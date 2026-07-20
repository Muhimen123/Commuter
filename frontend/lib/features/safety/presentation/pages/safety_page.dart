import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/safety_header.dart';
import '../widgets/safety_heatmap_toggle.dart';
import '../widgets/safety_report_button.dart';
import '../widgets/safety_dashboard_sheet.dart';

class SafetyPage extends StatefulWidget {
  const SafetyPage({super.key});

  @override
  State<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  bool _heatmapEnabled = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Header height (64) + gap (12) + topPadding
    final headerTotalHeight = topPadding + 64 + 12;
    final maxSheetHeight = (screenHeight - headerTotalHeight) / screenHeight;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // 1. Full-bleed Map (Interactive map without API key)
            Positioned.fill(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(40.7128, -74.0060),
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.commuter.app.safety_map',
                  ),
                  if (_heatmapEnabled)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: const LatLng(40.7150, -74.0080),
                          radius: 1000,
                          useRadiusInMeter: true,
                          color: AppColors.danger.withValues(alpha: 0.2),
                          borderColor: AppColors.danger.withValues(alpha: 0.5),
                          borderStrokeWidth: 2,
                        ),
                        CircleMarker(
                          point: const LatLng(40.7080, -74.0020),
                          radius: 800,
                          useRadiusInMeter: true,
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderColor: AppColors.warning.withValues(alpha: 0.5),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // 2. Safety Heatmap Toggle Overlay
            Positioned(
              top: headerTotalHeight, // Below header + gap
              left: 16,
              right: 16,
              child: SafetyHeatmapToggle(
                isEnabled: _heatmapEnabled,
                onChanged: (val) => setState(() => _heatmapEnabled = val),
              ),
            ),

            // 3. Floating Action Button (Report)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.14 + 20, // Float just above the sheet peek
              right: 16,
              child: const SafetyReportButton(),
            ),

            // 4. Draggable Bottom Sheet
            SafetyDashboardSheet(maxChildSize: maxSheetHeight),

            // 5. Custom Floating Header - Placed LAST to stay on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafetyHeader(topPadding: topPadding),
            ),
          ],
        ),
      ),
    );
  }
}
