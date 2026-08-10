import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

class TransitIntelligenceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String valueText;
  final String labelText;

  const TransitIntelligenceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.valueText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            valueText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            labelText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
