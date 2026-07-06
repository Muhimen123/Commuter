import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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

                        // Buttons
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.go('/home');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0),

                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: () {
                                // Navigate to Log In
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
                            ).animate().fadeIn(delay: 1000.ms),
                          ],
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
}
