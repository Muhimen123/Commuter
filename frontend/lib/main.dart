import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    debugPrint('Supabase initialized successfully');

    // Verify DB connectivity with a lightweight auth endpoint check
    await Supabase.instance.client.auth.getSession();
    debugPrint('Supabase connection verified');
  } catch (error) {
    debugPrint('Failed to connect to Supabase: $error');
  }

  runApp(const ProviderScope(child: CommuterApp()));
}
