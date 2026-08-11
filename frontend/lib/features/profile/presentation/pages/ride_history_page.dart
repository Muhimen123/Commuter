import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/shared/widgets/glass_scaffold_background.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  final List<Map<String, String>> rides = [
    {
      'route': 'Bus Route 42',
      'date': 'Oct 22, 2024',
      'fare': '৳2.50',
      'status': 'Completed'
    },
    {
      'route': 'Evening Train Commute',
      'date': 'Oct 24, 2024',
      'fare': '৳4.75',
      'status': 'Completed'
    },
    {
      'route': 'Morning Express 101',
      'date': 'Oct 25, 2024',
      'fare': '৳3.00',
      'status': 'Completed'
    },
    {
      'route': 'Downtown Shuttle',
      'date': 'Oct 26, 2024',
      'fare': '৳1.50',
      'status': 'Completed'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GlassScaffoldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Ride History'),
        ),
        body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ride = rides[index];
          return GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride['route']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ride['date']} • ${ride['status']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ride['fare']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
