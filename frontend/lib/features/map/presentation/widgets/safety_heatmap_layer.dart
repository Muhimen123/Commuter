import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/safety_point.dart';
import '../../../../core/theme/app_theme.dart';

/// Builds a [Set<Heatmap>] for Google Maps from safety data points.
///
/// Maps [SafetyPoint.score] (0.0 = risky, 1.0 = safe) to a gradient
/// of danger → warning → safe, where risky areas appear as hot spots.
class SafetyHeatmapBuilder {
  SafetyHeatmapBuilder._(); // utility class

  static const _heatmapId = HeatmapId('safety_heatmap');

  /// Platform-appropriate radius in pixels (max 50 on both platforms).
  static HeatmapRadius _radiusForPlatform() {
    if (kIsWeb) return const HeatmapRadius.fromPixels(10);
    return const HeatmapRadius.fromPixels(50);
  }

  /// Builds a heatmap set for Google Maps.
  ///
  /// Returns an empty set when [points] is empty so the heatmap is removed.
  static Set<Heatmap> build({
    required BuildContext context,
    required List<SafetyPoint> points,
  }) {
    debugPrint('SafetyHeatmapBuilder: building with ${points.length} points');
    if (points.isEmpty) return {};

    final safety = Theme.of(context).extension<SafetyColors>();
    final danger = safety?.danger ?? const Color(0xFFFF5252);
    final warning = safety?.warning ?? const Color(0xFFFFB300);
    final safe = safety?.safe ?? const Color(0xFF2ECC71);

    // Boost saturation for heatmap visibility over map tiles.
    Color vivid(Color base, {double satBoost = 0.25, double lightAdjust = 0.0}) {
      final hsl = HSLColor.fromColor(base);
      return hsl
          .withSaturation((hsl.saturation + satBoost).clamp(0.0, 1.0))
          .withLightness((hsl.lightness + lightAdjust).clamp(0.0, 1.0))
          .toColor();
    }

    final vDanger = vivid(danger, satBoost: 0.60, lightAdjust: -0.05);
    final vWarning = vivid(warning, satBoost: 0.25);
    final vSafe = vivid(safe, satBoost: 0.25, lightAdjust: -0.04);

    // Gradient: transparent → safe (green) → warning (amber) → danger (red).
    // The first color is fully transparent so the heatmap fades out at the edges
    // of the data extent instead of showing a hard square border.
    final gradient = HeatmapGradient([
      HeatmapGradientColor(vSafe.withAlpha(0), 0.0),  // transparent edge fade
      HeatmapGradientColor(vSafe, 0.3),               // safe → green
      HeatmapGradientColor(vWarning, 0.6),             // warning → amber
      HeatmapGradientColor(vDanger, 1.0),              // risky → red
    ]);

    // Weight = inverse of score: risky areas (score ~0) get high weight.
    final data = points.map((p) {
      return WeightedLatLng(
        LatLng(p.latitude, p.longitude),
        weight: 1.0 - p.score,
      );
    }).toList();

    debugPrint('SafetyHeatmapBuilder: created Heatmap with ${data.length} weighted points');
    final minW = data.map((w) => w.weight).reduce((a, b) => a < b ? a : b);
    final maxW = data.map((w) => w.weight).reduce((a, b) => a > b ? a : b);
    debugPrint('SafetyHeatmapBuilder: weights range: [$minW .. $maxW]');

    return {
      Heatmap(
        heatmapId: _heatmapId,
        data: data,
        gradient: gradient,
        maxIntensity: 1,
        opacity: 0.7,
        radius: _radiusForPlatform(),
        dissipating: true,
      ),
    };
  }
}