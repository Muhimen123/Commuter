import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Center(child: Text(title)),
    );
  }
}
