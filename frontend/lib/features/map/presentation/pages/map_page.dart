import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController controller;

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
      controller.move(LatLng(position.latitude, position.longitude), 15);
    } catch (e) {
      debugPrint('Error getting current position: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      body: FlutterMap(
        mapController: controller,
        options: const MapOptions(
          initialCenter: LatLng(47.4358055, 8.4737324),
          initialZoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.commuter.frontend',
          ),
          CurrentLocationLayer(),
        ],
      ),
    );
  }
}
