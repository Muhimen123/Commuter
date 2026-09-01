import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/shared/widgets/commuter_toast.dart';

class VerifyCodePage extends ConsumerStatefulWidget {
  final String? email;

  const VerifyCodePage({
    super.key,
    this.email,
  });

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    final targetEmail = widget.email?.trim() ?? '';

    if (targetEmail.isEmpty) {
      CommuterToast.show(
        context,
        message: 'Missing email address. Please request a new code.',
        icon: Icons.error_outline,
      );
      return;
    }

    if (code.isEmpty) {
      CommuterToast.show(
        context,
        message: 'Please enter the verification code.',
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).verifyPasswordResetOtp(
            email: targetEmail,
            token: code,
          );

      if (mounted) {
        CommuterToast.show(
          context,
          message: 'Code verified successfully.',
          icon: Icons.check_circle_outline,
        );
        context.push('/reset_password', extra: targetEmail);
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
              : 'Invalid or expired code. Please try again.',
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

  Future<void> _handleResendCode() async {
    final targetEmail = widget.email?.trim() ?? '';
    if (targetEmail.isEmpty) {
      CommuterToast.show(
        context,
        message: 'No email specified to resend code.',
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await ref.read(authProvider.notifier).sendPasswordResetOtp(targetEmail);
      if (mounted) {
        CommuterToast.show(
          context,
          message: 'A new verification code has been sent to $targetEmail',
          icon: Icons.mark_email_read_outlined,
        );
      }
    } catch (e) {
      if (mounted) {
        CommuterToast.show(
          context,
          message: 'Failed to resend code. Please try again.',
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final targetEmail = widget.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
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
                          'Enter verification code',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          targetEmail != null && targetEmail.isNotEmpty
                              ? 'We have sent a verification code to $targetEmail. Please enter it below.'
                              : 'We have sent a verification code to your email address. Please enter it below.',
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
                            child: AuthTextField(
                              label: 'Verification Code',
                              hintText: '123456',
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isResending ? null : _handleResendCode,
                            child: _isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.lg),
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleVerifyCode,
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
                              const Text('Verifying...'),
                            ] else ...[
                              const Text('Verify Code'),
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
    );
  }
}
