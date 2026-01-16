<<<<<<< HEAD
import 'package:exampro/features/exam/data/attempt_repository.dart';
=======
import 'package:citizentest/features/exam/data/attempt_repository.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  final AttemptRepository _attempts;
  SyncService(this._attempts);

  Future<void> syncAll() async {
    final pending = await _attempts.pendingSyncAttempts();
<<<<<<< HEAD
    for (final a in pending) {
=======
    for (final _ in pending) {
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      // TODO: POST to API and mark as synced on success
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService(ref.watch(attemptRepositoryProvider)));
<<<<<<< HEAD

=======
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
