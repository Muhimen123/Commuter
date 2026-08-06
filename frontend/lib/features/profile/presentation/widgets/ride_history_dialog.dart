import 'package:flutter/material.dart';

class RideHistoryDialog extends StatelessWidget {
  const RideHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for ride history
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

    return AlertDialog(
      title: const Text('Ride History'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: rides.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final ride = rides[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                ride['route']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${ride['date']} • ${ride['status']}'),
              trailing: Text(
                ride['fare']!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
