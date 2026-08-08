import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/osrm_repository.dart';
import '../../data/photon_repository.dart';
import '../widgets/safety_map_button.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';
import '../widgets/active_ride_panel.dart';
import '../widgets/add_stop_confirmation_dialog.dart';
import '../widgets/map_search_field.dart';
import '../widgets/start_journey_fab.dart';

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
  bool _isStartingJourney = false;
  bool _journeyStarted = false;
  List<LatLng> _routePoints = [];

  bool _heatmapEnabled = false;

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLat != oldWidget.initialLat || widget.initialLon != oldWidget.initialLon) {
      if (widget.initialLat != null && widget.initialLon != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.move(LatLng(widget.initialLat!, widget.initialLon!), 16.0);
          if (widget.sharedPersonName != null && mounted) {
            CommuterToast.show(
              context,
              message: 'Viewing ${widget.sharedPersonName}\'s live location',
              icon: Icons.person_pin_circle_rounded,
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
          CommuterToast.show(
            context,
            message: 'Viewing ${widget.sharedPersonName}\'s live location',
            icon: Icons.person_pin_circle_rounded,
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
      _isStartingJourney = false;
      _journeyStarted = false;
    });
    _centerMapOnUser();
  }

  Future<void> _startJourney() async {
    if (_isStartingJourney) return;
    if (_journeyStarted) {
      _showAddStopDialog();
      return;
    }
    setState(() {
      _isStartingJourney = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isStartingJourney = false;
        _journeyStarted = true;
      });
      CommuterToast.show(
        context,
        message: 'Journey started! Live tracking active.',
        icon: Icons.navigation_rounded,
      );
    }
  }

  void _endJourney() {
    CommuterToast.show(
      context,
      message: 'Journey ended. Thanks for contributing!',
      icon: Icons.check_circle_rounded,
    );
    _clearRoute();
  }

  void _showAddStopDialog() {
    final center = controller.camera.center;
    showDialog(
      context: context,
      builder: (context) => AddStopConfirmationDialog(
        center: center,
        onAddStop: () {
          CommuterToast.show(
            context,
            message: 'Stop added to journey!',
            icon: Icons.check_circle,
          );
        },
      ),
    );
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
      resizeToAvoidBottomInset: false,
      floatingActionButton: _journeyStarted
          ? null
          : StartJourneyFab(
              hasRoute: _hasRoute,
              isStartingJourney: _isStartingJourney,
              journeyStarted: _journeyStarted,
              onPressed: _startJourney,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              CurrentLocationLayer(),

              if (widget.sharedPersonName != null && widget.initialLat != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.initialLat!, widget.initialLon!),
                      width: 120,
                      height: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.sharedPersonName!,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
            bottom: _journeyStarted ? 150 : 32,
            left: 16,
            child: SafetyMapButton(
              isEnabled: _heatmapEnabled,
              onTap: () {
                setState(() {
                  _heatmapEnabled = !_heatmapEnabled;
                });
              },
            ),
          ),
          if (_journeyStarted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ActiveRidePanel(
                onAddStop: _showAddStopDialog,
                onEndJourney: _endJourney,
              ),
            ),
        ],
      ),
    );
  }
}
