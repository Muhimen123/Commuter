import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';

class LocationSharingWithSection extends StatefulWidget {
  const LocationSharingWithSection({super.key});

  @override
  State<LocationSharingWithSection> createState() => _LocationSharingWithSectionState();
}

class _LocationSharingWithSectionState extends State<LocationSharingWithSection> {
  // Mock data for people we are sharing with
  final List<String> _sharingWith = [];

  // Mock trusted contacts (fetched from profile logic in a real app)
  final List<String> _trustedContacts = [
    'Sarah Johnson',
    'Mark Roberts',
    'Alex Thompson',
  ];

  void _showShareModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Location With',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _trustedContacts.length,
                itemBuilder: (context, index) {
                  final contact = _trustedContacts[index];
                  final isAlreadySharing = _sharingWith.contains(contact);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(contact[0]),
                    ),
                    title: Text(contact),
                    trailing: isAlreadySharing 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.add_circle_outline),
                    onTap: isAlreadySharing ? null : () {
                      setState(() {
                        _sharingWith.add(contact);
                      });
                      Navigator.pop(context);
                      CommuterToast.show(
                        context,
                        message: 'Now sharing live location with $contact',
                        icon: Icons.share_location,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.share_location, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Location Sharing With',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _showShareModal,
                icon: const Icon(Icons.add, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (_sharingWith.isEmpty) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'You are not sharing location with anyone.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            ..._sharingWith.map((name) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(child: Text(name[0])),
                title: Text(name),
                subtitle: const Text('Active tracking'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline, 
                    size: 20, 
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    setState(() {
                      _sharingWith.remove(name);
                    });
                    CommuterToast.show(
                      context,
                      message: 'Stopped sharing location with $name',
                      icon: Icons.person_remove_rounded,
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                      iconBackgroundColor: Theme.of(context).colorScheme.error,
                      iconForegroundColor: Theme.of(context).colorScheme.onError,
                    );
                  },
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }
}
