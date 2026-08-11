import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme_notifier.dart';
import '../../../../shared/widgets/glass_scaffold_background.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _locationEnabled = true;
  bool _contactsEnabled = false;
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  String _distanceMetric = 'Km'; // 'Km' or 'Miles'

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffoldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
        children: [
          _buildSectionHeader('Permissions'),
          SwitchListTile(
            title: const Text('Location Access'),
            subtitle: const Text('Required for routing and live tracking'),
            value: _locationEnabled,
            onChanged: (val) => setState(() => _locationEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Contacts Access'),
            subtitle: const Text('Required to manage Trusted Guardians'),
            value: _contactsEnabled,
            onChanged: (val) => setState(() => _contactsEnabled = val),
          ),
          const Divider(),
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app theme appearance'),
            value: _darkModeEnabled,
            onChanged: (val) {
              setState(() => _darkModeEnabled = val);
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          ListTile(
            title: const Text('Distance Metric'),
            subtitle: const Text('Select distance display measurement'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Km', label: Text('Km')),
                ButtonSegment(value: 'Miles', label: Text('Mi')),
              ],
              selected: {_distanceMetric},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _distanceMetric = newSelection.first;
                });
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive security alerts and ride updates'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          const Divider(),
          _buildSectionHeader('General & Privacy'),
          ListTile(
            title: const Text('Data & Privacy'),
            subtitle: const Text('Manage data usage and export reports'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy portal coming soon')),
              );
            },
          ),
          ListTile(
            title: const Text('About Commuter'),
            subtitle: const Text('Version 1.0.0 (Build 2026.08)'),
            trailing: const Icon(Icons.info_outline),
            onTap: () {},
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
