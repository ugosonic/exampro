import 'package:citizentest/core/utils/validators.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _sending = false;
  bool _deleting = false;
  bool _codeSent = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final canSend = Validators.isEmail(email) && !_sending && !_deleting;
    final canDelete = _codeSent && code.isNotEmpty && !_sending && !_deleting;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Request a confirmation code to delete your account.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_sending && !_deleting,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: email.isEmpty || Validators.isEmail(email) ? null : 'Invalid email',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: canSend ? _sendCode : null,
                child: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send confirmation code'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                enabled: _codeSent && !_sending && !_deleting,
                decoration: InputDecoration(
                  labelText: 'Confirmation code',
                  helperText: _codeSent ? 'Check your email for the code.' : 'Send a code to continue.',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: canDelete ? _confirmDelete : null,
                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                child: _deleting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Delete account'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Back to sign in'),
              ),
              if (_infoMessage != null) ...[
                const SizedBox(height: 8),
                Text(_infoMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() {
      _sending = true;
      _errorMessage = null;
      _infoMessage = null;
    });
    try {
      final email = _emailController.text.trim();
      await ref.read(authRepositoryProvider).requestDeleteCode(email);
      setState(() {
        _codeSent = true;
        _infoMessage = 'Confirmation code sent to $email.';
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to send confirmation code.');
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('This action cannot be undone. Do you want to continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _deleting = true;
      _errorMessage = null;
      _infoMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).deleteAccount(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
          );
      ref.read(currentUserProvider.notifier).state = null;
      if (mounted) context.go('/onboarding');
    } catch (e) {
      setState(() => _errorMessage = 'Failed to delete account.');
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }
}
