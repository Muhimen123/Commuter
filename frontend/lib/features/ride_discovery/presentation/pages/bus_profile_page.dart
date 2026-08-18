import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

class BusProfilePage extends StatelessWidget {
  final Ride ride;

  const BusProfilePage({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Mock realistic route (polyline)
    final List<LatLng> routePoints = [
      const LatLng(23.7317, 90.4067), // Motijheel
      const LatLng(23.7380, 90.4000), // Press Club area
      const LatLng(23.7460, 90.3950), // Shahbag
      const LatLng(23.7500, 90.3930), // Kawran Bazar
      const LatLng(23.7570, 90.3900), // Farmgate
      const LatLng(23.7800, 90.3800), // Agargaon
      const LatLng(23.8050, 90.3700), // Mirpur 10 approach
      const LatLng(23.8223, 90.3654), // Mirpur
    ];

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
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Standard App Bar alternative matching profile header styling
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.md,
              ),
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
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                children: [
                  // Map Card
                  Container(
                    height: 250,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F1F5),
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GoogleMap(
                      mapType: MapType.normal,
                      buildingsEnabled: false,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(23.7770, 90.3860),
                        zoom: 11.5,
                      ),
                      zoomGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      myLocationEnabled: false,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('bus_route'),
                          points: routePoints,
                          width: 4,
                          color: colorScheme.primary,
                        ),
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('start'),
                          position: routePoints.first,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                        ),
                        Marker(
                          markerId: const MarkerId('end'),
                          position: routePoints.last,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                        ),
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Cards Row
                  Row(
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
                  const SizedBox(height: AppSpacing.lg),

                  // Community Feed Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community Feed',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => _showCommunityFeedModal(context),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Mock Review Card
                  const _ReviewCard(
                    name: 'Sarah J.',
                    time: '15 mins ago',
                    rating: 5,
                    text: 'Clean bus, driver was very helpful when I asked about connections.',
                  ),
                  
                  // Mock Review Card
                  // (Review card replaced by _ReviewCard)
                  const SizedBox(height: AppSpacing.lg),

                  // Crowd Level Card
                  Card(
                    elevation: 0,
                    color: const Color(0xFFF0F1F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                  const SizedBox(height: AppSpacing.lg),

                  // Stoppage Points List (Dropdown / ExpansionTile)
                  Card(
                    elevation: 0,
                    color: const Color(0xFFF0F1F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
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
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommunityFeedModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community Feed',
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                    children: const [
                      _ReviewCard(
                        name: 'Sarah J.',
                        time: '15 mins ago',
                        rating: 5,
                        text: 'Clean bus, driver was very helpful when I asked about connections.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _ReviewCard(
                        name: 'Rahim U.',
                        time: '2 hours ago',
                        rating: 4,
                        text: 'A bit crowded today but reached on time.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _ReviewCard(
                        name: 'Aisha K.',
                        time: '1 day ago',
                        rating: 5,
                        text: 'Felt very safe during the evening commute. Good lighting inside.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _ReviewCard(
                        name: 'Mehedi H.',
                        time: '2 days ago',
                        rating: 3,
                        text: 'Bus was delayed by 10 minutes due to traffic at Farmgate.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _ReviewCard(
                        name: 'Nusrat F.',
                        time: '3 days ago',
                        rating: 5,
                        text: 'Extremely comfortable seats and AC was working perfectly.',
                      ),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
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
      elevation: 0,
      color: const Color(0xFFF0F1F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.4),
          width: 1.5,
        ),
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

class _ReviewCard extends StatelessWidget {
  final String name;
  final String time;
  final int rating;
  final String text;

  const _ReviewCard({
    required this.name,
    required this.time,
    required this.rating,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: const Color(0xFFF0F1F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.4),
          width: 1.5,
        ),
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
                      Text(name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(time, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    text,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
