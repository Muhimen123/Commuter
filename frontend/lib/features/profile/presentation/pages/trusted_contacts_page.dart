import 'package:flutter/material.dart';
import '../widgets/add_contact_dialog.dart';

class TrustedContactsPage extends StatefulWidget {
  const TrustedContactsPage({super.key});

  @override
  State<TrustedContactsPage> createState() => _TrustedContactsPageState();
}

class _TrustedContactsPageState extends State<TrustedContactsPage> {
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
          'name': 'New Contact',
          'number': result,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Guardians'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                contact['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(contact['number']!),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  setState(() {
                    _contacts.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: _addNewContact,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Guardian'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ),
      ),
    );
  }
}
