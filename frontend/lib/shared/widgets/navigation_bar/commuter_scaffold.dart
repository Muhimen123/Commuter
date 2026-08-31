import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/journey/domain/simulation_provider.dart';
import 'package:frontend/features/journey/presentation/widgets/simulation_toggle_dialog.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';

class CommuterScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CommuterScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}
