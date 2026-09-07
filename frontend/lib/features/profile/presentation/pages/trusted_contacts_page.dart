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

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Contact'),
            content: Text(
                'Are you sure you want to remove $name from your trusted guardians? This will mutually remove both of you from each other\'s lists.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardians & Invites'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(trustedContactsProvider.notifier).loadContacts(),
        child: contactsAsync.when(
          data: (allContacts) {
            // Trusted Guardians: Show only rows where I am the OWNER and status is ACCEPTED
            final accepted = allContacts.where((c) => c.status == 'accepted' && !c.isIncoming).toList();

            // Pending Incoming: Someone wants to add ME
            final incoming = allContacts.where((c) => c.status == 'pending' && c.isIncoming).toList();

            // Pending Outgoing: I want to add SOMEONE ELSE
            final outgoing = allContacts.where((c) => c.status == 'pending' && !c.isIncoming).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
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
                  _buildHeader('Sent Invites (Waiting for response)'),
                  ...outgoing.map((c) => _buildInviteTile(c, false)),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
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
            : TextButton(
                onPressed: () => ref.read(trustedContactsProvider.notifier).cancelInvite(contact.id),
                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
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
          onPressed: () async {
            if (await _confirmDelete(contact.name)) {
              ref.read(trustedContactsProvider.notifier).deleteContact(contact.id);
            }
          },
        ),
      ),
    );
  }
}
