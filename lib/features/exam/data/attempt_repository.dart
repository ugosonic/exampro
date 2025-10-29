import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttemptRepository {
  final AppDatabase _db;
  AttemptRepository(this._db);

  Future<int> startAttempt({required int examId, required String mode, required String userEmail}) async {
    final id = await _db.into(_db.attempts).insert(AttemptsCompanion(
          examId: drift.Value(examId),
          mode: drift.Value(mode),
          startedAt: drift.Value(DateTime.now()),
        ));
    await _db.customStatement('UPDATE attempts SET user_email = ? WHERE id = ?', [userEmail, id]);
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
