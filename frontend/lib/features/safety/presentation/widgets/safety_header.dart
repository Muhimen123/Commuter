import 'package:flutter/material.dart';

class SafetyHeader extends StatelessWidget {
  final double topPadding;

  const SafetyHeader({
    super.key,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
          const Spacer(),
          Text(
            'Commuter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Icon(Icons.person_outline, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
