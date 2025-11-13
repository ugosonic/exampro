import 'package:citizentest/features/exam/data/attempt_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  final AttemptRepository _attempts;
  SyncService(this._attempts);

  Future<void> syncAll() async {
    final pending = await _attempts.pendingSyncAttempts();
    for (final _ in pending) {
      // TODO: POST to API and mark as synced on success
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService(ref.watch(attemptRepositoryProvider)));
