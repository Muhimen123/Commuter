import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _loadingProgress = 0.0;
  bool _isBackendReady = false;

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  final List<String> _loadingSteps = [
    'Connecting to transit servers...',
    'Fetching local bus routes...',
    'Optimizing route graph...',
    'Syncing safety reports...',
    'Ready to commute!',
  ];

  Future<void> _initializeAppData() async {
    // Simulate backend loading sequence
    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 35));
      if (mounted) {
        setState(() {
          _loadingProgress = (i + 1) / 100;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isBackendReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Logo/Icon
                        const Icon(
                          Icons.directions_bus,
                          size: 100,
                          color: Colors.white,
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .moveY(begin: -8, end: 8, duration: 2.seconds, curve: Curves.easeInOut),

                        const SizedBox(height: 24),

                        // App Name
                        Text(
                          'Commuter',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 16),

                        // Tagline
                        Text(
                          'Your personal safety companion for every journey.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                        const Spacer(),

                        // Loading / Actions Section
                        SizedBox(
                          height: 160, // Fixed height to prevent layout jump
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: 500.ms,
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.2),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: !_isBackendReady
                                  ? _buildLoadingState()
                                  : _buildActionButtons(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final stepIndex = (_loadingProgress * (_loadingSteps.length - 1)).floor();
    final currentStep = _loadingSteps[stepIndex];

    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currentStep,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
        )
            .animate(key: ValueKey(currentStep))
            .fadeIn(duration: 400.ms)
            .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_loadingProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      key: const ValueKey('actions'),
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            context.go('/signup');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
          ),
          child: Text(
            'Get Started',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
          child: Text(
            'Log In',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}
