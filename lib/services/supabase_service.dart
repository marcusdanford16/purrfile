import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Owns Supabase initialization and gives the rest of the app a single,
/// testable access point (`SupabaseService.client`) instead of scattering
/// `Supabase.instance.client` everywhere.
///
/// This connects to the EXISTING PurrFile Supabase project. It never creates,
/// drops, or alters tables — see /supabase/rls_policies.sql for the one kind
/// of schema change this app makes (adding missing RLS policies), which is
/// applied manually in the Supabase SQL editor, not from the app.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Prefer environment configuration; fall back to the values from the
    // project proposal only for local/dev convenience. Never commit a real
    // .env — see .gitignore.
    String url;
    String publishableKey;
    try {
      await dotenv.load(fileName: '.env');
      url = dotenv.env['SUPABASE_URL'] ?? _fallbackUrl;
      publishableKey =
          dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? _fallbackKey;
    } catch (_) {
      // No .env bundled (e.g. a fresh checkout before `cp .env.example .env`).
      url = _fallbackUrl;
      publishableKey = _fallbackKey;
    }

    await Supabase.initialize(url: url, anonKey: publishableKey);
    _initialized = true;
  }

  static const String _fallbackUrl = 'https://hzpixswzwktmhwfchjtr.supabase.co';
  static const String _fallbackKey =
      'sb_publishable_h-3JYDwG-lccJel3HcK2QA_NGcjsVsO';

  static SupabaseClient get client => Supabase.instance.client;
}
