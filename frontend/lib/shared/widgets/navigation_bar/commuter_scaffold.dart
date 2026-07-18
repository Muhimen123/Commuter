import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommuterScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CommuterScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        height: 70,
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              label: 'Ride',
            ),
            NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Safety'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
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
}
