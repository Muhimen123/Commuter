import 'package:flutter/material.dart';
import '../widgets/location_sharing_with_section.dart';
import '../widgets/location_shared_with_section.dart';
import '../widgets/survey_history_section.dart';
import '../widgets/safety_action_buttons.dart';

class SafetyPage extends StatefulWidget {
  const SafetyPage({super.key});

  @override
  State<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text(
              'Safety Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Monitor your journey and manage emergency contacts.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 32),
            
            SafetyActionButtons(),
            SizedBox(height: 24),
            
            LocationSharingWithSection(),
            SizedBox(height: 24),
            
            LocationSharedWithSection(),
            SizedBox(height: 24),
            
            SurveyHistorySection(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
