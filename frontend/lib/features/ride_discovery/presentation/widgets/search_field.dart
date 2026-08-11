import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/shared/widgets/glass_container.dart';

class RideSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const RideSearchField({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        height: 56,
        child: TextField(
          controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search routes or destinations',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      ),
    );
  }
}
