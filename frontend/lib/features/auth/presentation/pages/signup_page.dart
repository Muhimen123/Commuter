import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_tokens.dart';
import '../widgets/auth_text_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
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
                  const SizedBox(height: AppSpacing.xxl),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
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
                            label: 'Password',
                            hintText: '••••••••',
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      // TODO: Implement signup logic
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_forward, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Text('Sign Up'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(
                      'Already have an account? Log in',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
