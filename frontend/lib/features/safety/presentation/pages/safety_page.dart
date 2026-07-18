import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'report/incident_report_page.dart';

class SafetyPage extends StatefulWidget {
  const SafetyPage({super.key});

  @override
  State<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  bool _heatmapEnabled = true;

  @override
  Widget build(BuildContext context) {
    final safetyColors = Theme.of(context).extension<SafetyColors>();
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Header height (64) + padding (8) + status bar + gap (12)
    final headerTotalHeight = topPadding + 64 + 12;
    final maxSheetHeight = (screenHeight - headerTotalHeight) / screenHeight;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // 1. Full-bleed Map (Proper interactive map without API key)
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
                    // Use a unique, descriptive user agent string for OSM compliance
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

            // 3. Safety Heatmap Toggle Overlay
            Positioned(
              top: topPadding + 64 + 12, // Below header + gap
              left: 16,
              right: 16,
              child: _buildHeatmapToggle(),
            ),

            // 4. Floating Action Button (Report) - Placed before sheet to be underneath when dragged
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.4 + 20, // Float just above the sheet peek
              right: 16,
              child: _buildReportButton(safetyColors),
            ),

            // 5. Draggable Bottom Sheet
            _buildDraggableSheet(maxSheetHeight),

            // 6. Custom Floating Header - Placed LAST to stay on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
          const Spacer(),
          Text(
            'Commuter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Icon(Icons.person_outline, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Switch(
            value: _heatmapEnabled,
            onChanged: (val) => setState(() => _heatmapEnabled = val),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Safety Heatmap',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Overlay known incidents and secure zones.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(SafetyColors? safetyColors) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const IncidentReportPage()),
        );
      },
      icon: const Icon(Icons.report_problem_outlined, color: Colors.white),
      label: const Text('Report Incident'),
      style: ElevatedButton.styleFrom(
        backgroundColor: safetyColors?.danger ?? const Color(0xFFBA1A1A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildDraggableSheet(double maxChildSize) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Text(
                'Safety Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitor your journey and manage emergency contacts.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              // Transit Alert
              _buildTransitAlert(),
              const SizedBox(height: 24),

              // Sharing With Section
              _buildSharingSection(),
              const SizedBox(height: 24),

              // Safety Survey History
              _buildSurveyHistory(),
              
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransitAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4DDCA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF6D5E00)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transit Alert',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C1B17),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minor delays on the Blue Line due to signal maintenance. Areas remain secure.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF494631),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.share_location, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Sharing With',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Icon(Icons.radio_button_checked, color: Color(0xFF307082)),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactTile('Sarah Johnson', 'Active tracking', 'https://i.pravatar.cc/150?u=sarah'),
          const SizedBox(height: 12),
          _buildContactTile('Mark Roberts', 'Active tracking', 'https://i.pravatar.cc/150?u=mark', initials: 'MR'),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Add Contact'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String name, String status, String avatarUrl, {String? initials}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundImage: initials == null ? NetworkImage(avatarUrl) : null,
            child: initials != null ? Text(initials) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Safety Survey History',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSurveyItem('Evening Train Commute', 'Central Station to North Hills • Oct 24', 'Felt Safe', true),
          const Divider(height: 32),
          _buildSurveyItem('Bus Route 42', 'Downtown Loop • Oct 22', 'Neutral', false),
        ],
      ),
    );
  }

  Widget _buildSurveyItem(String title, String subtitle, String status, bool positive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: positive 
                ? Theme.of(context).colorScheme.secondaryContainer 
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: positive 
                      ? Theme.of(context).colorScheme.onSecondaryContainer 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
