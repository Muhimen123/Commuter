import 'package:flutter/material.dart';

import 'package:frontend/core/theme/design_tokens.dart';

/// Opens the walk + ride itinerary planner for the drafted route.
///
/// Sits beside [StartJourneyFab] and, like it, only appears once a route has
/// actually been drafted — there is nothing to plan before that.
class JourneyPlanButton extends StatelessWidget {
  final bool hasRoute;
  final VoidCallback onPressed;

  const JourneyPlanButton({
    super.key,
    required this.hasRoute,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasRoute) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Suggested rides',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          width: AppSizing.touchTargetMin,
          height: AppSizing.touchTargetMin,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.alt_route_rounded,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
