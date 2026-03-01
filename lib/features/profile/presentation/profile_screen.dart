import 'package:citizentest/core/auth/token_store.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/notifications/notification_settings.dart';
import 'package:citizentest/core/notifications/notifications.dart';
import 'package:citizentest/core/notifications/pending_test_reminder.dart';
import 'package:citizentest/core/notifications/push_notifications.dart';
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
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Stack(
        children: [
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Guest',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text('Role: ${user?.role ?? 'none'}'),
                      const SizedBox(height: 12),
                      const LanguagePicker(),
                      const SizedBox(height: 20),
                      // Manual content update removed: content and progress sync now happen automatically after sign-in.
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _NotificationSettingsCard(),
              const SizedBox(height: 16),
              if ((user?.role ?? '') == 'admin')
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
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            child: const Text('Erase'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      try {
                        await ref.read(resetServiceProvider).resetAll();
                        ref.read(currentUserProvider.notifier).state = null;
                        if (!context.mounted) return;
                        context.go('/onboarding');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All local data erased'),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to erase: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Erase all local data'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onErrorContainer,
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () async {
                  await ref.read(tokenStoreProvider).clear();
                  ref.read(currentUserProvider.notifier).state = null;
                  if (!context.mounted) return;
                  context.go('/onboarding');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationSettingsCard extends ConsumerStatefulWidget {
  const _NotificationSettingsCard();

  @override
  ConsumerState<_NotificationSettingsCard> createState() =>
      _NotificationSettingsCardState();
}

class _NotificationSettingsCardState
    extends ConsumerState<_NotificationSettingsCard> {
  bool _loaded = false;
  bool _enabled = true;
  int _hour = 19;
  int _minute = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(dbProvider);
    final enabled = await NotificationSettings.getEnabled(db);
    final hour = await NotificationSettings.getReminderHour(db);
    final minute = await NotificationSettings.getReminderMinute(db);
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _enabled = enabled;
      _hour = hour;
      _minute = minute;
    });
  }

  Future<void> _save() async {
    final db = ref.read(dbProvider);
    await NotificationSettings.setEnabled(db, _enabled);
    await NotificationSettings.setReminderTime(
      db,
      hour: _hour,
      minute: _minute,
    );
    if (!_enabled) {
      await NotificationsService.cancelAll();
    }
    try {
      await PendingTestReminderService.sync(db);
    } catch (_) {
      // Keep settings responsive even if schedule APIs are restricted.
    }
    try {
      await ref.read(pushNotificationsProvider).syncTokenWithBackend();
    } catch (_) {
      // Local settings should still save even if backend sync is unavailable.
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked == null) return;
    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _enabled,
              onChanged: !_loaded
                  ? null
                  : (v) async {
                      setState(() => _enabled = v);
                      await _save();
                    },
              title: const Text('Pending test reminders'),
              subtitle: const Text(
                'Get a reminder when you have an unfinished test',
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder time'),
              subtitle: Text(timeLabel),
              trailing: TextButton(
                onPressed: (!_enabled || !_loaded)
                    ? null
                    : () => _pickTime(context),
                child: const Text('Change'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
