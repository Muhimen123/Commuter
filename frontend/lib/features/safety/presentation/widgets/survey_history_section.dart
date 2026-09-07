import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/safety/data/repositories/supabase_incident_report_repository.dart';
import 'package:frontend/features/safety/domain/entities/incident_report.dart';

const List<String> _kMonthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime date) {
  final local = date.toLocal();
  return '${_kMonthAbbreviations[local.month - 1]} ${local.day}';
}

class SurveyHistorySection extends ConsumerWidget {
  const SurveyHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(incidentReportHistoryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Safety Survey History',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (historyAsync.valueOrNull case final reports? when reports.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllSurveys(context, reports),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Couldn\'t load your survey history.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(incidentReportHistoryProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (reports) {
              if (reports.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No surveys submitted yet. Use "Area Survey" to report on a location.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }
              final preview = reports.take(2).toList();
              return Column(
                children: [
                  for (var i = 0; i < preview.length; i++) ...[
                    if (i > 0) const Divider(height: 32),
                    _buildSurveyItem(context, preview[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAllSurveys(BuildContext context, List<IncidentReport> reports) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Safety Surveys'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: reports.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) => _buildSurveyItem(context, reports[index]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyItem(BuildContext context, IncidentReport report) {
    final title = (report.locationText?.trim().isNotEmpty ?? false)
        ? report.locationText!.trim()
        : 'Unnamed location';
    final subtitle = _formatDate(report.createdAt);

    final safetyColors = Theme.of(context).extension<SafetyColors>();
    final String status;
    final Color badgeColor;
    if (report.overallSafetyRating >= 4) {
      status = 'Felt Safe';
      badgeColor = safetyColors?.safe ?? Colors.green;
    } else if (report.overallSafetyRating == 3) {
      status = 'Neutral';
      badgeColor = safetyColors?.warning ?? Colors.orange;
    } else {
      status = 'Felt Unsafe';
      badgeColor = safetyColors?.danger ?? Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
          ),
        ),
      ],
    );
  }
}
