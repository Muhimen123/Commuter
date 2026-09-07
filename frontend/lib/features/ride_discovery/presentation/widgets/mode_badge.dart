import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

class ModeBadge extends StatelessWidget {
  final TransitMode mode;
  final String? lineCode;
  final String? lineColor;

  const ModeBadge({
    super.key,
    required this.mode,
    this.lineCode,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tint = _parseColor(lineColor) ?? colorScheme.onSurfaceVariant;
    // final label = lineCode == null ? _modeLabel(mode) : '${_modeLabel(mode)}';
    final label =  _modeLabel(mode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: tint.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_modeIcon(mode), size: 14, color: tint),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  static IconData _modeIcon(TransitMode mode) => switch (mode) {
        TransitMode.bus => Icons.directions_bus,
        TransitMode.metro => Icons.tram,
        TransitMode.train => Icons.train,
      };

  static String _modeLabel(TransitMode mode) => switch (mode) {
        TransitMode.bus => 'Bus',
        TransitMode.metro => 'Metro',
        TransitMode.train => 'Train',
      };

  static Color? _parseColor(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return null;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }
}
