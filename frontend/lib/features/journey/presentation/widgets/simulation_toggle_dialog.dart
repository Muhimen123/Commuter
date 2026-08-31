import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Confirmation dialog shown after long-pressing the Home nav tab, offering
/// to turn ride simulation on or off. [isCurrentlyEnabled] picks the copy
/// and action so the same dialog serves both directions of the toggle.
class SimulationToggleDialog extends StatelessWidget {
  const SimulationToggleDialog({super.key, required this.isCurrentlyEnabled});

  final bool isCurrentlyEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.developer_mode_rounded, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ride Simulation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        isCurrentlyEnabled
            ? 'Turn off ride simulation? Your journey will go back to using your '
                'real GPS location.'
            : 'Enable ride simulation? While on, your location will move '
                'automatically along the drawn route instead of using your real '
                'GPS — useful for testing without physically riding. Backend '
                'pings are recorded exactly like a real ride.',
        style: TextStyle(fontSize: 15, height: 1.35, color: colorScheme.onSurface),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCurrentlyEnabled ? AppColors.danger : AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  isCurrentlyEnabled ? 'Turn Off' : 'Enable',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
