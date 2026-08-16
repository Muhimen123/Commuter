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
  static const _radius = HeatmapRadius.fromPixels(60);

  /// Builds a heatmap set for Google Maps.
  ///
  /// Returns an empty set when [points] is empty so the heatmap is removed.
  static Set<Heatmap> build({
    required BuildContext context,
    required List<SafetyPoint> points,
  }) {
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

    // Gradient: low intensity (safe) → high intensity (danger).
    // Colors listed low-to-high with their start points.
    final gradient = HeatmapGradient([
      HeatmapGradientColor(vSafe, 0.0),
      HeatmapGradientColor(vWarning, 0.5),
      HeatmapGradientColor(vDanger, 1.0),
    ]);

    // Weight = inverse of score: risky areas (score ~0) get high weight.
    final data = points.map((p) {
      return WeightedLatLng(
        LatLng(p.latitude, p.longitude),
        weight: 1.0 - p.score,
      );
    }).toList();

    return {
      Heatmap(
        heatmapId: _heatmapId,
        data: data,
        gradient: gradient,
        opacity: 0.7,
        radius: _radius,
        dissipating: true,
      ),
    };
  }
}