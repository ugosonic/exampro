import 'package:citizentest/features/auth/presentation/sign_up_state.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:citizentest/common/widgets/neon_glass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(signUpControllerProvider);
    final controller = ref.read(signUpControllerProvider.notifier);
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
                          child: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF8FC7FF), size: 34),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text('Create account', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF0B2540), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                enabled: !state.loading,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.white70 : Colors.black45),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4DA3FF))),
                  errorText: state.emailError,
                ),
                onChanged: controller.onEmailChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: _obscure1,
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
                    icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white70 : Colors.black45),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                onChanged: controller.onPasswordChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: _obscure2,
                enabled: !state.loading,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_person_outlined, color: isDark ? Colors.white70 : Colors.black45),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4DA3FF))),
                  errorText: state.confirmError,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white70 : Colors.black45),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                onChanged: controller.onConfirmChanged,
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
                      : const Text('Create account'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Already have an account? Sign in'),
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
