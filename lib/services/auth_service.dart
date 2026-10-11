import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Thin wrapper around Supabase Auth. Every method throws a plain
/// [String] message on failure so screens can show it directly without
/// depending on Supabase exception types.
class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      if (res.user == null) {
        throw 'Sign-up failed. Please try again.';
      }
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Could not create your account. Check your connection and try again.';
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    try {
      final res = await _client.auth
          .signInWithPassword(email: email.trim(), password: password);
      if (res.user == null) {
        throw 'Invalid email or password.';
      }
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Could not log in. Check your connection and try again.';
    }
  }

  Future<void> logOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw 'Could not log out. Please try again.';
    }
  }
}
