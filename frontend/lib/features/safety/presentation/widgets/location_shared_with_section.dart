import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocationSharedWithSection extends StatelessWidget {
  const LocationSharedWithSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for people sharing their location with us
    final List<Map<String, String>> _sharedBy = [
      {'name': 'Sarah Johnson', 'status': '2 mins ago'},
      {'name': 'Mark Roberts', 'status': 'Live'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Location Shared With You',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._sharedBy.map((person) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: CircleAvatar(child: Text(person['name']![0])),
              title: Text(person['name']!),
              subtitle: Text(person['status']!),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                // Navigate to Map and show a mock location for this person
                // Sarah is at a mock park, Mark is at a mock station
                final mockLat = person['name'] == 'Sarah Johnson' ? 47.4420 : 47.4300;
                final mockLon = person['name'] == 'Sarah Johnson' ? 8.4680 : 8.4850;
                
                context.go('/?lat=$mockLat&lon=$mockLon&name=${person['name']}');
              },
            ),
          )),
        ],
      ),
    );
  }
}
