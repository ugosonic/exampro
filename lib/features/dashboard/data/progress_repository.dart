import 'package:drift/drift.dart' as drift;
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:dio/dio.dart';

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
  final Dio _dio;
  ProgressRepository(this._db, this._dio);

  Future<List<CategoryProgress>> categoryProgressForUser(String userEmail) async {
    // Compute totals from server snapshot when possible to avoid depending on local content
    Map<int, int> totals = {};
    List<Map<String, dynamic>> categories = [];
    // Load local categories to reflect immediate edits in names/images
    final localCats = await _db.select(_db.categories).get();
    final localMap = {for (final c in localCats) c.id: {'id': c.id, 'name': c.name, 'image_url': c.imageUrl}};
    try {
      final snap = await _dio.get('/sync/snapshot');
      final exams = ((snap.data['exams'] as List?) ?? const [])
          .cast<Map>()
          .map((m) => (m).cast<String, dynamic>())
          .toList();
      final examQs = ((snap.data['exam_questions'] as List?) ?? const [])
          .cast<Map>()
          .map((m) => (m).cast<String, dynamic>())
          .toList();
      final remoteCats = ((snap.data['categories'] as List?) ?? const [])
          .cast<Map>()
          .map((m) => (m).cast<String, dynamic>())
          .toList();
      categories = [
        for (final m in remoteCats)
          {
            'id': (m['id'] as num).toInt(),
            'name': (localMap[(m['id'] as num).toInt()]?['name'] as String?) ?? (m['name'] as String? ?? ''),
            'image_url': (localMap[(m['id'] as num).toInt()]?['image_url'] as String?) ?? (m['image_url'] as String? ?? ''),
          }
      ];
      final byExam = <int, Set<int>>{};
      for (final m in examQs) {
        final e = (m['exam_id'] as num).toInt();
        final q = (m['question_id'] as num).toInt();
        (byExam[e] ??= <int>{}).add(q);
      }
      totals = <int, int>{};
      for (final e in exams) {
        final cid = (e['category_id'] as num).toInt();
        final eid = (e['id'] as num).toInt();
        totals[cid] = (totals[cid] ?? 0) + (byExam[eid]?.length ?? 0);
      }
    } catch (_) {
      // Fallback to local DB for totals and categories
      final totalsRows = await _db.customSelect(
        'SELECT e.category_id AS cid, CAST(COUNT(DISTINCT eq.question_id) AS INTEGER) AS total '
        'FROM exams e JOIN exam_questions eq ON e.id = eq.exam_id '
        'GROUP BY e.category_id',
      ).get();
      totals = <int, int>{ for (final r in totalsRows) (r.data['cid'] as int): (r.data['total'] as int) };
      final catsRows = await _db.select(_db.categories).get();
      categories = [for (final c in catsRows) {'id': c.id, 'name': c.name, 'image_url': c.imageUrl}];
    }

    // Completed distinct questions by category for this user
    // Combine exam attempts and category practice answers (union of question_ids per category)
    final doneRows = await _db.customSelect(
      'SELECT cid, CAST(COUNT(DISTINCT qid) AS INTEGER) AS completed FROM ('
      '  SELECT e.category_id AS cid, aa.question_id AS qid '
      '  FROM attempts a '
      '  JOIN attempt_answers aa ON aa.attempt_id = a.id '
      '  JOIN exams e ON e.id = a.exam_id '
      '  WHERE a.user_email = ? '
      '  UNION '
      '  SELECT category_id AS cid, question_id AS qid FROM practice_answers WHERE user_email = ?'
      ') t GROUP BY cid',
      variables: [drift.Variable(userEmail), drift.Variable(userEmail)],
    ).get();
    final done = <int, int>{ for (final r in doneRows) (r.data['cid'] as int): (r.data['completed'] as int) };

    return [
      for (final c in categories)
        CategoryProgress(
          categoryId: (c['id'] as num).toInt(),
          name: c['name'] as String,
          imageUrl: (c['image_url'] as String?) ?? '',
          completed: done[(c['id'] as num).toInt()] ?? 0,
          total: totals[(c['id'] as num).toInt()] ?? 0,
        )
    ];
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref.watch(dbProvider), ref.watch(dioProvider)));

final categoryProgressProvider = FutureProvider.family<List<CategoryProgress>, String>((ref, email) async {
  return ref.watch(progressRepositoryProvider).categoryProgressForUser(email);
});

// Lightweight live-update wiring: when progressTickProvider changes, recompute
final progressTickProvider = StateProvider<int>((ref) => 0);
final liveCategoryProgressProvider = FutureProvider.family<List<CategoryProgress>, String>((ref, email) async {
  // Re-run when tick changes
  ref.watch(progressTickProvider);
  return ref.watch(progressRepositoryProvider).categoryProgressForUser(email);
});
