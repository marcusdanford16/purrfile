import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reminder.dart';
import 'supabase_service.dart';

/// Same ownership model as [HealthRecordService]: `reminders.cat_id` is
/// joined against `cats.user_id` both in RLS and here.
class ReminderService {
  final SupabaseClient _client = SupabaseService.client;

  /// Friendly message for users. While developing (debug builds only), the
  /// real Supabase error is appended and printed so you can see WHY a
  /// request failed (RLS policy, wrong column, bad value...).
  String _fail(String friendly, Object error) {
    debugPrint('ReminderService error: $error');
    return kDebugMode ? '$friendly\n[$error]' : friendly;
  }

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'You must be logged in.';
    return uid;
  }

  /// All reminders for every cat the current user owns (used by the
  /// Reminders & Notifications screen, which is cat-agnostic).
  Future<List<Reminder>> getAllReminders() async {
    try {
      final rows = await _client
          .from('reminders')
          .select('*, cats!inner(user_id)')
          .eq('cats.user_id', _uid)
          .order('reminder_date', ascending: true);
      return (rows as List)
          .map((r) => Reminder.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _fail('Could not load reminders. Please try again.', e);
    }
  }

  Future<List<Reminder>> getRemindersForCat(String catId) async {
    try {
      final rows = await _client
          .from('reminders')
          .select('*, cats!inner(user_id)')
          .eq('cat_id', catId)
          .eq('cats.user_id', _uid)
          .order('reminder_date', ascending: true);
      return (rows as List)
          .map((r) => Reminder.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _fail('Could not load reminders. Please try again.', e);
    }
  }

  Future<Reminder> addReminder(Reminder reminder) async {
    try {
      final row = await _client
          .from('reminders')
          .insert(reminder.toInsertMap())
          .select()
          .single();
      return Reminder.fromMap(row);
    } catch (e) {
      throw _fail('Could not save this reminder. Please try again.', e);
    }
  }

  Future<Reminder> updateReminder(Reminder reminder) async {
    try {
      final row = await _client
          .from('reminders')
          .update(reminder.toInsertMap())
          .eq('id', reminder.id)
          .select()
          .single();
      return Reminder.fromMap(row);
    } catch (e) {
      throw _fail('Could not update this reminder. Please try again.', e);
    }
  }

  Future<void> markCompleted(String reminderId) async {
    try {
      await _client
          .from('reminders')
          .update({'notification_status': true}).eq('id', reminderId);
    } catch (e) {
      throw _fail('Could not update this reminder. Please try again.', e);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _client.from('reminders').delete().eq('id', reminderId);
    } catch (e) {
      throw _fail('Could not delete this reminder. Please try again.', e);
    }
  }
}
