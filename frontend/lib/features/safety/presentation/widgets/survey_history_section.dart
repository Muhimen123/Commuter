import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/glass_container.dart';

class SurveyHistorySection extends StatelessWidget {
  const SurveyHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
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
              TextButton(
                onPressed: () => _showAllSurveys(context),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSurveyItem(
            context,
            'Evening Train Commute',
            'Central Station to North Hills • Oct 24',
            'Felt Safe',
            true,
          ),
          const Divider(height: 32),
          _buildSurveyItem(
            context,
            'Bus Route 42',
            'Downtown Loop • Oct 22',
            'Neutral',
            false,
          ),
        ],
      ),
    );
  }

  void _showAllSurveys(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Safety Surveys',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
            shrinkWrap: true,
            itemCount: 5, // Example count
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) => _buildSurveyItem(
              context,
              index % 2 == 0 ? 'Evening Train Commute' : 'Bus Route 42',
              'Example Route • Oct ${24 - index}',
              index % 2 == 0 ? 'Felt Safe' : 'Neutral',
              index % 2 == 0,
            ),
          ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyItem(
    BuildContext context,
    String title,
    String subtitle,
    String status,
    bool positive,
  ) {
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
            color: positive 
                ? Theme.of(context).colorScheme.secondaryContainer 
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: positive 
                      ? Theme.of(context).colorScheme.onSecondaryContainer 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
