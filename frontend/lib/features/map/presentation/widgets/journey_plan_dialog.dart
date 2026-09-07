import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/map/domain/entities/journey_leg.dart';
import 'package:frontend/features/map/domain/transit_plan_provider.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

/// Lists the walk + ride itineraries between two points and returns the one
/// the commuter picks.
///
/// Mirrors [BusSelectionDialog]'s dialog shape/padding — same rounded
/// [Dialog], same title + subtitle + action-row layout.
class JourneyPlanDialog extends ConsumerStatefulWidget {
  final LatLng origin;
  final LatLng destination;

  const JourneyPlanDialog({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  ConsumerState<JourneyPlanDialog> createState() => _JourneyPlanDialogState();
}

class _JourneyPlanDialogState extends ConsumerState<JourneyPlanDialog> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plansAsync = ref.watch(
      transitPlanProvider(
        TransitPlanRequest(
          origin: widget.origin,
          destination: widget.destination,
        ),
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Suggested Rides',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            Text(
              'Walk and ride combinations using rides in the database.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: plansAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'Could not plan a route right now. Please try again.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                  ),
                ),
                data: (itineraries) => itineraries.isEmpty
                    ? _buildEmptyState(context, colorScheme)
                    : _buildItineraryList(context, colorScheme, itineraries),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.signpost_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'re already there.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryList(
    BuildContext context,
    ColorScheme colorScheme,
    List<TransitItinerary> itineraries,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: itineraries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final itinerary = itineraries[index];
        final expanded = index == _expandedIndex;
        return _ItineraryCard(
          itinerary: itinerary,
          expanded: expanded,
          onTap: () => setState(() => _expandedIndex = expanded ? -1 : index),
          onUse: () => Navigator.of(context).pop(itinerary),
        );
      },
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  final TransitItinerary itinerary;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onUse;

  const _ItineraryCard({
    required this.itinerary,
    required this.expanded,
    required this.onTap,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: expanded ? colorScheme.primary : colorScheme.outlineVariant,
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegChipsRow(legs: itinerary.legs),
                  const SizedBox(height: AppSpacing.xs),
                  _SummaryLine(itinerary: itinerary),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(
              height: 1,
              indent: AppSpacing.sm,
              endIndent: AppSpacing.sm,
              color: colorScheme.outlineVariant,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final leg in itinerary.legs) _LegStep(leg: leg),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: onUse,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(0, AppSizing.buttonHeight),
                      ),
                      child: const Text('Use this plan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small icon-only chips summarising a plan at a glance, e.g. 🚶 ▸ 🚌 ▸ 🚶.
class _LegChipsRow extends StatelessWidget {
  final List<JourneyLeg> legs;

  const _LegChipsRow({required this.legs});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final children = <Widget>[];

    for (var i = 0; i < legs.length; i++) {
      if (i > 0) {
        children.add(
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      }
      children.add(_legChip(context, legs[i]));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Widget _legChip(BuildContext context, JourneyLeg leg) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (leg) {
      WalkLeg() => Icon(
          Icons.directions_walk_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      RideLeg(ride: final ride) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: rideColor(ride, colorScheme).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.extraSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                transitModeIcon(ride.transitMode),
                size: 14,
                color: rideColor(ride, colorScheme),
              ),
              const SizedBox(width: 2),
              Text(
                ride.routeNumber,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: rideColor(ride, colorScheme),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
    };
  }
}

class _SummaryLine extends StatelessWidget {
  final TransitItinerary itinerary;

  const _SummaryLine({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parts = <String>[
      '${itinerary.totalWalkMeters.round()} m walk',
      if (itinerary.rideCount > 0)
        '${itinerary.rideCount} ${itinerary.rideCount == 1 ? 'ride' : 'rides'}',
      if (itinerary.totalFare > 0) '৳${itinerary.totalFare.round()}',
    ];

    return Text(
      parts.join(' · '),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _LegStep extends StatelessWidget {
  final JourneyLeg leg;

  const _LegStep({required this.leg});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Pattern matching only promotes a local variable, not a field access —
    // rebind to one so the RideLeg branch below can read leg.stopCount.
    final leg = this.leg;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: switch (leg) {
        WalkLeg(distanceMeters: final metres, toStopName: final toStop) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.directions_walk_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  toStop != null
                      ? 'Walk ~${metres.round()} m to $toStop'
                      : 'Walk ~${metres.round()} m to your destination',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        RideLeg(
          ride: final ride,
          boardStop: final board,
          alightStop: final alight,
        ) =>
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                transitModeIcon(ride.transitMode),
                size: 18,
                color: rideColor(ride, colorScheme),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${ride.routeNumber} · ${ride.routeName}\n'
                  'Board at ${board.stopName} → alight at ${alight.stopName} '
                  '(${leg.stopCount} stops)',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
      },
    );
  }
}

/// A route's line color when the DB has one, else a mode-appropriate default.
Color rideColor(Ride ride, ColorScheme colorScheme) {
  final hex = ride.lineColor;
  if (hex != null && hex.length == 7 && hex.startsWith('#')) {
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value != null) return Color(0xFF000000 | value);
  }
  return colorScheme.primary;
}

IconData transitModeIcon(TransitMode mode) {
  return switch (mode) {
    TransitMode.bus => Icons.directions_bus_rounded,
    TransitMode.metro => Icons.subway_rounded,
    TransitMode.train => Icons.train_rounded,
  };
}
