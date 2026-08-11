import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/glass_container.dart';

class TransitAlertCard extends StatelessWidget {
  const TransitAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
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
}
