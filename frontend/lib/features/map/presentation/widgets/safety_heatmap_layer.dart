import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../domain/entities/safety_point.dart';
// NOTE: adjust this import if `SafetyColors` actually lives in
// `core/theme/design_tokens.dart` instead — AGENTS.md flags a duplicate
// AppColors class between the two theme files.
import '../../../../core/theme/app_theme.dart';

/// Weather-radar-style safety heatmap layer for [FlutterMap].
///
/// Renders each [SafetyPoint] as a stack of soft, layered rings
/// (red -> amber -> green, driven by [SafetyPoint.score]) and blurs the
/// whole thing so overlapping points melt into smooth blobs instead of
/// showing up as discrete circles — the AccuWeather look.
///
/// Built on flutter_map's public `CircleLayer`/`CircleMarker` API (stable
/// across versions) rather than hand-rolled canvas projection, so it keeps
/// working if flutter_map's internal camera APIs change.
class SafetyHeatmapLayer extends StatelessWidget {
  final List<SafetyPoint> points;

  const SafetyHeatmapLayer({super.key, required this.points});

  // Rings drawn outer -> inner, faintest -> most saturated.
  static const _ringFractions = [1.0, 0.72, 0.46, 0.22];
  static const _ringAlphas = [0.03, 0.07, 0.12, 0.20];
  static const _baseRadiusMeters = 260.0;

  Color _colorForScore(BuildContext context, double score) {
    final safety = Theme.of(context).extension<SafetyColors>();
    final danger = safety?.danger ?? const Color(0xFFFF5252);
    final warning = safety?.warning ?? const Color(0xFFFFB300);
    final safe = safety?.safe ?? const Color(0xFF2ECC71);

    // The design-token safety colors are intentionally muted for UI chrome
    // (buttons, badges). A heatmap needs to pop over map tiles, so boost
    // saturation here specifically. For red zones (danger), we boost
    // saturation significantly so they remain distinct even at low opacity.
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

    if (score <= 0.5) {
      return Color.lerp(vDanger, vWarning, score / 0.5)!;
    }
    return Color.lerp(vWarning, vSafe, (score - 0.5) / 0.5)!;
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final circles = <CircleMarker>[];
    // Paint all outer (faint) rings first, then progressively inner/denser
    // rings on top, across ALL points — this is what makes nearby points of
    // similar severity blend into one intensity blob rather than reading
    // as a pile of separate dots.
    for (var ring = 0; ring < _ringFractions.length; ring++) {
      for (final point in points) {
        circles.add(
          CircleMarker(
            point: point.position,
            radius: _baseRadiusMeters * _ringFractions[ring],
            useRadiusInMeter: true,
            color: _colorForScore(context, point.score).withValues(alpha: _ringAlphas[ring]),
            borderStrokeWidth: 0,
          ),
        );
      }
    }

    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: CircleLayer(circles: circles),
      ),
    );
  }
}
