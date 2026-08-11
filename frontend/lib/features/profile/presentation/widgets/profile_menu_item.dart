import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/glass_container.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tileColor: Colors.transparent,
            leading: Icon(
              icon,
              color: isDestructive ? Theme.of(context).colorScheme.error : null,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isDestructive ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }
}
