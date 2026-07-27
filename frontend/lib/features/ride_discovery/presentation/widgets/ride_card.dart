import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/ride.dart';

class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(color: colorScheme.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ride.isRecommended) ...[
              _RecommendedBadge(),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteNumberBox(routeNumber: ride.routeNumber),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.routeName,
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'via ${ride.via}',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      if (ride.alertMessage != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(Icons.warning, size: 16, color: colorScheme.error),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              ride.alertMessage!,
                              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _ArrivalTimeBox(
                  time: ride.arrivalTime,
                  status: ride.status,
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 20, color: colorScheme.tertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      ride.rating.toString(),
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '(${ride.reviewCount} reviews)',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 18, color: colorScheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Safety Score: ${ride.safetyScore}%',
                      style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments, size: 18, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '\$${ride.fare.toStringAsFixed(2)}',
                      style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 40),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Track Ride'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colorScheme.tertiaryContainer.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thumb_up, size: 16, color: colorScheme.tertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Recommended by 40+ people today',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteNumberBox extends StatelessWidget {
  final String routeNumber;

  const _RouteNumberBox({required this.routeNumber});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      alignment: Alignment.center,
      child: Text(
        routeNumber,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ArrivalTimeBox extends StatelessWidget {
  final String time;
  final RideStatus status;

  const _ArrivalTimeBox({required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    String statusText;

    switch (status) {
      case RideStatus.arriving:
        statusColor = colorScheme.primary;
        statusText = 'ARRIVING';
        break;
      case RideStatus.scheduled:
        statusColor = colorScheme.onSurfaceVariant;
        statusText = 'SCHEDULED';
        break;
      case RideStatus.delayed:
        statusColor = colorScheme.tertiary;
        statusText = 'DELAYED';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: textTheme.headlineMedium?.copyWith(
            color: status == RideStatus.arriving ? statusColor : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          statusText,
          style: textTheme.labelMedium?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
