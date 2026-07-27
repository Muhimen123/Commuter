import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

class RideFilterChips extends StatelessWidget {
  const RideFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            _FilterChip(
              label: 'Nearby',
              icon: Icons.near_me,
              isSelected: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Highly Rated',
              icon: Icons.group,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Safest Routes',
              icon: Icons.security,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Lowest Fare',
              icon: Icons.payments,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.secondaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
