import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/safety/domain/safety_notifier.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';
import 'package:frontend/features/safety/presentation/pages/report/incident_report_page.dart';

class SafetyActionButtons extends ConsumerWidget {
  const SafetyActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            icon: Icons.map_outlined,
            label: 'Area Survey',
            color: const Color(0xFFC0A94E),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const IncidentReportPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const _SOSModal(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              fixedSize: const Size.fromHeight(52),
            ),
            child: const Text('SOS'),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        fixedSize: const Size.fromHeight(52),
      ),
    );
  }
}

class _SOSModal extends ConsumerStatefulWidget {
  const _SOSModal();

  @override
  ConsumerState<_SOSModal> createState() => _SOSModalState();
}

class _SOSModalState extends ConsumerState<_SOSModal> {
  double _progress = 0.0;
  Timer? _timer;
  bool _isTriggered = false;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.05 / 2.0; // 2 seconds total
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _triggerSOS();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _progress = 0.0;
    });
  }

  Future<void> _triggerSOS() async {
    if (_isTriggered) return;
    _isTriggered = true;
    
    // Call the real SOS logic via Riverpod
    await ref.read(safetyAlertProvider.notifier).triggerSOS();

    if (mounted) {
      Navigator.of(context).pop();
      CommuterToast.show(
        context,
        message: 'Emergency Alert Sent to Trusted Contacts!',
        icon: Icons.emergency_share_rounded,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SOS'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Hold the SOS button to send notification'),
          const SizedBox(height: 20),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: GestureDetector(
              onTapDown: (_) => _startTimer(),
              onTapUp: (_) => _stopTimer(),
              onTapCancel: () => _stopTimer(),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    if (_progress > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white38),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
