import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/journey/domain/simulation_provider.dart';
import 'package:frontend/features/journey/presentation/widgets/simulation_toggle_dialog.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';
import 'package:frontend/features/safety/domain/safety_notifier.dart';
import 'package:frontend/features/notifications/domain/notification_notifier.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';

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

    // Listen for general notifications
    ref.listen<NotificationState>(notificationProvider, (previous, next) {
      if (next.latestNotification != null && next.latestNotification != previous?.latestNotification) {
        _handleNewNotification(context, ref, next.latestNotification!);
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
          destinations: [
            NavigationDestination(
              icon: GestureDetector(
                onLongPress: () => _onHomeLongPress(context, ref),
                child: const Icon(Icons.home_outlined),
              ),
              selectedIcon: GestureDetector(
                onLongPress: () => _onHomeLongPress(context, ref),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.directions_bus),
              label: 'Ride',
            ),
            const NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              label: 'Safety',
            ),
            const NavigationDestination(
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

  Future<void> _onHomeLongPress(BuildContext context, WidgetRef ref) async {
    final isEnabled = ref.read(simulationEnabledProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => SimulationToggleDialog(isCurrentlyEnabled: isEnabled),
    );
    if (confirmed != true) return;

    final newValue = !isEnabled;
    ref.read(simulationEnabledProvider.notifier).state = newValue;
    if (!context.mounted) return;
    CommuterToast.show(
      context,
      message: newValue
          ? 'Ride simulation enabled'
          : 'Ride simulation disabled',
      icon: newValue ? Icons.developer_mode_rounded : Icons.gps_fixed_rounded,
    );
  }

  void _handleNewNotification(BuildContext context, WidgetRef ref, AppNotification notification) {
    // If it's an SOS alert, the safetyAlertProvider might already be handling it with a big modal.
    // We can avoid double-showing if it's an SOS type.
    if (notification.type == 'sos_alert') {
      ref.read(notificationProvider.notifier).clearLatest();
      return;
    }

    CommuterToast.show(
      context,
      message: '${notification.title}: ${notification.content}',
      icon: _getIconForType(notification.type),
      onTap: () => _onNotificationTap(context, ref, notification),
    );

    ref.read(notificationProvider.notifier).clearLatest();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'contact_invite':
        return Icons.person_add_alt_1;
      case 'location_share':
        return Icons.share_location;
      case 'sos_alert':
        return Icons.emergency_share;
      default:
        return Icons.notifications;
    }
  }

  void _onNotificationTap(BuildContext context, WidgetRef ref, AppNotification notification) {
    ref.read(notificationProvider.notifier).markAsRead(notification.id);

    if (notification.type == 'contact_invite') {
      context.go('/trusted_contacts');
    } else if (notification.type == 'location_share') {
      final payload = notification.payload;
      if (payload != null) {
        final lat = payload['lat'];
        final lng = payload['lng'];
        final name = payload['sender_name'];
        if (lat != null && lng != null) {
          context.go('/?lat=$lat&lon=$lng&name=$name');
        } else {
          context.go('/safety');
        }
      }
    }
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
