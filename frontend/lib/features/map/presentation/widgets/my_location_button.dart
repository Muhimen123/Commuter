import 'package:flutter/material.dart';

/// A floating circular button to re-center the map on the user's current location.
class MyLocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double bottom;

  const MyLocationButton({
    super.key,
    required this.onPressed,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: bottom + 56,
      left: 16,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.my_location_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }
}