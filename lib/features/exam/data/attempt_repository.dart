import 'dart:convert';

import 'package:drift/drift.dart' as drift;
<<<<<<< HEAD
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
=======
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttemptRepository {
  final AppDatabase _db;
  AttemptRepository(this._db);

<<<<<<< HEAD
  Future<int> startAttempt({required int examId, required String mode}) async {
=======
  Future<int> startAttempt({required int examId, required String mode, required String userEmail}) async {
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    final id = await _db.into(_db.attempts).insert(AttemptsCompanion(
          examId: drift.Value(examId),
          mode: drift.Value(mode),
          startedAt: drift.Value(DateTime.now()),
        ));
<<<<<<< HEAD
=======
    await _db.customStatement('UPDATE attempts SET user_email = ? WHERE id = ?', [userEmail, id]);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    return id;
  }

  Future<void> saveAnswer({required int attemptId, required int questionId, required List<int> selected, int timeMs = 0}) async {
    await _db.into(_db.attemptAnswers).insertOnConflictUpdate(AttemptAnswersCompanion(
      attemptId: drift.Value(attemptId),
      questionId: drift.Value(questionId),
      selected: drift.Value(jsonEncode(selected)),
      timeMs: drift.Value(timeMs),
    ));
  }

  Future<void> submitAttempt(int attemptId) async {
    await (_db.update(_db.attempts)..where((t) => t.id.equals(attemptId))).write(AttemptsCompanion(
      endedAt: drift.Value(DateTime.now()),
      synced: const drift.Value(false),
    ));
  }

  Future<List<Attempt>> pendingSyncAttempts() async =>
      await (_db.select(_db.attempts)..where((t) => t.synced.equals(false))).get();
}

final attemptRepositoryProvider = Provider<AttemptRepository>((ref) => AttemptRepository(ref.watch(dbProvider)));
<<<<<<< HEAD

=======
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
