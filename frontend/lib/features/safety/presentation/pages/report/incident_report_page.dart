import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/theme/app_colors.dart';

class _RatingCategory {
  final IconData icon;
  final String label;
  final String lowHint;
  final String highHint;
  const _RatingCategory(this.icon, this.label, this.lowHint, this.highHint);
}

const List<_RatingCategory> _kRatingCategories = [
  _RatingCategory(
    Icons.lightbulb_outline_rounded,
    'Lighting',
    'Poorly lit',
    'Very well lit',
  ),
  _RatingCategory(
    Icons.visibility_outlined,
    'Public Visibility',
    'Hidden / blocked view',
    'Open & visible',
  ),
  _RatingCategory(
    Icons.groups_outlined,
    'Crowd Density',
    'Empty / deserted',
    'Very crowded',
  ),
  _RatingCategory(
    Icons.local_police_outlined,
    'Police/Security Presence',
    'Rarely seen',
    'Frequently seen',
  ),
  _RatingCategory(
    Icons.report_outlined,
    'Harassment Frequency',
    'Rarely happens',
    'Happens often',
  ),
  _RatingCategory(
    Icons.shopping_bag_outlined,
    'Theft/Snatching Frequency',
    'Rarely happens',
    'Happens often',
  ),
  _RatingCategory(
    Icons.sentiment_satisfied_alt_outlined,
    'Overall Feeling of Safety',
    'Feels unsafe',
    'Feels very safe',
  ),
];

const List<String> _kLevelLabels = ['Very Low', 'Low', 'Moderate', 'High', 'Very High'];

const List<Color> _kGradientColors = [
  Color(0xFF3FC46D),
  Color(0xFFF5B942),
  Color(0xFFE9564C),
];

Color _colorForLevel(num value) {
  final t = ((value - 1) / 4).clamp(0.0, 1.0);
  if (t <= 0.5) {
    return Color.lerp(_kGradientColors[0], _kGradientColors[1], t / 0.5)!;
  }
  return Color.lerp(_kGradientColors[1], _kGradientColors[2], (t - 0.5) / 0.5)!;
}

class _MetricSliderRow extends StatefulWidget {
  final _RatingCategory category;
  final int value;
  final ValueChanged<int> onChanged;

  const _MetricSliderRow({
    required this.category,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_MetricSliderRow> createState() => _MetricSliderRowState();
}

class _MetricSliderRowState extends State<_MetricSliderRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late double _displayValue = widget.value.toDouble();
  bool _isDragging = false;

  @override
  void didUpdateWidget(covariant _MetricSliderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && !_snapController.isAnimating && widget.value != oldWidget.value) {
      _displayValue = widget.value.toDouble();
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _glideTo(double target) {
    final animation = Tween<double>(begin: _displayValue, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    void listener() => setState(() => _displayValue = animation.value);
    animation.addListener(listener);
    _snapController
      ..reset()
      ..forward().whenCompleteOrCancel(() => animation.removeListener(listener));
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForLevel(_displayValue);
    final levelLabel = _kLevelLabels[_displayValue.round().clamp(1, 5) - 1];

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
                child: Text(levelLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: _kGradientColors),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
                  thumbColor: color,
                ),
                child: Slider(
                  value: _displayValue,
                  min: 1,
                  max: 5,
                  onChangeStart: (_) {
                    _snapController.stop();
                    _isDragging = true;
                  },
                  onChanged: (v) => setState(() => _displayValue = v),
                  onChangeEnd: (v) {
                    _isDragging = false;
                    final rounded = v.round().clamp(1, 5);
                    widget.onChanged(rounded);
                    _glideTo(rounded.toDouble());
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.category.lowHint,
                style: TextStyle(fontSize: 11, color: AppColors.text.withValues(alpha: 0.55)),
              ),
              Text(
                widget.category.highHint,
                style: TextStyle(fontSize: 11, color: AppColors.text.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubmissionSuccessDialog extends StatelessWidget {
  const _SubmissionSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF3FC46D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ).animate().scale(
                    duration: 450.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 20),
              const Text(
                'Report Submitted',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.text,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Your report has been submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.text.withValues(alpha: 0.65)),
              ).animate().fadeIn(delay: 220.ms, duration: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ).animate().fadeIn(delay: 280.ms, duration: 300.ms),
            ],
          ),
        ),
      ),
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

  Future<void> _handleSubmit() async {
    // TODO: Persist the report to a backend once one is available.
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, _, _) => const _SubmissionSuccessDialog(),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
    if (mounted) Navigator.of(context).pop();
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
      padding: const EdgeInsets.only(bottom: 22),
      child: _MetricSliderRow(
        category: category,
        value: _ratings[category.label] ?? 3,
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
              const SizedBox(height: 4),
              Text(
                'Drag each slider toward what you actually noticed. The text under each one explains what a low or high value means.',
                style: TextStyle(fontSize: 12, color: AppColors.text.withValues(alpha: 0.6)),
              ),
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
                  onPressed: _handleSubmit,
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
