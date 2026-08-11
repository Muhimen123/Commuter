import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/glass_container.dart';

class SharingSection extends StatelessWidget {
  const SharingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
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
                    'Sharing With',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Icon(Icons.radio_button_checked, color: Color(0xFF307082)),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactTile(
            context,
            'Sarah Johnson',
            'Active tracking',
            'https://i.pravatar.cc/150?u=sarah',
          ),
          const SizedBox(height: 12),
          _buildContactTile(
            context,
            'Mark Roberts',
            'Active tracking',
            'https://i.pravatar.cc/150?u=mark',
            initials: 'MR',
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    String name,
    String status,
    String avatarUrl, {
    String? initials,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundImage: initials == null ? NetworkImage(avatarUrl) : null,
            child: initials != null ? Text(initials) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
