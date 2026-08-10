import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/profile_entity.dart';
import 'safety_metric_item_row.dart';

class SafetyMetricsSection extends StatelessWidget {
  final SafetyMetrics metrics;

  const SafetyMetricsSection({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final safetyColors = Theme.of(context).extension<SafetyColors>();
    final warningColor = safetyColors?.warning ?? Colors.amber;
    final safeColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Metrics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              SafetyMetricItemRow(
                icon: Icons.warning_amber_rounded,
                iconColor: warningColor,
                title: 'Safety Reports',
                subtitle: 'Submitted for review',
                valueText: '${metrics.reportsSubmitted}',
                valueColor: warningColor,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(height: 1),
              ),
              SafetyMetricItemRow(
                icon: Icons.verified_user,
                iconColor: safeColor,
                title: 'Safe Journeys',
                subtitle: 'Completed without incident',
                valueText: '${metrics.safeJourneysCompleted}',
                valueColor: safeColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
