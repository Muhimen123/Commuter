import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/profile_entity.dart';

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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              _MetricItemRow(
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
              _MetricItemRow(
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

class _MetricItemRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String valueText;
  final Color valueColor;

  const _MetricItemRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.valueText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
        Text(
          valueText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
