import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/sync/data/sync_repository.dart';
import 'package:exampro/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionInitializerProvider = FutureProvider<void>((ref) async {
  final tokens = ref.read(tokenStoreProvider);
  final has = await tokens.hasTokens();
  if (!has) return;
  try {
    final me = await ref.read(authRepositoryProvider).me();
    ref.read(currentUserProvider.notifier).state = me;
    // Auto-sync content and user progress so devices are consistent.
    try {
      if (me != null) {
        await ref.read(syncRepositoryProvider).pushUserProgress(me.email);
        await ref.read(syncRepositoryProvider).pullUserProgress(me.email);
      }
      await ref.read(syncRepositoryProvider).pullAndImport();
    } catch (_) {
      // Ignore transient sync errors; UI remains usable and will retry later.
    }
  } catch (_) {
    // Do not clear tokens automatically on transient/network errors.
    // Keep the session until the user explicitly signs out.
  }
});
