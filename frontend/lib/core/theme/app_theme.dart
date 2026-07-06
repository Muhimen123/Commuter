import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF307082),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF307082),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFB8DEE0),
      onPrimaryContainer: const Color(0xFF0A2226),
      secondary: const Color(0xFF4A6268),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFCCE6E8),
      onSecondaryContainer: const Color(0xFF051F22),
      surface: const Color(0xFFF9F9F9),
      onSurface: const Color(0xFF2D3436),
      surfaceContainerHigh: const Color(0xFFDDE4E3),
      onSurfaceVariant: const Color(0xFF414947),
      surfaceContainer: const Color(0xFFECE7DC),
      outline: const Color(0xFF71797A),
      error: const Color(0xFFFF7675),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFDAD9),
      onErrorContainer: const Color(0xFF410002),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        );
      }),
    ),
  );

  // For dark theme, you might want to define m3_roles_dark in DESIGN_TOKENS.json
  // For now, let's just use a basic dark theme based on the same seed
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF307082),
      brightness: Brightness.dark,
    ),
  );
}
