import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryProgress {
  final int categoryId;
  final String name;
  final String imageUrl;
  final int completed;
  final int total;
  const CategoryProgress({required this.categoryId, required this.name, required this.imageUrl, required this.completed, required this.total});

  double get pct => total == 0 ? 0 : (completed / total).clamp(0, 1);
}

class ProgressRepository {
  final AppDatabase _db;
  ProgressRepository(this._db);

  Future<List<CategoryProgress>> categoryProgressForUser(String userEmail) async {
    // Totals by category
    final totalsRows = await _db.customSelect(
      'SELECT e.category_id AS cid, CAST(COUNT(DISTINCT eq.question_id) AS INTEGER) AS total '
      'FROM exams e JOIN exam_questions eq ON e.id = eq.exam_id '
      'GROUP BY e.category_id',
    ).get();
    final totals = <int, int>{
      for (final r in totalsRows) (r.data['cid'] as int): (r.data['total'] as int)
    };

    // Completed distinct questions by category for this user
    final doneRows = await _db.customSelect(
      'SELECT e.category_id AS cid, CAST(COUNT(DISTINCT aa.question_id) AS INTEGER) AS completed '
      'FROM attempts a '
      'JOIN attempt_answers aa ON aa.attempt_id = a.id '
      'JOIN exams e ON e.id = a.exam_id '
      'WHERE a.user_email = ? '
      'GROUP BY e.category_id',
      variables: [drift.Variable(userEmail)],
    ).get();
    final done = <int, int>{
      for (final r in doneRows) (r.data['cid'] as int): (r.data['completed'] as int)
    };

    // All categories in DB
    final cats = await _db.select(_db.categories).get();
    return [
      for (final c in cats)
        CategoryProgress(
          categoryId: c.id,
          name: c.name,
          imageUrl: c.imageUrl,
          completed: done[c.id] ?? 0,
          total: totals[c.id] ?? 0,
        )
    ];
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref.watch(dbProvider)));

final categoryProgressProvider = FutureProvider.family<List<CategoryProgress>, String>((ref, email) async {
  return ref.watch(progressRepositoryProvider).categoryProgressForUser(email);
});


