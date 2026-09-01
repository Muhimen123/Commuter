import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'package:frontend/features/auth/presentation/widgets/password_text_field.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? email;

  const ResetPasswordPage({
    super.key,
    this.email,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isResetSuccessful = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    // If the user abandons the screen prematurely before successfully resetting password,
    // force a logout to invalidate the temporary recovery session.
    if (!_isResetSuccessful) {
      ref.read(authProvider.notifier).signOut();
    }
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty) {
      CommuterToast.show(
        context,
        message: 'Please enter a new password.',
        icon: Icons.error_outline,
      );
      return;
    }

    if (newPassword.length < 6) {
      CommuterToast.show(
        context,
        message: 'Password must be at least 6 characters.',
        icon: Icons.error_outline,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      CommuterToast.show(
        context,
        message: 'Passwords do not match.',
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).updatePassword(newPassword);
      _isResetSuccessful = true;

      if (mounted) {
        CommuterToast.show(
          context,
          message: 'Password reset successfully! Please sign in.',
          icon: Icons.check_circle_outline,
        );
        context.go('/login');
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
              : 'Failed to reset password. Please try again.',
          icon: Icons.error_outline,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAbandonFlow() async {
    if (!_isResetSuccessful) {
      await ref.read(authProvider.notifier).signOut();
    }
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!_isResetSuccessful) {
          ref.read(authProvider.notifier).signOut();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: _handleAbandonFlow,
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Create new password',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Your new password must be at least 6 characters and different from previous passwords.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Card(
                            elevation: 4,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                children: [
                                  PasswordTextField(
                                    label: 'New Password',
                                    hintText: '••••••••',
                                    controller: _newPasswordController,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  PasswordTextField(
                                    label: 'Confirm Password',
                                    hintText: '••••••••',
                                    controller: _confirmPasswordController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.lg),
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleResetPassword,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text('Updating Password...'),
                              ] else ...[
                                const Text('Reset Password'),
                              ],
                            ],
                          ),
                        ),
                      ),
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
}
