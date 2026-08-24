import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';
import 'package:frontend/features/safety/presentation/pages/report/incident_report_page.dart';

class SafetyActionButtons extends StatelessWidget {
  const SafetyActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
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
        const Expanded(
          child: _SOSButton(),
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

class _SOSButton extends StatefulWidget {
  const _SOSButton();

  @override
  State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton> {
  double _progress = 0.0;
  Timer? _timer;
  bool _isTriggered = false;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.05 / 2.0; // 2 seconds total now
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

  void _triggerSOS() {
    if (_isTriggered) return;
    _isTriggered = true;
    CommuterToast.show(
      context,
      message: 'Emergency Alert Sent to Trusted Contacts!',
      icon: Icons.emergency_share_rounded,
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isTriggered = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startTimer(),
      onTapUp: (_) => _stopTimer(),
      onTapCancel: () => _stopTimer(),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
    );
  }
}
