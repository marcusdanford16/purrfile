import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/health_record.dart';
import 'supabase_service.dart';

/// `health_records` keys off `cat_id`, not `user_id`, so ownership is
/// enforced two ways: RLS on the database side (see
/// supabase/rls_policies.sql — a record is only visible if its cat belongs
/// to auth.uid()), and an inner join here so a bug in this client never
/// silently trusts a `cat_id` on its own.
class HealthRecordService {
  final SupabaseClient _client = SupabaseService.client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'You must be logged in.';
    return uid;
  }

  Future<List<HealthRecord>> getRecordsForCat(String catId) async {
    try {
      final rows = await _client
          .from('health_records')
          .select('*, cats!inner(user_id)')
          .eq('cat_id', catId)
          .eq('cats.user_id', _uid)
          .order('date', ascending: false);
      return (rows as List)
          .map((r) => HealthRecord.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Could not load health records. Please try again.';
    }
  }

  Future<HealthRecord> addRecord(HealthRecord record) async {
    try {
      final row = await _client
          .from('health_records')
          .insert(record.toInsertMap())
          .select()
          .single();
      return HealthRecord.fromMap(row);
    } catch (e) {
      throw 'Could not save this health record. Please try again.';
    }
  }

  Future<HealthRecord> updateRecord(HealthRecord record) async {
    try {
      final row = await _client
          .from('health_records')
          .update(record.toInsertMap())
          .eq('id', record.id)
          .select()
          .single();
      return HealthRecord.fromMap(row);
    } catch (e) {
      throw 'Could not update this health record. Please try again.';
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _client.from('health_records').delete().eq('id', recordId);
    } catch (e) {
      throw 'Could not delete this health record. Please try again.';
    }
  }
}
