import 'package:flutter/material.dart';
import 'design_tokens.dart';

class SafetyColors extends ThemeExtension<SafetyColors> {
  final Color? safe;
  final Color? warning;
  final Color? danger;

  const SafetyColors({
    required this.safe,
    required this.warning,
    required this.danger,
  });

  @override
  SafetyColors copyWith({Color? safe, Color? warning, Color? danger}) {
    return SafetyColors(
      safe: safe ?? this.safe,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  SafetyColors lerp(ThemeExtension<SafetyColors>? other, double t) {
    if (other is! SafetyColors) {
      return this;
    }
    return SafetyColors(
      safe: Color.lerp(safe, other.safe, t),
      warning: Color.lerp(warning, other.warning, t),
      danger: Color.lerp(danger, other.danger, t),
    );
  }
}

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
    extensions: const [
      SafetyColors(
        safe: AppColors.safetySafe,
        warning: AppColors.safetyWarning,
        danger: AppColors.safetyDanger,
      ),
    ],
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, height: 64 / 57),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, height: 52 / 45),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, height: 44 / 36),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 40 / 32),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 36 / 28),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 28 / 22),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 24 / 16),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 16 / 12),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 16 / 11),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      color: const Color(0xFFF9F9F9),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
        shape: const StadiumBorder(),
        backgroundColor: const Color(0xFF307082),
        foregroundColor: const Color(0xFFFFFFFF),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: Color(0xFF307082), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
