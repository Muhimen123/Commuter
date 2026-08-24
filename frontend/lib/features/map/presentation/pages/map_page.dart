import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/journey/domain/journey_notifier.dart';
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
import '../widgets/bus_selection_dialog.dart';
import '../widgets/shared_location_chip.dart';
import '../widgets/my_location_button.dart';

class MapPage extends ConsumerStatefulWidget {
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
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  final PlacesRepository _placesRepository = PlacesRepository();
  final DirectionsRepository _directionsRepository = DirectionsRepository();
  final SafetyHeatmapRepository _safetyHeatmapRepository = MockSafetyHeatmapRepository();

  Timer? _debounceTimer;
  List<LocationSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _hasRoute = false;
  List<LatLng> _routePoints = [];

  // Drafted-route context captured for journey persistence.
  LatLng? _routeOrigin;
  LocationSuggestion? _selectedDestination;
  String? _routePolyline;
  double? _routeDistanceKm;

  bool _heatmapEnabled = false;
  bool _isLoadingSafetyPoints = false;
  List<SafetyPoint> _safetyPoints = [];

  // Camera tracking — needed because GoogleMapController doesn't expose center synchronously.
  LatLng _lastCameraCenter = const LatLng(23.8103, 90.4125);
  int _markerIdCounter = 0;
  bool _isViewingSharedLocation = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialLat != null && widget.initialLon != null) {
      _lastCameraCenter = LatLng(widget.initialLat!, widget.initialLon!);
    }
    _isViewingSharedLocation = widget.sharedPersonName != null;

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
      _resumeJourney();
    });
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nameChanged = widget.sharedPersonName != oldWidget.sharedPersonName;
    final coordsChanged = widget.initialLat != oldWidget.initialLat ||
        widget.initialLon != oldWidget.initialLon;

    if (nameChanged) {
      setState(() {
        _isViewingSharedLocation = widget.sharedPersonName != null;
      });
    }

    if (coordsChanged && widget.initialLat != null && widget.initialLon != null) {
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

  /// Resumes an in-progress journey from the backend and redraws its route.
  Future<void> _resumeJourney() async {
    final journey = await ref.read(journeyProvider.notifier).resume();
    if (journey == null || !mounted) return;
    if (journey.routePolyline == null) return;

    final points =
        DirectionsRepository.decodePolyline(journey.routePolyline!);
    setState(() {
      _hasRoute = true;
      _routePoints = points;
      _routeOrigin = LatLng(journey.originLatitude, journey.originLongitude);
      _routePolyline = journey.routePolyline;
      _routeDistanceKm = journey.distanceKm;
      _selectedDestination = journey.hasDestination
          ? LocationSuggestion(
              name: journey.destinationName ?? 'Destination',
              placeId: journey.destinationPlaceId,
              lat: journey.destinationLatitude!,
              lon: journey.destinationLongitude!,
            )
          : null;
    });
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

    final origin = _lastCameraCenter;
    final dest = LatLng(suggestion.lat, suggestion.lon);

    setState(() {
      _hasRoute = true;
      _routePoints = [origin, dest];
      _routeOrigin = origin;
      _selectedDestination = suggestion;
      _routePolyline = null;
      _routeDistanceKm = null;
    });

    await _animateTo(dest, 15.0);
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    final result = await _directionsRepository.fetchRoute(origin, dest);
    if (mounted && _hasRoute) {
      setState(() {
        _routePoints = result.points;
        _routePolyline = result.polyline;
        _routeDistanceKm = result.distanceKm;
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
      _routeOrigin = center;
      _selectedDestination = null;
      _routePolyline = null;
      _routeDistanceKm = null;
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

    final result = await _directionsRepository.fetchRoute(center, dest);
    if (mounted && _hasRoute) {
      setState(() {
        _routePoints = result.points;
        _routePolyline = result.polyline;
        _routeDistanceKm = result.distanceKm;
      });
    }
  }

  void _clearRoute() {
    _debounceTimer?.cancel();
    setState(() {
      _hasRoute = false;
      _routePoints = [];
      _routeOrigin = null;
      _selectedDestination = null;
      _routePolyline = null;
      _routeDistanceKm = null;
      _suggestions = [];
      _isLoadingSuggestions = false;
      _searchController.clear();
    });
    _centerMapOnUser();
  }

  Future<void> _startJourney() async {
    final notifier = ref.read(journeyProvider.notifier);
    if (ref.read(journeyProvider).isStarting) return;
    if (ref.read(journeyProvider).hasActiveJourney) {
      _showAddStopDialog();
      return;
    }

    if (!mounted) return;
    final selectedBus = await showDialog<String>(
      context: context,
      builder: (context) => const BusSelectionDialog(),
    );

    if (selectedBus == null || selectedBus.isEmpty) return;
    if (!mounted) return;

    final origin = _routeOrigin ?? _lastCameraCenter;
    final dest = _selectedDestination;

    await notifier.startJourney(
      routeId: null, // routes table not yet populated
      originLatitude: origin.latitude,
      originLongitude: origin.longitude,
      destinationName: dest?.name,
      destinationPlaceId: dest?.placeId,
      destinationLatitude: dest?.lat,
      destinationLongitude: dest?.lon,
      routePolyline: _routePolyline,
      distanceKm: _routeDistanceKm,
    );

    if (!mounted) return;
    final state = ref.read(journeyProvider);
    if (state.hasActiveJourney) {
      CommuterToast.show(
        context,
        message: 'Journey started on $selectedBus! Live tracking active.',
        icon: Icons.navigation_rounded,
      );
    } else if (state.error != null) {
      CommuterToast.show(
        context,
        message: 'Failed to start journey. Please try again.',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  void _showAddStopDialog() {
    final center = _lastCameraCenter;
    showDialog(
      context: context,
      builder: (dialogContext) => AddStopConfirmationDialog(
        center: center,
        onAddStop: () async {
          final stop = await ref.read(journeyProvider.notifier).addStop(
                stopName: null,
                latitude: center.latitude,
                longitude: center.longitude,
              );
          if (!mounted) return;
          if (stop != null) {
            CommuterToast.show(
              context,
              message: 'Stop added to journey!',
              icon: Icons.check_circle,
            );
          } else {
            CommuterToast.show(
              context,
              message: 'Failed to add stop. Please try again.',
              icon: Icons.error_outline_rounded,
            );
          }
        },
      ),
    );
  }

  void _endJourney() {
    showDialog(
      context: context,
      builder: (dialogContext) => RideSurveyDialog(
        onSkip: () async {
          final success = await ref.read(journeyProvider.notifier).endJourney();
          if (!mounted) return;
          CommuterToast.show(
            context,
            message: success
                ? 'Journey ended.'
                : 'Failed to end journey. Please try again.',
            icon: success
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
          );
          if (success) _clearRoute();
        },
        onSubmitted: (fare, rating, safetyRating, isStudentFare, feedback) async {
          final notifier = ref.read(journeyProvider.notifier);
          final surveySaved = await notifier.submitSurvey(
            fare: fare,
            rating: rating,
            safetyRating: safetyRating,
            isStudentFare: isStudentFare,
            feedback: feedback,
          );
          final journeyEnded = await notifier.endJourney();
          if (!mounted) return;
          final studentTag = isStudentFare ? ' (Student)' : '';
          CommuterToast.show(
            context,
            message: journeyEnded
                ? (surveySaved
                    ? 'Journey ended. ৳$fare$studentTag | $rating★ | $safetyRating'
                    : 'Journey ended. Survey not saved.')
                : 'Failed to end journey. Please try again.',
            icon: journeyEnded
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
          );
          if (journeyEnded) _clearRoute();
        },
      ),
    );
  }

  /// Builds the shared-location marker for a person's live location.
  Set<Marker> _buildSharedLocationMarker() {
    if (!_isViewingSharedLocation ||
        widget.initialLat == null ||
        widget.initialLon == null) {
      return const {};
    }

    final markerId = MarkerId(_nextMarkerId('shared'));

    return {
      Marker(
        markerId: markerId,
        position: LatLng(widget.initialLat!, widget.initialLon!),
        infoWindow: InfoWindow(title: widget.sharedPersonName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        consumeTapEvents: true,
        onTap: () {
          _controller?.showMarkerInfoWindow(markerId);
        },
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

    const markerId = MarkerId('destination');

    return {
      Marker(
        markerId: markerId,
        position: _routePoints.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        consumeTapEvents: true,
        onTap: () {
          _controller?.showMarkerInfoWindow(markerId);
        },
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

    final journeyState = ref.watch(journeyProvider);
    final journeyStarted = journeyState.hasActiveJourney;
    final isStartingJourney = journeyState.isStarting;
    final safetyButtonBottom = journeyStarted ? 150.0 : 32.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: journeyStarted
          ? null
          : StartJourneyFab(
              hasRoute: _hasRoute,
              isStartingJourney: isStartingJourney,
              journeyStarted: journeyStarted,
              onPressed: _startJourney,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            buildingsEnabled: false,
            zoomControlsEnabled: false,
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

          // Shared-location viewing chip (close button to return to safety).
          if (_isViewingSharedLocation)
            Positioned(
              top: topPadding + 76,
              left: 16,
              right: 16,
              child: SharedLocationChip(
                personName: widget.sharedPersonName!,
                onClose: () {
                  setState(() {
                    _isViewingSharedLocation = false;
                  });
                  _centerMapOnUser();
                },
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
          MyLocationButton(
            onPressed: _centerMapOnUser,
            bottom: safetyButtonBottom,
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
          if (journeyStarted)
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
