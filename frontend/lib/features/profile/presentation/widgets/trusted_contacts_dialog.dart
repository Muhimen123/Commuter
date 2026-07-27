import 'package:flutter/material.dart';
import 'add_contact_dialog.dart';

class TrustedContactsDialog extends StatefulWidget {
  const TrustedContactsDialog({super.key});

  @override
  State<TrustedContactsDialog> createState() => _TrustedContactsDialogState();
}

class _TrustedContactsDialogState extends State<TrustedContactsDialog> {
  // Dummy data for trusted contacts
  final List<Map<String, String>> _contacts = [
    {'name': 'Sarah Johnson', 'number': '+1 234 567 8901'},
    {'name': 'Mark Roberts', 'number': '+1 234 567 8902'},
  ];

  void _addNewContact() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const AddContactDialog(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _contacts.add({
          'name': 'New Contact', // Simplified for demo
          'number': result,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trusted Contacts'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _contacts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(contact['name']!),
                    subtitle: Text(contact['number']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _contacts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addNewContact,
              icon: const Icon(Icons.add),
              label: const Text('Add New'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
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
