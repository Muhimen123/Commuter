import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/password_text_field.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      CommuterToast.show(
        context,
        message: 'Please enter your full name.',
        icon: Icons.error_outline,
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      CommuterToast.show(
        context,
        message: 'Please enter a valid email address.',
        icon: Icons.error_outline,
      );
      return;
    }

    if (phone.isEmpty) {
      CommuterToast.show(
        context,
        message: 'Please enter your phone number.',
        icon: Icons.error_outline,
      );
      return;
    }

    if (password.length < 6) {
      CommuterToast.show(
        context,
        message: 'Password must be at least 6 characters.',
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).signUp(
            fullName: name,
            email: email,
            phoneNumber: phone,
            password: password,
          );

      final authState = ref.read(authProvider);
      if (authState.hasError) {
        throw authState.error!;
      }

      if (mounted) {
        context.go('/check_email', extra: email);
      }
    } catch (e) {
      if (mounted) {
        final message = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException(message: ', '')
            .replaceAll(')', '');
        CommuterToast.show(
          context,
          message: message.isNotEmpty
              ? message
              : 'Sign up failed. Please try again.',
          icon: Icons.error_outline,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
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
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthTextField(
                            label: 'Full Name',
                            hintText: 'Jane Doe',
                            controller: _nameController,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AuthTextField(
                            label: 'Email',
                            hintText: 'jane@example.com',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AuthTextField(
                            label: 'Phone Number',
                            hintText: '+880 1401234567',
                            keyboardType: TextInputType.phone,
                            controller: _phoneController,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PasswordTextField(
                            label: 'Password',
                            hintText: '••••••••',
                            controller: _passwordController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: isLoading ? null : _handleSignUp,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Signing up...'),
                    ] else ...[
                      const Icon(Icons.arrow_forward, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Sign Up'),
                    ],
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
                    color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}