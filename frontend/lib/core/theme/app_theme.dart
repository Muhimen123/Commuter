import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      extensions: [
        SafetyColors(
          safe: AppColors.safe,
          warning: AppColors.warning,
          danger: AppColors.danger,
        ),
      ],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(40),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Basic dark theme implementation
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      extensions: [
        SafetyColors(
          safe: AppColors.safe,
          warning: AppColors.warning,
          danger: AppColors.danger,
        ),
      ],
    );
  }
}

class SafetyColors extends ThemeExtension<SafetyColors> {
  final Color? safe;
  final Color? warning;
  final Color? danger;

  SafetyColors({
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
    if (other is! SafetyColors) return this;
    return SafetyColors(
      safe: Color.lerp(safe, other.safe, t),
      warning: Color.lerp(warning, other.warning, t),
      danger: Color.lerp(danger, other.danger, t),
    );
  }
}
