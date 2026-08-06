import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/osrm_repository.dart';
import '../../data/photon_repository.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';
import '../widgets/active_ride_panel.dart';
import '../widgets/add_stop_confirmation_dialog.dart';
import '../widgets/map_search_field.dart';
import '../widgets/start_journey_fab.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

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
              onChanged: _onSearchChanged,
              onClear: _clearRoute,
              hasRoute: _hasRoute,
              suggestions: _suggestions,
              onSuggestionSelected: _selectSuggestion,
              isLoading: _isLoadingSuggestions,
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
