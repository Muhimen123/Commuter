import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/profile/presentation/widgets/add_contact_dialog.dart';
import 'package:frontend/features/profile/domain/trusted_contacts_notifier.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';

class TrustedContactsPage extends ConsumerStatefulWidget {
  const TrustedContactsPage({super.key});

  @override
  ConsumerState<TrustedContactsPage> createState() => _TrustedContactsPageState();
}

class _TrustedContactsPageState extends ConsumerState<TrustedContactsPage> {
  void _addNewContact() async {
    final phone = await showDialog<String>(
      context: context,
      builder: (context) => const AddContactDialog(),
    );

    if (phone != null && phone.isNotEmpty) {
      try {
        await ref.read(trustedContactsProvider.notifier).sendInvite(phone);
        if (mounted) {
          CommuterToast.show(
            context,
            message: 'Invite sent successfully!',
            icon: Icons.check_circle,
          );
        }
      } catch (e) {
        if (mounted) {
          CommuterToast.show(
            context,
            message: 'User not found or already added.',
            icon: Icons.error_outline,
            backgroundColor: Colors.red.shade50,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardians & Invites'),
      ),
      body: contactsAsync.when(
        data: (allContacts) {
          final accepted = allContacts.where((c) => c.status == 'accepted').toList();
          final incoming = allContacts.where((c) => c.status == 'pending' && c.isIncoming).toList();
          final outgoing = allContacts.where((c) => c.status == 'pending' && !c.isIncoming).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (incoming.isNotEmpty) ...[
                _buildHeader('Pending Requests'),
                ...incoming.map((c) => _buildInviteTile(c, true)),
                const SizedBox(height: 24),
              ],
              
              _buildHeader('Trusted Guardians'),
              if (accepted.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text('No trusted guardians yet.', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ...accepted.map((c) => _buildContactTile(c)),

              if (outgoing.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildHeader('Sent Invites'),
                ...outgoing.map((c) => _buildInviteTile(c, false)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: _addNewContact,
            icon: const Icon(Icons.person_add),
            label: const Text('Add by Phone Number'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildInviteTile(TrustedContact contact, bool isIncoming) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phoneNumber),
        trailing: isIncoming 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => ref.read(trustedContactsProvider.notifier).respondToInvite(contact.id, true),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => ref.read(trustedContactsProvider.notifier).respondToInvite(contact.id, false),
                ),
              ],
            )
          : const Chip(label: Text('Pending', style: TextStyle(fontSize: 10))),
      ),
    );
  }

  Widget _buildContactTile(TrustedContact contact) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(contact.name[0]),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phoneNumber),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ref.read(trustedContactsProvider.notifier).deleteContact(contact.id),
        ),
      ),
    );
  }
}
