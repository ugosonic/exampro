import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:exampro/features/sync/data/sync_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/profile/data/reset_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  double _progress = 0;
  String _label = '';
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.email ?? 'Guest', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Role: ${user?.role ?? 'none'}'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Content update', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_updating) ...[
                    LinearProgressIndicator(value: _progress == 0 ? null : _progress),
                    const SizedBox(height: 8),
                    Text(_label.isEmpty ? 'Updating…' : _label),
                  ] else
                    FilledButton.icon(
                      icon: const Icon(Icons.sync),
                      label: const Text('Update now'),
                onPressed: () async {
                  setState(() { _updating = true; _progress = 0; _label = 'Starting…'; });
                  try {
                    final user = ref.read(currentUserProvider);
                    if (user != null) {
                      _label = 'Syncing your progress…';
                      await ref.read(syncRepositoryProvider).pushUserProgress(user.email);
                      await ref.read(syncRepositoryProvider).pullUserProgress(user.email);
                    }
                    await ref.read(syncRepositoryProvider).pullAndImport(onProgress: (p, l) => setState(() { _progress = p; _label = l; }));
                    // Refresh current user's role from local DB if present
                    final me = ref.read(currentUserProvider);
                    if (me != null) {
                      final row = await (ref.read(dbProvider).select(ref.read(dbProvider).users)..where((u) => u.email.equals(me.email))).getSingleOrNull();
                      if (row != null) {
                        ref.read(currentUserProvider.notifier).state = User(id: me.id, email: me.email, role: row.role);
                      }
                    }
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content and progress updated')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                  }
                  if (mounted) setState(() { _updating = false; });
                },
                    ),
                ]),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Erase all local data?'),
                    content: const Text(
                      'This will sign you out and permanently delete all local data: users, attempts, saved questions, content, and settings. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                        child: const Text('Erase'),
                      ),
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
                  // Ensure we land on onboarding after sign-out
                  // Use go_router so the shell updates correctly
                  context.go('/onboarding');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            )
          ],
        ),
      ),
    );
  }
}
