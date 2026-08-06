import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/profile_entity.dart';

class CommuteAnalyticsSection extends StatelessWidget {
  final CommuteAnalytics analytics;

  const CommuteAnalyticsSection({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commute Analytics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FareSpentByRouteCard(spendByRoute: analytics.spendByRoute),
        const SizedBox(height: AppSpacing.sm),
        _TransitModeCard(transitModes: analytics.transitModes),
        const SizedBox(height: AppSpacing.sm),
        _RideHoursCard(rideHours: analytics.rideHoursPerWeek),
      ],
    );
  }
}

class _FareSpentByRouteCard extends StatelessWidget {
  final List<RouteSpend> spendByRoute;

  const _FareSpentByRouteCard({required this.spendByRoute});

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
        color: colorScheme.surface,
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

class _TransitModeCard extends StatelessWidget {
  final List<TransitModeShare> transitModes;

  const _TransitModeCard({required this.transitModes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final safetyColors = Theme.of(context).extension<SafetyColors>();

    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      safetyColors?.warning ?? Colors.amber,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transit Mode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...List.generate(transitModes.length, (index) {
                  final item = transitModes[index];
                  final color = colors[index % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${item.modeName} (${item.percentage}%)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(
            width: 86,
            height: 86,
            child: CustomPaint(
              painter: _DoughnutChartPainter(
                items: transitModes,
                colors: colors,
              ),
              child: Center(
                child: Icon(
                  Icons.pie_chart_outline,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _DoughnutChartPainter extends CustomPainter {
  final List<TransitModeShare> items;
  final List<Color> colors;

  _DoughnutChartPainter({required this.items, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = items.fold(0, (sum, item) => sum + item.percentage);
    if (total <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 8,
    );

    double startAngle = -math.pi / 2;

    for (int i = 0; i < items.length; i++) {
      final sweepAngle = (items[i].percentage / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle - 0.08, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RideHoursCard extends StatelessWidget {
  final List<DailyRideHours> rideHours;

  const _RideHoursCard({required this.rideHours});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxHours = rideHours.isNotEmpty
        ? rideHours.map((e) => e.hours).reduce(math.max)
        : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Hours per Week',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: rideHours.map((day) {
                final double ratio = maxHours > 0 ? (day.hours / maxHours).clamp(0.1, 1.0) : 0.1;
                final bool isHigh = day.hours > 3.0;
                final bool isMax = day.hours == maxHours;
                final barColor = isMax
                    ? colorScheme.primary
                    : isHigh
                        ? colorScheme.secondary.withValues(alpha: 0.7)
                        : colorScheme.surfaceContainerHigh;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 72 * ratio,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(AppRadius.extraSmall),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      day.dayLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
