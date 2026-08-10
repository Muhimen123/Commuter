import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/profile_entity.dart';

class QuickStatsRow extends StatelessWidget {
  final QuickStats stats;

  const QuickStatsRow({
    super.key,
    required this.stats,
  });

  String _formatNumber(num number) {
    if (number is int) {
      if (number >= 1000) {
        final str = number.toString();
        return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
      }
      return number.toString();
    } else {
      if (number == number.toInt()) {
        return _formatNumber(number.toInt());
      }
      return number.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safetyColors = Theme.of(context).extension<SafetyColors>();
    final goldColor = safetyColors?.warning ?? Colors.amber;

    return Row(
      children: [
        Expanded(
          child: _StatItemCard(
            icon: Icons.directions_bus,
            iconBgColor: Theme.of(context).colorScheme.primary,
            iconColor: Theme.of(context).colorScheme.onPrimary,
            valueText: _formatNumber(stats.totalRides),
            unitText: '',
            labelText: 'Total Rides',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatItemCard(
            icon: Icons.place_outlined,
            iconBgColor: goldColor,
            iconColor: Colors.white,
            valueText: _formatNumber(stats.distanceCommuted),
            unitText: ' ${stats.distanceUnit}',
            labelText: 'Distance Commuted',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatItemCard(
            icon: Icons.eco_outlined,
            iconBgColor: Theme.of(context).colorScheme.secondaryContainer,
            iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
            valueText: _formatNumber(stats.co2Saved),
            unitText: ' ${stats.co2Unit}',
            labelText: 'Estimated CO2 Saved',
          ),
        ),
      ],
    );
  }
}

class _StatItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String valueText;
  final String unitText;
  final String labelText;

  const _StatItemCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueText,
    required this.unitText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
              children: [
                TextSpan(text: valueText),
                if (unitText.isNotEmpty)
                  TextSpan(
                    text: unitText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            labelText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
