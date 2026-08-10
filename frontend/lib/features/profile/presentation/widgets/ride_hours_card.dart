import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/profile_entity.dart';

class RideHoursCard extends StatelessWidget {
  final List<DailyRideHours> rideHours;

  const RideHoursCard({super.key, required this.rideHours});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxHours = rideHours.isNotEmpty
        ? rideHours.map((e) => e.hours).reduce(math.max)
        : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Hours per Week',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: rideHours.map((day) {
                final double ratio = maxHours > 0 ? (day.hours / maxHours).clamp(0.1, 1.0) : 0.1;
                final bool isHigh = day.hours > 3.0;
                final bool isMax = day.hours == maxHours;
                final barColor = isMax
                    ? colorScheme.primary
                    : isHigh
                        ? colorScheme.secondary.withValues(alpha: 0.7)
                        : colorScheme.surfaceContainerHigh;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 72 * ratio,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(AppRadius.extraSmall),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      day.dayLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
