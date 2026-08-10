import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/search_field.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/filter_chips.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/ride_card.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

class RideDiscoveryPage extends StatefulWidget {
  const RideDiscoveryPage({super.key});

  @override
  State<RideDiscoveryPage> createState() => _RideDiscoveryPageState();
}

class _RideDiscoveryPageState extends State<RideDiscoveryPage> {
  String _selectedFilter = 'Nearby';

  final List<Ride> _allRides = [
    const Ride(
      id: '1',
      routeNumber: '42',
      routeName: 'Turag Transport',
      destination: 'Motijheel',
      via: 'Farmgate',
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
      via: 'Badda',
      status: RideStatus.delayed,
      rating: 4.9,
      reviewCount: 215,
      safetyScore: 99,
      fare: 40.00,
    ),
    const Ride(
      id: '4',
      routeNumber: '7',
      routeName: 'Bikalpa Auto',
      destination: 'Azimpur',
      via: 'Nilkhet',
      status: RideStatus.arriving,
      rating: 4.2,
      reviewCount: 45,
      safetyScore: 85,
      fare: 15.00,
    ),
    const Ride(
      id: '5',
      routeNumber: '9',
      routeName: 'Salsabil',
      destination: 'Jatrabari',
      via: 'Sayedabad',
      status: RideStatus.scheduled,
      rating: 4.7,
      reviewCount: 156,
      safetyScore: 95,
      fare: 30.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Apply sorting/filtering based on selected chip
    List<Ride> displayedRides = List.from(_allRides);
    if (_selectedFilter == 'Highly Rated') {
      displayedRides.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedFilter == 'Safest Routes') {
      displayedRides.sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
    } else if (_selectedFilter == 'Lowest Fare') {
      displayedRides.sort((a, b) => a.fare.compareTo(b.fare));
    }
    // 'Nearby' uses the default order

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
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        children: [
          const RideSearchField(),
          const SizedBox(height: AppSpacing.md),
          RideFilterChips(
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ...displayedRides.map((ride) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: RideCard(ride: ride),
              )),
          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }
}
