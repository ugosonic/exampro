import 'package:citizentest/features/auth/presentation/sign_in_state.dart';
import 'package:citizentest/features/auth/data/auth_repository.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:citizentest/common/widgets/neon_glass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(signInControllerProvider);
    final controller = ref.read(signInControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: NeonGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF8FC7FF), size: 34),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text('Welcome back', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF0B2540), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
              TextField(
                key: const Key('email_field'),
                keyboardType: TextInputType.emailAddress,
                enabled: !state.loading,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.person_outline, color: isDark ? Colors.white70 : Colors.black45),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFF4DA3FF))),
                  errorText: state.emailError,
                ),
                onChanged: controller.onEmailChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('password_field'),
                obscureText: _obscure,
                enabled: !state.loading,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black45),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4DA3FF))),
                  errorText: state.passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white70 : Colors.black45),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onChanged: controller.onPasswordChanged,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: state.loading
                      ? null
                      : () async {
                          final emailCtrl = TextEditingController(text: state.email);
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Reset password'),
                              content: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Send reset link')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            try {
                              await ref.read(authRepositoryProvider).forgotPassword(emailCtrl.text.trim());
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('If the email exists, a reset link was sent.')));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                              }
                            }
                          }
                        },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: state.canSubmit && !state.loading
                      ? () async {
                          final ok = await controller.submit();
                          if (!context.mounted) return;
                          if (ok) {
                            final user = ref.read(currentUserProvider);
                            if (user?.role == 'admin') {
                              context.go('/admin');
                            } else {
                              context.go('/dashboard');
                            }
                          }
                        }
                      : null,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2C69C9)),
                  child: state.loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('LOGIN'),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Create an account'),
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ]
            ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
