import 'package:flutter/material.dart';

class StartJourneyFab extends StatelessWidget {
  const StartJourneyFab({
    super.key,
    required this.hasRoute,
    required this.isStartingJourney,
    required this.journeyStarted,
    required this.onPressed,
  });

  final bool hasRoute;
  final bool isStartingJourney;
  final bool journeyStarted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!hasRoute) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: isStartingJourney ? null : onPressed,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: isStartingJourney
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              ),
            )
          : Icon(journeyStarted ? Icons.add : Icons.directions_bus),
      label: Text(
        isStartingJourney
            ? 'Starting Journey'
            : (journeyStarted ? 'Add Stop' : 'Start Journey'),
      ),
    );
  }
}
