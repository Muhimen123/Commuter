import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/theme/app_colors.dart';

class _RatingCategory {
  final IconData icon;
  final String label;
  const _RatingCategory(this.icon, this.label);
}

const List<_RatingCategory> _kRatingCategories = [
  _RatingCategory(Icons.lightbulb_outline_rounded, 'Lighting'),
  _RatingCategory(Icons.visibility_outlined, 'Public Visibility'),
  _RatingCategory(Icons.groups_outlined, 'Crowd Density'),
  _RatingCategory(Icons.local_police_outlined, 'Police/Security Presence'),
  _RatingCategory(Icons.report_outlined, 'Harassment Frequency'),
  _RatingCategory(Icons.shopping_bag_outlined, 'Theft/Snatching Frequency'),
  _RatingCategory(Icons.sentiment_satisfied_alt_outlined, 'Overall Feeling of Safety'),
];

class _StarRatingRow extends StatefulWidget {
  final _RatingCategory category;
  final int value;
  final ValueChanged<int> onChanged;

  const _StarRatingRow({
    required this.category,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_StarRatingRow> createState() => _StarRatingRowState();
}

class _StarRatingRowState extends State<_StarRatingRow>
    with TickerProviderStateMixin {
  static final TweenSequence<double> _popSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.45).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.45, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 65,
    ),
  ]);

  late final List<AnimationController> _controllers = List.generate(
    5,
    (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    ),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int starValue) {
    widget.onChanged(starValue);
    for (var i = 0; i < 5; i++) {
      if (i < starValue) {
        Future.delayed(Duration(milliseconds: i * 55), () {
          if (mounted) _controllers[i].forward(from: 0);
        });
      } else {
        _controllers[i].value = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.category.icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.category.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: widget.value > 0 ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${widget.value}/5',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) {
            final starValue = i + 1;
            final isFilled = starValue <= widget.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _handleTap(starValue),
                child: AnimatedBuilder(
                  animation: _controllers[i],
                  builder: (context, child) {
                    final scale = isFilled
                        ? _popSequence.transform(_controllers[i].value)
                        : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      key: ValueKey(isFilled),
                      size: 30,
                      color: isFilled
                          ? AppColors.warning
                          : AppColors.text.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final Map<String, int> _ratings = {};
  bool _isLocating = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final areaName = await _reverseGeocode(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _locationController.text = areaName ??
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        _isLocating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationError = 'Unable to detect location';
      });
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng&zoom=16&addressdetails=1',
      );
      final response = await http
          .get(uri, headers: {'Accept-Language': 'en'})
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) return data['display_name'] as String?;

      final area = address['suburb'] ??
          address['neighbourhood'] ??
          address['residential'] ??
          address['quarter'] ??
          address['city_district'] ??
          address['town'] ??
          address['village'];
      final city = address['city'] ?? address['county'] ?? address['state'];

      if (area != null && city != null && area != city) {
        return '$area, $city';
      }
      return (area ?? city) as String? ?? data['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        color: AppColors.text,
      ),
    );
  }

  Widget _ratingRow(_RatingCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _StarRatingRow(
        category: category,
        value: _ratings[category.label] ?? 0,
        onChanged: (value) => setState(() => _ratings[category.label] = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Report Condition',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          labelText: 'Location',
                          hintText: _isLocating
                              ? 'Detecting your location...'
                              : (_locationError ?? 'Enter location...'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: _isLocating
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: 'Use current location',
                              icon: const Icon(Icons.my_location, size: 20),
                              color: AppColors.primary,
                              onPressed: _fetchCurrentLocation,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Rate this area'),
              const SizedBox(height: 12),
              _sectionCard(
                child: Column(
                  children: _kRatingCategories.map(_ratingRow).toList(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add details (optional)...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement report submission
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
