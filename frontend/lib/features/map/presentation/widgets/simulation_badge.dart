import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';

/// Small floating pill shown while a ride's location is being driven by
/// [RideSimulator] instead of real GPS, so simulated pings are never
/// mistaken for a real one.
class SimulationBadge extends StatelessWidget {
  const SimulationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.developer_mode_rounded,
              size: 16,
              color: colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Simulating ride',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
