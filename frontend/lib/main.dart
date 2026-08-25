import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/app.dart';

/// Supabase.initialize() always appends its own `/rest/v1` (and `/auth/v1`,
/// etc.) suffix to the url it's given, so it must receive the bare project
/// URL. SUPABASE_URL in .env is kept with a trailing `/rest/v1/` for other
/// tooling, so strip that suffix here before handing it to the SDK —
/// otherwise every request ends up double-pathed (.../rest/v1/rest/v1/...).
String _bareSupabaseUrl(String rawUrl) {
  return rawUrl.replaceFirst(RegExp(r'/rest/v1/?$'), '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    String url = const String.fromEnvironment('SUPABASE_URL');
    if (url.contains('/rest/v1')) {
      url = url.split('/rest/v1').first;
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
      debugPrint('Supabase initialized successfully');

      // Verify DB connectivity with a lightweight auth endpoint check
      await Supabase.instance.client.auth.getSession();
      debugPrint('Supabase connection verified');
    }
  } catch (error) {
    debugPrint('Failed to connect to Supabase: $error');
  }

  runApp(const ProviderScope(child: CommuterApp()));
}
