import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/profile_entity.dart';
import 'transit_intelligence_card.dart';

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
              child: TransitIntelligenceCard(
                icon: Icons.verified,
                iconColor: Theme.of(context).colorScheme.primary,
                valueText: '${intelligence.trustScorePercentage}%',
                labelText: 'Community Trust Score',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TransitIntelligenceCard(
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
              child: TransitIntelligenceCard(
                icon: Icons.directions_transit_outlined,
                iconColor: Theme.of(context).colorScheme.primary,
                valueText: '${intelligence.stopsAdded}',
                labelText: 'Stops Added',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TransitIntelligenceCard(
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
