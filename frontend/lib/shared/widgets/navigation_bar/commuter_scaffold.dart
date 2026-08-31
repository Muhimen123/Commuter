import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/safety/domain/safety_notifier.dart';

class CommuterScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CommuterScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for real-time safety alerts
    ref.listen<SafetyAlert?>(safetyAlertProvider, (previous, next) {
      if (next != null) {
        _showEmergencyModal(context, ref, next);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        height: 70,
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_bus),
              label: 'Ride',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              label: 'Safety',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _showEmergencyModal(BuildContext context, WidgetRef ref, SafetyAlert alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text('EMERGENCY ALERT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${alert.senderName} has triggered an SOS!',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Their live location is being shared with you. Please take immediate action.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(safetyAlertProvider.notifier).dismissAlert();
              Navigator.pop(context);
            },
            child: const Text('Dismiss', style: TextStyle(color: Colors.white60)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(safetyAlertProvider.notifier).dismissAlert();
              Navigator.pop(context);
              // Navigate to map and center on sender
              context.go('/?lat=${alert.latitude}&lon=${alert.longitude}&name=${alert.senderName}');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
            child: const Text('View on Map'),
          ),
        ],
      ),
    );
  }
}
