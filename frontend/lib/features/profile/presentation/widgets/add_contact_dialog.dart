import 'package:flutter/material.dart';

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'John Doe',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+1 234 567 890',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'phone': _phoneController.text,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
