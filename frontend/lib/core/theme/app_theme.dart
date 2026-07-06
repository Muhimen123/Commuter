import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFB8DEE0),
      onPrimaryContainer: const Color(0xFF0A2226),
      secondary: const Color(0xFF4A6268),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCCE6E8),
      onSecondaryContainer: const Color(0xFF051F22),
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerHigh: const Color(0xFFDDE4E3),
      onSurfaceVariant: const Color(0xFF414947),
      surfaceContainer: AppColors.background,
      outline: const Color(0xFF71797A),
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD9),
      onErrorContainer: const Color(0xFF410002),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
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
    textTheme: GoogleFonts.interTextTheme(),
    extensions: [
      SafetyColors(
        safe: AppColors.safe,
        warning: AppColors.warning,
        danger: AppColors.danger,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
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
