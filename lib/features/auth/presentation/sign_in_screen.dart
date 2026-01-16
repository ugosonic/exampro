import 'package:exampro/features/auth/presentation/sign_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);
    final controller = ref.read(signInControllerProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('email_field'),
                keyboardType: TextInputType.emailAddress,
                enabled: !state.loading,
                decoration: InputDecoration(labelText: 'Email', errorText: state.emailError),
                onChanged: controller.onEmailChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('password_field'),
                obscureText: true,
                enabled: !state.loading,
                decoration: InputDecoration(labelText: 'Password', errorText: state.passwordError),
                onChanged: controller.onPasswordChanged,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: state.loading ? null : () {}, child: const Text('Forgot password?')),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: state.loading ? null : () => context.go('/delete-account'),
                  child: const Text('Delete account'),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.canSubmit && !state.loading
                    ? () async {
                        final ok = await controller.submit();
                        if (ok) context.go('/dashboard');
                      }
                    : null,
                child: state.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sign in'),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.loading ? null : () => context.go('/register'),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
