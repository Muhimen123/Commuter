import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Small floating legend shown while the safety heatmap is active —
/// mirrors the intensity-bar convention used by weather-radar apps.
class SafetyHeatmapLegend extends StatelessWidget {
  const SafetyHeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final safety = theme.extension<SafetyColors>();
    final danger = safety?.danger ?? const Color(0xFFFF5252);
    final warning = safety?.warning ?? const Color(0xFFFFB300);
    final safe = safety?.safe ?? const Color(0xFF2ECC71);

    return Semantics(
      label: 'Safety heatmap legend, red is riskier, green is safer',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Riskier',
              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Container(
              width: 72,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(colors: [danger, warning, safe]),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Safer',
              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
