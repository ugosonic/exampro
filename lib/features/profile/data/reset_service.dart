import 'package:citizentest/core/auth/token_store.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetService {
  final AppDatabase _db;
  final TokenStore _tokens;
  ResetService(this._db, this._tokens);

  Future<void> resetAll() async {
    // Clear auth tokens first
    await _tokens.clear();
    // Wipe all app tables. Order matters due to FKs.
    await _db.transaction(() async {
      final tables = <String>[
        'exam_grade_bands',
        'exam_questions',
        'choices',
        'questions',
        'exams',
        'question_categories',
        'question_subcategories',
        'attempt_answers',
        'attempts',
        'saved_questions',
        'reports',
        'daily_goals',
        'app_settings',
        'payments',
        'users',
        'subcategories',
        'categories',
      ];
      for (final t in tables) {
        await _db.customStatement('DELETE FROM $t');
      }
      // Optionally reset autoincrement counters
      try {
        await _db.customStatement('DELETE FROM sqlite_sequence');
      } catch (_) {}
    });
    try {
      await _db.customStatement('VACUUM');
    } catch (_) {}
  }
}

final resetServiceProvider = Provider<ResetService>((ref) => ResetService(ref.watch(dbProvider), ref.watch(tokenStoreProvider)));

