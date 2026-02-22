import 'dart:async';

import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/features/sync/data/sync_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentSyncBootstrap {
  final Ref _ref;
  Timer? _timer;
  bool _running = false;

  ContentSyncBootstrap(this._ref);

  void start() {
    _timer ??= Timer.periodic(const Duration(minutes: 2), (_) => syncNow());
  }

  Future<void> syncNow({bool force = false}) async {
    if (_running) return;
    _running = true;
    try {
      final sync = _ref.read(syncRepositoryProvider);
      final hasLocal = await _hasLocalContent();
      await sync.syncIfNeeded(force: force || !hasLocal);

      final user = _ref.read(currentUserProvider);
      final email = user?.email;
      if (email != null && email.isNotEmpty) {
        try {
          await sync.pullUserProgress(email);
        } catch (_) {
          // Ignore transient progress sync failures.
        }
      }
    } catch (_) {
      // Ignore transient content sync failures; local DB remains usable.
    } finally {
      _running = false;
    }
  }

  Future<void> onUserChanged() async {
    await syncNow(force: true);
  }

  Future<bool> _hasLocalContent() async {
    final db = _ref.read(dbProvider);
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM categories')
        .getSingle();
    return ((row.data['c'] as int?) ?? 0) > 0;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

final contentSyncBootstrapProvider = Provider<ContentSyncBootstrap>((ref) {
  final bootstrap = ContentSyncBootstrap(ref);
  ref.listen(currentUserProvider, (previous, next) {
    final prevEmail = previous?.email ?? '';
    final nextEmail = next?.email ?? '';
    if (nextEmail.isNotEmpty && nextEmail != prevEmail) {
      unawaited(bootstrap.onUserChanged());
    }
  });
  bootstrap.start();
  unawaited(bootstrap.syncNow(force: true));
  ref.onDispose(bootstrap.dispose);
  return bootstrap;
});
