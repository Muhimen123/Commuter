import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/safety/presentation/pages/report/incident_report_page.dart';

class SafetyActionButtons extends StatelessWidget {
  const SafetyActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            icon: Icons.map_outlined,
            label: 'Area Survey',
            color: const Color(0xFFC0A94E),
            onTap: () {
              // TODO: Navigate to Area Survey page
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            context,
            icon: Icons.report_problem_outlined,
            label: 'Report Incident',
            color: AppColors.danger,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const IncidentReportPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }
}
