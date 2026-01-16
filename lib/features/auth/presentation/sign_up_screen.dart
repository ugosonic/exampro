import 'package:exampro/features/auth/presentation/sign_up_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpControllerProvider);
    final controller = ref.read(signUpControllerProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('signup_email_field'),
                keyboardType: TextInputType.emailAddress,
                enabled: !state.loading,
                decoration: InputDecoration(labelText: 'Email', errorText: state.emailError),
                onChanged: controller.onEmailChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('signup_password_field'),
                obscureText: true,
                enabled: !state.loading,
                decoration: InputDecoration(labelText: 'Password', errorText: state.passwordError),
                onChanged: controller.onPasswordChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('signup_confirm_field'),
                obscureText: true,
                enabled: !state.loading,
                decoration: InputDecoration(labelText: 'Confirm password', errorText: state.confirmError),
                onChanged: controller.onConfirmChanged,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.canSubmit && !state.loading
                    ? () async {
                        final ok = await controller.submit();
                        if (ok && context.mounted) context.go('/dashboard');
                      }
                    : null,
                child: state.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Register'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.loading ? null : () => context.go('/auth'),
                child: const Text('Already have an account? Sign in'),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
