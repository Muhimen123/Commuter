import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/features/safety/presentation/widgets/safety_heatmap_toggle.dart';
import 'package:frontend/core/theme/app_colors.dart';
import '../../data/osrm_repository.dart';
import '../../data/photon_repository.dart';
import '../widgets/map_search_field.dart';

class MapPage extends StatefulWidget {
  final String title;
  final double? initialLat;
  final double? initialLon;
  final String? sharedPersonName;

  const MapPage({
    super.key, 
    required this.title,
    this.initialLat,
    this.initialLon,
    this.sharedPersonName,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController controller;
  final TextEditingController _searchController = TextEditingController();
  final PhotonRepository _photonRepository = PhotonRepository();
  final OsrmRepository _osrmRepository = OsrmRepository();
  
  Timer? _debounceTimer;
  List<LocationSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _hasRoute = false;
  List<LatLng> _routePoints = [];

  bool _heatmapEnabled = false;
  List<CircleMarker> _radarCircles = [];

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we receive new tracking coordinates via navigation
    if (widget.initialLat != oldWidget.initialLat || widget.initialLon != oldWidget.initialLon) {
      if (widget.initialLat != null && widget.initialLon != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.move(LatLng(widget.initialLat!, widget.initialLon!), 16.0);
          if (widget.sharedPersonName != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${widget.sharedPersonName}\'s live location'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = MapController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLat != null && widget.initialLon != null) {
        controller.move(LatLng(widget.initialLat!, widget.initialLon!), 16.0);
        if (widget.sharedPersonName != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing ${widget.sharedPersonName}\'s live location'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _centerMapOnUser();
      }
    });
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

  // Generate an AccuWeather-style "radar" effect using nested circles
  void _generateRadarEffect(LatLng center) {
    setState(() {
      _radarCircles = [];
      
      // Create several "storm" blobs around the center
      final blobs = [
        LatLng(center.latitude + 0.005, center.longitude - 0.004),
        LatLng(center.latitude - 0.003, center.longitude + 0.006),
        LatLng(center.latitude + 0.002, center.longitude + 0.002),
        LatLng(center.latitude - 0.006, center.longitude - 0.003),
      ];

      for (var blob in blobs) {
        // AccuWeather style: Multi-layered transparent circles for soft gradient
        
        // Layer 0: Super-soft outer green glow
        _radarCircles.add(CircleMarker(
          point: blob,
          radius: 1800,
          useRadiusInMeter: true,
          color: Colors.green.withValues(alpha: 0.05),
          borderStrokeWidth: 0,
        ));

        // Layer 1: Soft green
        _radarCircles.add(CircleMarker(
          point: blob,
          radius: 1200,
          useRadiusInMeter: true,
          color: Colors.green.withValues(alpha: 0.15),
          borderStrokeWidth: 0,
        ));
        
        // Layer 2: Transition green-yellow
        _radarCircles.add(CircleMarker(
          point: blob,
          radius: 800,
          useRadiusInMeter: true,
          color: Colors.lightGreen.withValues(alpha: 0.25),
          borderStrokeWidth: 0,
        ));

        // Layer 3: Warning Orange
        _radarCircles.add(CircleMarker(
          point: blob,
          radius: 500,
          useRadiusInMeter: true,
          color: Colors.orange.withValues(alpha: 0.35),
          borderStrokeWidth: 0,
        ));

        // Layer 4: Danger Red core
        _radarCircles.add(CircleMarker(
          point: blob,
          radius: 250,
          useRadiusInMeter: true,
          color: Colors.red.withValues(alpha: 0.45),
          borderStrokeWidth: 0,
        ));

        // Layer 5: Intense Red/White peak
        _radarCircles.add(CircleMarker(
          point: blob,
          radius: 120,
          useRadiusInMeter: true,
          color: Colors.redAccent.withValues(alpha: 0.6),
          borderStrokeWidth: 0,
        ));
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final results = await _photonRepository.fetchSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoadingSuggestions = false;
        });
      }
    });
  }

  Future<void> _selectSuggestion(LocationSuggestion suggestion) async {
    _debounceTimer?.cancel();
    _searchController.text = suggestion.name;
    setState(() {
      _suggestions = [];
      _isLoadingSuggestions = false;
    });

    final dest = LatLng(suggestion.lat, suggestion.lon);
    final center = controller.camera.center;

    setState(() {
      _hasRoute = true;
      _routePoints = [center, dest];
    });

    controller.move(dest, 15.0);
    FocusScope.of(context).unfocus();

    final points = await _osrmRepository.fetchRoute(center, dest);
    if (mounted && _hasRoute) {
      setState(() {
        _routePoints = points;
      });
    }
  }

  Future<void> _searchAndDraftRoute(String query) async {
    if (query.trim().isEmpty) return;
    _debounceTimer?.cancel();
    setState(() {
      _suggestions = [];
      _isLoadingSuggestions = false;
    });
    
    final center = controller.camera.center;
    final dest = LatLng(center.latitude + 0.008, center.longitude + 0.008);

    setState(() {
      _hasRoute = true;
      _routePoints = [center, dest];
    });

    controller.move(LatLng((center.latitude + dest.latitude) / 2, (center.longitude + dest.longitude) / 2), 14.5);
    FocusScope.of(context).unfocus();

    final points = await _osrmRepository.fetchRoute(center, dest);
    if (mounted && _hasRoute) {
      setState(() {
        _routePoints = points;
      });
    }
  }

  void _clearRoute() {
    _debounceTimer?.cancel();
    setState(() {
      _hasRoute = false;
      _routePoints = [];
      _suggestions = [];
      _isLoadingSuggestions = false;
      _searchController.clear();
    });
    _centerMapOnUser();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
            options: MapOptions(
              initialCenter: widget.initialLat != null 
                  ? LatLng(widget.initialLat!, widget.initialLon!) 
                  : const LatLng(47.4358, 8.4737),
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.commuter.frontend',
              ),
              if (_heatmapEnabled)
                CircleLayer(
                  circles: _radarCircles,
                ),
              CurrentLocationLayer(),
              
              // If viewing someone else's location, show their marker
              if (widget.sharedPersonName != null && widget.initialLat != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.initialLat!, widget.initialLon!),
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.sharedPersonName!,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.location_on, color: colorScheme.primary, size: 30),
                        ],
                      ),
                    ),
                  ],
                ),

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
              onChanged: _onSearchChanged,
              onClear: _clearRoute,
              hasRoute: _hasRoute,
              suggestions: _suggestions,
              onSuggestionSelected: _selectSuggestion,
              isLoading: _isLoadingSuggestions,
            ),
          ),
          Positioned(
            top: topPadding + 84,
            left: 16,
            right: 16,
            child: SafetyHeatmapToggle(
              isEnabled: _heatmapEnabled,
              onChanged: (val) {
                setState(() {
                  _heatmapEnabled = val;
                  if (_heatmapEnabled) {
                    _generateRadarEffect(controller.camera.center);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
