import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/search_field.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/filter_chips.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/ride_card.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

class RideDiscoveryPage extends StatelessWidget {
  const RideDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Ride> rides = [
      const Ride(
        id: '1',
        routeNumber: '42',
        routeName: 'Turag Transport',
        destination: 'Motijheel',
        via: 'Farmgate',
        arrivalTime: '2 min',
        status: RideStatus.arriving,
        rating: 4.8,
        reviewCount: 128,
        safetyScore: 98,
        fare: 35.00,
        isRecommended: true,
      ),
      const Ride(
        id: '2',
        routeNumber: '15',
        routeName: 'Mirpur Link',
        destination: 'Mirpur 10',
        via: 'Kakrail',
        arrivalTime: '8 min',
        status: RideStatus.scheduled,
        rating: 4.5,
        reviewCount: 84,
        safetyScore: 92,
        fare: 25.00,
      ),
      const Ride(
        id: '3',
        routeNumber: '88',
        routeName: 'Balaka Paribahan',
        destination: 'Gulshan 1',
        via: 'Detour active',
        arrivalTime: '15 min',
        status: RideStatus.delayed,
        rating: 4.9,
        reviewCount: 215,
        safetyScore: 99,
        fare: 40.00,
        alertMessage: 'Detour active',
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.menu),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Commuter',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const RideSearchField(),
          const SizedBox(height: AppSpacing.md),
          const RideFilterChips(),
          const SizedBox(height: AppSpacing.md),
          ...rides.map((ride) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: RideCard(ride: ride),
              )),
          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }
}
