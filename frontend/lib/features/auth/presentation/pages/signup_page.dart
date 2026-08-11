import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/password_text_field.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/shared/widgets/glass_scaffold_background.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffoldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Create account',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Join Commuter to travel with peace of mind.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          AuthTextField(
                            label: 'Full Name',
                            hintText: 'Jane Doe',
                          ),
                          SizedBox(height: AppSpacing.lg),
                          AuthTextField(
                            label: 'Email',
                            hintText: 'jane@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          AuthTextField(
                            label: 'Phone Number',
                            hintText: '+880 1401234567',
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          PasswordTextField(
                            label: 'Password',
                            hintText: '••••••••',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  context.go('/');
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_forward, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Sign Up'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  context.push('/login');
                },
                child: Text(
                  'Already have an account? Log in',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
