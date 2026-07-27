import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/design_tokens.dart';
import '../widgets/map_search_field.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController controller;
  final TextEditingController _searchController = TextEditingController();
  bool _hasRoute = false;
  String? _destinationName;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    controller = MapController();
    _centerMapOnUser();
  }

  Future<void> _centerMapOnUser() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      controller.move(LatLng(position.latitude, position.longitude), 17);
    } catch (e) {
      debugPrint('Error getting current position: $e');
    }
  }

  void _searchAndDraftRoute(String query) {
    if (query.trim().isEmpty) return;
    
    final center = controller.camera.center;
    final dest = LatLng(center.latitude + 0.008, center.longitude + 0.008);

    setState(() {
      _destinationName = query;
      _hasRoute = true;
      _routePoints = [
        center,
        LatLng(center.latitude + 0.004, center.longitude + 0.002),
        LatLng(center.latitude + 0.006, center.longitude + 0.005),
        dest,
      ];
    });

    controller.move(LatLng((center.latitude + dest.latitude) / 2, (center.longitude + dest.longitude) / 2), 14.5);
    FocusScope.of(context).unfocus();
  }

  void _clearRoute() {
    setState(() {
      _hasRoute = false;
      _destinationName = null;
      _routePoints = [];
      _searchController.clear();
    });
    _centerMapOnUser();
  }

  @override
  void dispose() {
    controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller,
            options: const MapOptions(
              initialCenter: LatLng(47.4358055, 8.4737324),
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.commuter.frontend',
              ),
              CurrentLocationLayer(),
              if (_hasRoute && _routePoints.isNotEmpty) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: colorScheme.primary,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _routePoints.last,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_pin,
                        color: colorScheme.error,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: MapSearchField(
              controller: _searchController,
              onSubmitted: _searchAndDraftRoute,
              onClear: _clearRoute,
              hasRoute: _hasRoute,
            ),
          ),
          if (_hasRoute)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_bus, color: colorScheme.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Route to: ${_destinationName ?? "Destination"}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearRoute,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Est. Time: 24 min'),
                              Text('Fare: \$2.50 • 2 transfers'),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Starting navigation...')),
                              );
                            },
                            icon: const Icon(Icons.navigation),
                            label: const Text('Start'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
