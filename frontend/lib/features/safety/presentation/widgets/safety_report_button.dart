import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/report/incident_report_page.dart';

class SafetyReportButton extends StatelessWidget {
  const SafetyReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final safetyColors = Theme.of(context).extension<SafetyColors>();
    
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
}
