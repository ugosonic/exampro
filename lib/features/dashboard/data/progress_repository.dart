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
  const CategoryProgress({
    required this.categoryId,
    required this.name,
    required this.imageUrl,
    required this.completed,
    required this.total,
  });

  double get pct => total == 0 ? 0 : (completed / total).clamp(0, 1);
}

class ProgressRepository {
  final AppDatabase _db;
  final Dio _dio;
  ProgressRepository(this._db, this._dio);

  Future<List<CategoryProgress>> categoryProgressForUser(
    String userEmail,
  ) async {
    await _db.ensureClientSchema();

    // Compute totals from server snapshot when possible to avoid depending on local content
    Map<int, int> totals = {};
    List<Map<String, dynamic>> categories = [];
    List<Map<String, dynamic>> exams = [];
    // Load local categories to reflect immediate edits in names/images
    final localCats = await _db.select(_db.categories).get();
    final localMap = {
      for (final c in localCats)
        c.id: {'id': c.id, 'name': c.name, 'image_url': c.imageUrl},
    };
    try {
      final snap = await _dio.get('/sync/snapshot');
      exams = ((snap.data['exams'] as List?) ?? const [])
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
            'name':
                (localMap[(m['id'] as num).toInt()]?['name'] as String?) ??
                (m['name'] as String? ?? ''),
            'image_url':
                (localMap[(m['id'] as num).toInt()]?['image_url'] as String?) ??
                (m['image_url'] as String? ?? ''),
          },
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
      final totalsRows = await _db
          .customSelect(
            'SELECT e.category_id AS cid, CAST(COUNT(DISTINCT eq.question_id) AS INTEGER) AS total '
            'FROM exams e JOIN exam_questions eq ON e.id = eq.exam_id '
            'GROUP BY e.category_id',
          )
          .get();
      totals = <int, int>{
        for (final r in totalsRows)
          (r.data['cid'] as int): (r.data['total'] as int),
      };
      final catsRows = await _db.select(_db.categories).get();
      categories = [
        for (final c in catsRows)
          {'id': c.id, 'name': c.name, 'image_url': c.imageUrl},
      ];
    }

    final done = await _completedByCategory(userEmail: userEmail, exams: exams);

    return [
      for (final c in categories)
        CategoryProgress(
          categoryId: (c['id'] as num).toInt(),
          name: c['name'] as String,
          imageUrl: (c['image_url'] as String?) ?? '',
          completed: done[(c['id'] as num).toInt()] ?? 0,
          total: totals[(c['id'] as num).toInt()] ?? 0,
        ),
    ];
  }

  Future<Map<int, int>> _completedByCategory({
    required String userEmail,
    required List<Map<String, dynamic>> exams,
  }) async {
    // Prefer server-side progress so devices are consistent.
    try {
      final res = await _dio.get(
        '/sync/user-progress',
        queryParameters: {'email': userEmail},
      );
      final attempts = ((res.data['attempts'] as List?) ?? const [])
          .cast<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
      final answers = ((res.data['answers'] as List?) ?? const [])
          .cast<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();

      final examToCategory = <int, int>{};
      for (final e in exams) {
        final examId = e['id'];
        final categoryId = e['category_id'];
        if (examId is num && categoryId is num) {
          examToCategory[examId.toInt()] = categoryId.toInt();
        }
      }
      if (examToCategory.isEmpty) {
        final rows = await _db
            .customSelect('SELECT id, category_id FROM exams')
            .get();
        for (final r in rows) {
          final id = r.data['id'];
          final categoryId = r.data['category_id'];
          if (id is int && categoryId is int) {
            examToCategory[id] = categoryId;
          }
        }
      }

      final attemptToExam = <int, int>{};
      for (final a in attempts) {
        final id = a['id'];
        final examId = a['exam_id'];
        if (id is num && examId is num) {
          attemptToExam[id.toInt()] = examId.toInt();
        }
      }

      final doneSet = <int, Set<int>>{};
      for (final answer in answers) {
        final attemptId = answer['attempt_id'];
        final qid = answer['question_id'];
        if (attemptId is! num || qid is! num) continue;
        final examId = attemptToExam[attemptId.toInt()];
        if (examId == null) continue;
        final categoryId = examToCategory[examId];
        if (categoryId == null) continue;
        (doneSet[categoryId] ??= <int>{}).add(qid.toInt());
      }
      if (doneSet.isNotEmpty) {
        return {
          for (final entry in doneSet.entries) entry.key: entry.value.length,
        };
      }
    } catch (_) {}

    // Fallback to local DB; tolerate missing optional practice table.
    final hasPracticeAnswers = await _tableExists('practice_answers');
    final doneRows = await _db
        .customSelect(
          hasPracticeAnswers
              ? 'SELECT cid, CAST(COUNT(DISTINCT qid) AS INTEGER) AS completed FROM ('
                    '  SELECT e.category_id AS cid, aa.question_id AS qid '
                    '  FROM attempts a '
                    '  JOIN attempt_answers aa ON aa.attempt_id = a.id '
                    '  JOIN exams e ON e.id = a.exam_id '
                    '  WHERE a.user_email = ? '
                    '  UNION '
                    '  SELECT category_id AS cid, question_id AS qid FROM practice_answers WHERE user_email = ?'
                    ') t GROUP BY cid'
              : 'SELECT e.category_id AS cid, CAST(COUNT(DISTINCT aa.question_id) AS INTEGER) AS completed '
                    'FROM attempts a '
                    'JOIN attempt_answers aa ON aa.attempt_id = a.id '
                    'JOIN exams e ON e.id = a.exam_id '
                    'WHERE a.user_email = ? '
                    'GROUP BY e.category_id',
          variables: hasPracticeAnswers
              ? [drift.Variable(userEmail), drift.Variable(userEmail)]
              : [drift.Variable(userEmail)],
        )
        .get();
    return <int, int>{
      for (final r in doneRows)
        (r.data['cid'] as int): (r.data['completed'] as int),
    };
  }

  Future<bool> _tableExists(String table) async {
    final rows = await _db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: [drift.Variable(table)],
        )
        .get();
    return rows.isNotEmpty;
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(dbProvider), ref.watch(dioProvider)),
);

final categoryProgressProvider =
    FutureProvider.family<List<CategoryProgress>, String>((ref, email) async {
      return ref
          .watch(progressRepositoryProvider)
          .categoryProgressForUser(email);
    });

// Lightweight live-update wiring: when progressTickProvider changes, recompute
final progressTickProvider = StateProvider<int>((ref) => 0);
final liveCategoryProgressProvider =
    FutureProvider.family<List<CategoryProgress>, String>((ref, email) async {
      // Re-run when tick changes
      ref.watch(progressTickProvider);
      return ref
          .watch(progressRepositoryProvider)
          .categoryProgressForUser(email);
    });
