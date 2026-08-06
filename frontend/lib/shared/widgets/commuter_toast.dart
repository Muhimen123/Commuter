import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/core/theme/design_tokens.dart';

class CommuterToast {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? iconBackgroundColor,
    Color? iconForegroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = backgroundColor ?? colorScheme.primaryContainer;
    final fg = foregroundColor ?? colorScheme.onPrimaryContainer;
    final iconBg = iconBackgroundColor ?? colorScheme.primary;
    final iconFg = iconForegroundColor ?? colorScheme.onPrimary;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        elevation: 4,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconFg,
                size: 16,
              ),
            )
                .animate(delay: const Duration(milliseconds: 100))
                .scale(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                )
                .rotate(
                  begin: -0.1,
                  end: 0,
                  duration: const Duration(milliseconds: 300),
                ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        )
            .animate()
            .fade(duration: const Duration(milliseconds: 250))
            .slideY(
              begin: 0.2,
              end: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}
