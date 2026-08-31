import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/app.dart';

String _bareSupabaseUrl(String rawUrl) {
  return rawUrl.replaceFirst(RegExp(r'/rest/v1/?$'), '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final url = _bareSupabaseUrl(const String.fromEnvironment('SUPABASE_URL'));
    final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      debugPrint('Supabase initialized successfully');

      await Supabase.instance.client.auth.getSession();
      debugPrint('Supabase connection verified');
    }
  } catch (error) {
    debugPrint('Failed to connect to Supabase: $error');
  }

  runApp(const ProviderScope(child: CommuterApp()));
}
