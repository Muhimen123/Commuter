import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/profile_entity.dart';

class FareSpentByRouteCard extends StatelessWidget {
  final List<RouteSpend> spendByRoute;

  const FareSpentByRouteCard({super.key, required this.spendByRoute});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxSpend = spendByRoute.isNotEmpty
        ? spendByRoute.map((e) => e.totalSpend).reduce(math.max)
        : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fare Spent by Route (Top 5)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...spendByRoute.map((route) {
            final double ratio = maxSpend > 0 ? (route.totalSpend / maxSpend).clamp(0.05, 1.0) : 0.05;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      route.routeName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppRadius.small),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 32,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '৳${route.totalSpend.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
