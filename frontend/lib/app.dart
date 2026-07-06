import 'package:flutter/material.dart';
import 'core/theme/commuter_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';

class CommuterApp extends StatelessWidget {
  const CommuterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commuter',
      theme: CommuterTheme.lightTheme,
      darkTheme: CommuterTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
