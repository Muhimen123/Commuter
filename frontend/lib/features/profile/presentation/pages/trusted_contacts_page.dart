import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/profile/presentation/widgets/add_contact_dialog.dart';
import 'package:frontend/features/profile/domain/trusted_contacts_notifier.dart';

class TrustedContactsPage extends ConsumerStatefulWidget {
  const TrustedContactsPage({super.key});

  @override
  ConsumerState<TrustedContactsPage> createState() => _TrustedContactsPageState();
}

class _TrustedContactsPageState extends ConsumerState<TrustedContactsPage> {
  void _addNewContact() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddContactDialog(),
    );

    if (result != null && result['name'] != null && result['phone'] != null) {
      ref.read(trustedContactsProvider.notifier).addContact(
        result['name']!, 
        result['phone']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Guardians'),
      ),
      body: contactsAsync.when(
        data: (contacts) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final contact = contacts[index];
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
                  child: Text(contact.name[0]),
                ),
                title: Text(
                  contact.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(contact.phoneNumber),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  onPressed: () => ref.read(trustedContactsProvider.notifier).deleteContact(contact.id),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
