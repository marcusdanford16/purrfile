import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cat.dart';
import 'supabase_service.dart';

/// All reads/writes are implicitly scoped to the current user by RLS
/// (`cats.user_id = auth.uid()`), but we also filter explicitly so a missing
/// or misconfigured policy fails loudly (an empty list) rather than leaking
/// another user's data into a client-side bug.
class CatService {
  final SupabaseClient _client = SupabaseService.client;

  static const String _photoBucket = 'cat-photos';

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'You must be logged in.';
    return uid;
  }

  Future<String> uploadCatPhoto(Uint8List bytes, String extension) async {
    final safeExtension = extension.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
    final path =
        '$_uid/${DateTime.now().millisecondsSinceEpoch}.${safeExtension.isEmpty ? 'jpg' : safeExtension}';

    try {
      await _client.storage.from(_photoBucket).uploadBinary(path, bytes);
      return _client.storage.from(_photoBucket).getPublicUrl(path);
    } catch (e) {
      throw 'Could not upload this cat photo. Please try again.';
    }
  }

  Future<List<Cat>> getCats() async {
    try {
      final rows = await _client
          .from('cats')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: true);
      return (rows as List)
          .map((r) => Cat.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Could not load your cats. Please try again.';
    }
  }

  Future<Cat> addCat(Cat cat) async {
    try {
      final row = await _client
          .from('cats')
          .insert(cat.toInsertMap())
          .select()
          .single();
      return Cat.fromMap(row);
    } catch (e) {
      throw 'Could not save this cat profile. Please try again.';
    }
  }

  Future<Cat> updateCat(Cat cat) async {
    try {
      final row = await _client
          .from('cats')
          .update(cat.toInsertMap())
          .eq('id', cat.id)
          .eq('user_id', _uid)
          .select()
          .single();
      return Cat.fromMap(row);
    } catch (e) {
      throw 'Could not update this cat profile. Please try again.';
    }
  }

  Future<void> deleteCat(String catId) async {
    try {
      await _client.from('cats').delete().eq('id', catId).eq('user_id', _uid);
    } catch (e) {
      throw 'Could not delete this cat. Please try again.';
    }
  }
}
