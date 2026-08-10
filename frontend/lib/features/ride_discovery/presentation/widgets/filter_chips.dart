import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';

class RideFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const RideFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

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
              isSelected: selectedFilter == 'Nearby',
              onTap: () => onFilterSelected('Nearby'),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Highly Rated',
              icon: Icons.group,
              isSelected: selectedFilter == 'Highly Rated',
              onTap: () => onFilterSelected('Highly Rated'),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Safest Routes',
              icon: Icons.security,
              isSelected: selectedFilter == 'Safest Routes',
              onTap: () => onFilterSelected('Safest Routes'),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Lowest Fare',
              icon: Icons.payments,
              isSelected: selectedFilter == 'Lowest Fare',
              onTap: () => onFilterSelected('Lowest Fare'),
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
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
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
      ),
    );
  }
}
