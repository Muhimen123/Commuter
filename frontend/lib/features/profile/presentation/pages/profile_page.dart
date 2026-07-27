import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/trusted_contacts_dialog.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/ride_history_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name
                  Text(
                    'Jane Doe',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // Email
                  Text(
                    'jane@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // Edit Profile Button
                  OutlinedButton(
                    onPressed: () => _showEditProfile(context),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu Items
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Ride History',
              onTap: () => _showRideHistory(context),
            ),
            ProfileMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Trusted Contacts',
              onTap: () => _showTrustedContacts(context),
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Log Out',
              isDestructive: true,
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRideHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RideHistoryDialog(),
    );
  }

  void _showTrustedContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TrustedContactsDialog(),
    );
  }

  void _showEditProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditProfileDialog(),
    );
  }
}
