import 'package:citizentest/core/auth/token_store.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citizentest/features/profile/data/reset_service.dart';
import 'package:citizentest/features/onboarding/presentation/widgets/language_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final double _progress = 0;
  final String _label = '';
  final bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Stack(children: [
        // Purple header to match dashboard
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF7286FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.email ?? 'Guest', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Role: ${user?.role ?? 'none'}'),
                  const SizedBox(height: 12),
                  const LanguagePicker(),
                  const SizedBox(height: 20),
                  // Manual content update removed: content and progress sync now happen automatically after sign-in.
                ]),
              ),
            ),
            const SizedBox(height: 16),
            if ((user?.role ?? '') == 'admin')
              FilledButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Erase all local data?'),
                      content: const Text('This will sign you out and permanently delete all local data: users, attempts, saved questions, content, and settings. This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text('Erase')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    try {
                      await ref.read(resetServiceProvider).resetAll();
                      ref.read(currentUserProvider.notifier).state = null;
                      if (mounted) {
                        context.go('/onboarding');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All local data erased')));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to erase: $e')));
                      }
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Erase all local data'),
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer, foregroundColor: Theme.of(context).colorScheme.onErrorContainer),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(tokenStoreProvider).clear();
                ref.read(currentUserProvider.notifier).state = null;
                if (mounted) {
                  context.go('/onboarding');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ]),
    );
  }
}
