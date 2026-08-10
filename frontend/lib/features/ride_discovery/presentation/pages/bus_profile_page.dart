import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

class BusProfilePage extends StatelessWidget {
  final Ride ride;

  const BusProfilePage({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Mock start and end points for the route
    final startPoint = const LatLng(23.7317, 90.4067); // Motijheel area
    final endPoint = const LatLng(23.8223, 90.3654); // Mirpur area

    // Mock stoppage points
    final List<String> stops = [
      'Motijheel',
      'Press Club',
      'Shahbag',
      'Kawran Bazar',
      'Farmgate',
      'Agargaon',
      'Mirpur 10',
    ];

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      body: Stack(
        children: [
          // Background Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(23.7770, 90.3860), // roughly between start and end
                initialZoom: 12.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.commuter.frontend',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [startPoint, endPoint], // simplistic straight line for now
                      strokeWidth: 4.0,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startPoint,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: colorScheme.primary, size: 32),
                    ),
                    Marker(
                      point: endPoint,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: colorScheme.error, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content overlay
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: 60,
                      child: Container(
                        color: colorScheme.background,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cards Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                          child: Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.payments_outlined,
                                  title: 'AVERAGE FARE',
                                  value: '৳${ride.fare.toStringAsFixed(2)}',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.verified_user_outlined,
                                  title: 'SAFETY SCORE',
                                  value: '${ride.safetyScore}%',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Community Feed Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Community Feed',
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Mock Review Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              side: BorderSide(color: colorScheme.surfaceVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: colorScheme.primaryContainer,
                                    child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Sarah J.', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                            Text('15 mins ago', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: List.generate(5, (index) => const Icon(Icons.star, size: 16, color: Colors.amber)),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          'Clean bus, driver was very helpful when I asked about connections.',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Crowd Level Card (slightly smaller)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              side: BorderSide(color: colorScheme.surfaceVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm), // smaller padding
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.groups, size: 20, color: colorScheme.primary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Crowd Level',
                                              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '10 mins ago',
                                              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Moderate crowd at the previous stop.',
                                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Stoppage Points List (Dropdown / ExpansionTile)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              side: BorderSide(color: colorScheme.surfaceVariant),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: Text(
                                  'Stoppage Points',
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: stops.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final isFirst = index == 0;
                                      final isLast = index == stops.length - 1;
                                      return ListTile(
                                        leading: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isFirst || isLast ? Icons.location_on : Icons.trip_origin,
                                              color: isFirst ? colorScheme.primary : (isLast ? colorScheme.error : colorScheme.onSurfaceVariant),
                                              size: isFirst || isLast ? 24 : 16,
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          stops[index],
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Custom App Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.7),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Bus ${ride.routeNumber} - ${ride.routeName}',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
