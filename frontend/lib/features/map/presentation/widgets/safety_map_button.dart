import 'package:flutter/material.dart';

class SafetyMapButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const SafetyMapButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled 
              ? colorScheme.primary 
              : colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled 
                ? colorScheme.primary 
                : colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isEnabled ? Icons.shield_rounded : Icons.shield_outlined,
          color: isEnabled ? colorScheme.onPrimary : colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}
