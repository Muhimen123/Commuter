import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/directions_repository.dart';
import '../../data/places_repository.dart';
import '../../data/mock_safety_heatmap_repository.dart';
import '../../domain/entities/safety_point.dart';
import '../widgets/safety_map_button.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';
import '../widgets/active_ride_panel.dart';
import '../widgets/add_stop_confirmation_dialog.dart';
import '../widgets/map_search_field.dart';
import '../widgets/ride_survey_dialog.dart';
import '../widgets/safety_heatmap_layer.dart';
import '../widgets/safety_heatmap_legend.dart';
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
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  final PlacesRepository _placesRepository = PlacesRepository();
  final DirectionsRepository _directionsRepository = DirectionsRepository();
  final SafetyHeatmapRepository _safetyHeatmapRepository = MockSafetyHeatmapRepository();

  Timer? _debounceTimer;
  List<LocationSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _hasRoute = false;
  bool _isStartingJourney = false;
  bool _journeyStarted = false;
  List<LatLng> _routePoints = [];

  bool _heatmapEnabled = false;
  bool _isLoadingSafetyPoints = false;
  List<SafetyPoint> _safetyPoints = [];

  // Camera tracking — needed because GoogleMapController doesn't expose center synchronously.
  LatLng _lastCameraCenter = const LatLng(23.8103, 90.4125);
  int _markerIdCounter = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialLat != null && widget.initialLon != null) {
      _lastCameraCenter = LatLng(widget.initialLat!, widget.initialLon!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLat != null && widget.initialLon != null) {
        _animateTo(LatLng(widget.initialLat!, widget.initialLon!), 16.0);
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

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLat != oldWidget.initialLat ||
        widget.initialLon != oldWidget.initialLon) {
      if (widget.initialLat != null && widget.initialLon != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animateTo(LatLng(widget.initialLat!, widget.initialLon!), 16.0);
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

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;

    // If we had initial coords queued before the map was ready, move now.
    if (widget.initialLat != null && widget.initialLon != null) {
      await _animateTo(LatLng(widget.initialLat!, widget.initialLon!), 16.0);
    }
  }

  Future<void> _animateTo(LatLng target, double zoom) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  Future<void> _centerMapOnUser() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _animateTo(
        LatLng(position.latitude, position.longitude),
        17,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
    }
  }

  void _onCameraMove(CameraPosition position) {
    _lastCameraCenter = position.target;
  }

  Future<void> _toggleHeatmap() async {
    final turningOn = !_heatmapEnabled;
    setState(() => _heatmapEnabled = turningOn);

    if (!turningOn || _safetyPoints.isNotEmpty || _isLoadingSafetyPoints) return;

    setState(() => _isLoadingSafetyPoints = true);

    final center = widget.initialLat != null && widget.initialLon != null
        ? LatLng(widget.initialLat!, widget.initialLon!)
        : _lastCameraCenter;

    final points = await _safetyHeatmapRepository.getSafetyPoints(center: center);

    if (mounted) {
      setState(() {
        _safetyPoints = points;
        _isLoadingSafetyPoints = false;
      });
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
      final results = await _placesRepository.fetchSuggestions(
        query,
        center: _lastCameraCenter,
      );
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
    final origin = _lastCameraCenter;

    setState(() {
      _hasRoute = true;
      _routePoints = [origin, dest];
    });

    await _animateTo(dest, 15.0);
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    final points = await _directionsRepository.fetchRoute(origin, dest);
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

    final center = _lastCameraCenter;
    final dest = LatLng(center.latitude + 0.008, center.longitude + 0.008);

    setState(() {
      _hasRoute = true;
      _routePoints = [center, dest];
    });

    await _animateTo(
      LatLng(
        (center.latitude + dest.latitude) / 2,
        (center.longitude + dest.longitude) / 2,
      ),
      14.5,
    );
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    final points = await _directionsRepository.fetchRoute(center, dest);
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
    showDialog(
      context: context,
      builder: (context) => RideSurveyDialog(
        onSubmitted: (fare, rating, safetyRating, isStudentFare, feedback) {
          final studentTag = isStudentFare ? ' (Student)' : '';
          CommuterToast.show(
            context,
            message: 'Journey ended. ৳$fare$studentTag | $rating★ | $safetyRating',
            icon: Icons.check_circle_rounded,
          );
          _clearRoute();
        },
      ),
    );
  }

  void _showAddStopDialog() {
    final center = _lastCameraCenter;
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

  /// Builds the shared-location marker for a person's live location.
  Set<Marker> _buildSharedLocationMarker() {
    if (widget.sharedPersonName == null ||
        widget.initialLat == null ||
        widget.initialLon == null) {
      return const {};
    }

    final id = _nextMarkerId('shared');

    return {
      Marker(
        markerId: MarkerId(id),
        position: LatLng(widget.initialLat!, widget.initialLon!),
        infoWindow: InfoWindow(title: widget.sharedPersonName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    };
  }

  /// Builds the route polyline and destination marker.
  Set<Polyline> _buildRoutePolylines() {
    if (!_hasRoute || _routePoints.isEmpty) return const {};

    final colorScheme = Theme.of(context).colorScheme;

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: colorScheme.primary,
        width: 5,
      ),
    };
  }

  Set<Marker> _buildRouteMarkers() {
    if (!_hasRoute || _routePoints.isEmpty) return const {};

    return {
      Marker(
        markerId: const MarkerId('destination'),
        position: _routePoints.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  String _nextMarkerId(String prefix) {
    _markerIdCounter++;
    return '$prefix$_markerIdCounter';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final safetyButtonBottom = _journeyStarted ? 150.0 : 32.0;

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
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.initialLat != null
                  ? LatLng(widget.initialLat!, widget.initialLon!)
                  : const LatLng(23.8103, 90.4125),
              zoom: 17.0,
            ),
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            markers: {
              ..._buildSharedLocationMarker(),
              ..._buildRouteMarkers(),
            },
            polylines: _buildRoutePolylines(),
            heatmaps: SafetyHeatmapBuilder.build(
              context: context,
              points: _heatmapEnabled ? _safetyPoints : const [],
            ),
          ),

          // Safety heatmap loading indicator (overlay, not on map).
          if (_isLoadingSafetyPoints)
            Positioned(
              top: topPadding + 80,
              left: 16,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
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
            bottom: safetyButtonBottom,
            left: 16,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SafetyMapButton(
                  isEnabled: _heatmapEnabled,
                  onTap: _toggleHeatmap,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: safetyButtonBottom + 4,
            left: 72,
            child: IgnorePointer(
              ignoring: !_heatmapEnabled,
              child: AnimatedOpacity(
                opacity: _heatmapEnabled ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: const SafetyHeatmapLegend(),
              ),
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