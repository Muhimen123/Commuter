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

class CommuterTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
      ),
      scaffoldBackgroundColor: AppColors.background,
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
        color: AppColors.surface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
          shape: const StadiumBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE0E0E0).withValues(alpha: 0.5), // Matches the light grey in images
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    );
  }

  // Dark theme implementation can be added here if needed, 
  // following the same pattern with dark role overrides.
  static ThemeData get darkTheme => lightTheme; // Placeholder for now
}
