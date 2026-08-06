import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/profile_entity.dart';

class TransitIntelligenceSection extends StatelessWidget {
  final TransitIntelligence intelligence;

  const TransitIntelligenceSection({
    super.key,
    required this.intelligence,
  });

  String _formatNumber(int number) {
    if (number >= 1000) {
      final str = number.toString();
      return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transit Intelligence',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _IntelligenceCard(
                icon: Icons.verified,
                iconColor: Theme.of(context).colorScheme.primary,
                valueText: '${intelligence.trustScorePercentage}%',
                labelText: 'Community Trust Score',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _IntelligenceCard(
                icon: Icons.route_outlined,
                iconColor: Theme.of(context).colorScheme.secondary,
                valueText: '${intelligence.routesMapped}',
                labelText: 'Routes Mapped',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _IntelligenceCard(
                icon: Icons.directions_transit_outlined,
                iconColor: Theme.of(context).colorScheme.primary,
                valueText: '${intelligence.stopsAdded}',
                labelText: 'Stops Added',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _IntelligenceCard(
                icon: Icons.people_outline,
                iconColor: Theme.of(context).colorScheme.secondary,
                valueText: _formatNumber(intelligence.commutersHelped),
                labelText: 'Commuters Helped',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IntelligenceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String valueText;
  final String labelText;

  const _IntelligenceCard({
    required this.icon,
    required this.iconColor,
    required this.valueText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            valueText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            labelText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
