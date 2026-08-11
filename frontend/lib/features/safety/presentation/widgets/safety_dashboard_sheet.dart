import 'package:flutter/material.dart';
import 'transit_alert_card.dart';
import 'sharing_section.dart';
import 'survey_history_section.dart';
import 'package:frontend/shared/widgets/glass_container.dart';

class SafetyDashboardSheet extends StatelessWidget {
  final double maxChildSize;

  const SafetyDashboardSheet({
    super.key,
    required this.maxChildSize,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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

              const TransitAlertCard(),
              const SizedBox(height: 24),

              const SharingSection(),
              const SizedBox(height: 24),

              const SurveyHistorySection(),
              
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
