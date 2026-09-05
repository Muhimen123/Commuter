import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/safety/domain/sharing_notifier.dart';
import 'package:frontend/features/profile/domain/trusted_contacts_notifier.dart';

class SharingSection extends ConsumerWidget {
  const SharingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharingState = ref.watch(sharingProvider);
    final myShares = sharingState.myActiveShares;
    final sharedWithMe = sharingState.sharedWithMe;

    return Column(
      children: [
        // Outgoing: Sharing With (I am the sharer)
        Container(
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
                      Icon(Icons.share_location,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Sharing With',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (myShares.isNotEmpty)
                    const Icon(Icons.radio_button_checked, color: Colors.green),
                ],
              ),
              const SizedBox(height: 20),
              if (myShares.isEmpty)
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showShareDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Start Sharing'),
                  ),
                )
              else
                ...myShares.map((share) => _buildActiveShareTile(
                      context,
                      ref,
                      share['trusted_contacts']['contact_name'],
                      'Active tracking',
                      share['id'],
                    )),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Incoming: Shared With Me (I am the guardian)
        if (sharedWithMe.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_pin_circle,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Shared With Me',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (final loc in sharedWithMe)
                  if (loc != null)
                    _buildGuardianTile(
                      context,
                      loc.sharerName,
                      loc.lastPingAt != null ? 'Last seen just now' : 'Waiting for signal',
                      loc.sharerPhoto,
                      onTap: () {
                        if (loc.latitude != null && loc.longitude != null) {
                          context.go('/?lat=${loc.latitude}&lon=${loc.longitude}&name=${loc.sharerName}');
                        }
                      },
                    ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActiveShareTile(
    BuildContext context,
    WidgetRef ref,
    String name,
    String status,
    String shareId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
            onPressed: () => ref.read(sharingProvider.notifier).stopSharing(shareId),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianTile(
    BuildContext context,
    String name,
    String status,
    String? photoUrl, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? Text(name[0]) : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status,
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _showShareDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return const ShareLocationSheet();
      },
    );
  }
}

class ShareLocationSheet extends ConsumerWidget {
  const ShareLocationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(trustedContactsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Guardian',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 16),
          contacts.when(
            data: (list) => ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final contact = list[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(contact.name[0])),
                  title: Text(contact.name),
                  subtitle: Text(contact.linkedUserId != null 
                      ? 'Registered User' 
                      : 'Not registered'),
                  trailing: const Icon(Icons.send),
                  onTap: () {
                    ref.read(sharingProvider.notifier).startSharing(
                      contactId: contact.id,
                      recipientUserId: contact.linkedUserId,
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
