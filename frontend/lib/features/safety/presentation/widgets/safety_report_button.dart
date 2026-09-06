import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_theme.dart';

class SafetyReportButton extends StatelessWidget {
  const SafetyReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final safetyColors = Theme.of(context).extension<SafetyColors>();

    return ElevatedButton.icon(
      onPressed: () => context.push('/report'),
      icon: const Icon(Icons.report_problem_outlined, color: Colors.white),
      label: const Text('Area Survey'),
      style: ElevatedButton.styleFrom(
        backgroundColor: safetyColors?.danger ?? const Color(0xFFBA1A1A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
