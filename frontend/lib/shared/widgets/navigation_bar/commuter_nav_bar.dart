import 'package:flutter/material.dart';

/// Shared bottom navigation bar chrome — used both inside [CommuterScaffold]
/// (driven by [StatefulNavigationShell.goBranch]) and by standalone pages
/// outside the tab shell, like the incident report form, that still want
/// the tab bar visible and reachable (driven by [GoRouter.go] there instead).
class CommuterNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onHomeLongPress;

  const CommuterNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onHomeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: 70,
      child: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        destinations: [
          NavigationDestination(
            icon: GestureDetector(
              onLongPress: onHomeLongPress,
              child: const Icon(Icons.home_outlined),
            ),
            selectedIcon: GestureDetector(
              onLongPress: onHomeLongPress,
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
    );
  }
}
