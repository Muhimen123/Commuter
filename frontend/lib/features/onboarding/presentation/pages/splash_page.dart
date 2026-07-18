import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  bool _isAtCenter = false;
  bool _isExiting = false;

  late final AnimationController _wheelController;

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void _handleNavigation(String route) async {
    if (_isExiting) return;
    setState(() {
      _isExiting = true;
    });

    // Wait for the bus to drive off screen before navigating
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.primary,
        ),
        child: SafeArea(
          child: Stack(
            children: [
            // Bus Animation Layer
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The Bus
                  _buildAnimatedBus(),
                  
                  const SizedBox(height: 48),
                  
                  // App Name (Fades in when bus stops)
                  if (_isAtCenter)
                    Text(
                      'Commuter',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),

            // Controls Layer
            if (_isAtCenter && !_isExiting)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleNavigation('/signup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
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
                        onPressed: () => _handleNavigation('/login'),
                        child: Text(
                          'Log In',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBus() {
    return Animate(
      onComplete: (controller) {
        if (!_isExiting) {
          setState(() {
            _isAtCenter = true;
          });
        }
      },
      effects: [
        // Entrance: Drive from left to center
        MoveEffect(
          delay: 2.seconds,
          begin: const Offset(-600, 0),
          end: Offset.zero,
          duration: 2000.ms,
          curve: Curves.easeInOutCubic,
        ),
      ],
      child: Animate(
        target: _isExiting ? 1 : 0,
        effects: [
          // Exit: Drive from center to right
          MoveEffect(
            begin: Offset.zero,
            end: const Offset(500, 0),
            duration: 1200.ms,
            curve: Curves.easeInCubic,
          ),
        ],
        child: _BusSideView(wheelController: _wheelController),
      ),
    );
  }
}

class _BusSideView extends StatelessWidget {
  final AnimationController wheelController;

  const _BusSideView({required this.wheelController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Body
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          // Windows
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Door
          Positioned(
            bottom: 15,
            right: 30,
            child: Container(
              width: 25,
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),
          // Wheels
          Positioned(
            bottom: -10,
            left: 30,
            child: _Wheel(controller: wheelController),
          ),
          Positioned(
            bottom: -10,
            right: 30,
            child: _Wheel(controller: wheelController),
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  final AnimationController controller;

  const _Wheel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: controller.value * 2 * 3.14159,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF2D3436),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 4,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        );
      },
    );
  }
}
