import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/search_field.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/filter_chips.dart';
import 'package:frontend/features/ride_discovery/presentation/widgets/ride_card.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';
import 'package:frontend/features/ride_discovery/domain/entities/route_stop.dart';
import 'package:frontend/features/ride_discovery/domain/rides_provider.dart';

class RideDiscoveryPage extends ConsumerStatefulWidget {
  const RideDiscoveryPage({super.key});

  @override
  ConsumerState<RideDiscoveryPage> createState() => _RideDiscoveryPageState();
}

class _RideDiscoveryPageState extends ConsumerState<RideDiscoveryPage> {
  String _selectedFilter = 'Nearby';
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ride> _filtered(
    List<Ride> rides,
    Map<String, List<RouteStop>> stopsByRoute,
  ) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return rides;
    return rides.where((ride) {
      final matchesRide = ride.routeName.toLowerCase().contains(query) ||
          ride.routeNumber.toLowerCase().contains(query) ||
          ride.destination.toLowerCase().contains(query) ||
          ride.via.toLowerCase().contains(query);
      if (matchesRide) return true;
      final stops = stopsByRoute[ride.id] ?? const [];
      return stops.any((stop) => stop.stopName.toLowerCase().contains(query));
    }).toList();
  }

  List<Ride> _sorted(List<Ride> rides) {
    final displayedRides = List<Ride>.from(rides);
    if (_selectedFilter == 'Highly Rated') {
      displayedRides.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedFilter == 'Safest Routes') {
      // Unrated routes (null safetyScore) sort last, not first.
      displayedRides.sort((a, b) => (b.safetyScore ?? -1).compareTo(a.safetyScore ?? -1));
    } else if (_selectedFilter == 'Lowest Fare') {
      displayedRides.sort((a, b) => a.fare.compareTo(b.fare));
    }
    // 'Nearby' uses the default order
    return displayedRides;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ridesAsync = ref.watch(ridesProvider);
    final stopsByRoute =
        ref.watch(allRouteStopsProvider).asData?.value ?? const {};

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(ridesProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            children: [
              RideSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
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
              ...ridesAsync.when(
                data: (rides) => _sorted(_filtered(rides, stopsByRoute))
                    .map((ride) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: RideCard(ride: ride),
                        ))
                    .toList(),
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (error, _) => [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: Center(child: Text('Could not load rides: $error')),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
