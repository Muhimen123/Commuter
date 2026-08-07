import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/profile_entity.dart';
import 'fare_spent_by_route_card.dart';
import 'transit_mode_card.dart';
import 'ride_hours_card.dart';

class CommuteAnalyticsSection extends StatelessWidget {
  final CommuteAnalytics analytics;

  const CommuteAnalyticsSection({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commute Analytics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FareSpentByRouteCard(spendByRoute: analytics.spendByRoute),
        const SizedBox(height: AppSpacing.sm),
        TransitModeCard(transitModes: analytics.transitModes),
        const SizedBox(height: AppSpacing.sm),
        RideHoursCard(rideHours: analytics.rideHoursPerWeek),
      ],
    );
  }
}
