// C:\src\exampro\lib\features\exam\data\exam_repository.dart
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/features/catalog/data/content_api.dart';

class ExamRepository {
  final AppDatabase _db;
  final ContentApi? _remote;
  ExamRepository(this._db, [this._remote]);

  // ---------- robust JSON helpers (no .cast<...> anywhere) ----------
  Map<String, dynamic> _asMap(dynamic v) {
    if (v == null) return <String, dynamic>{};
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    throw StateError('Expected Map, got ${v.runtimeType}');
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic v) {
    if (v == null) return const <Map<String, dynamic>>[];
    if (v is List) {
      return v.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        throw StateError('Expected element Map, got ${e.runtimeType}');
      }).toList();
    }
    throw StateError('Expected List, got ${v.runtimeType}');
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
  // -------------------------------------------------------------------

  Future<Exam?> getExam(int id) async {
    // Local first
    final local =
        await (_db.select(_db.exams)..where((e) => e.id.equals(id))).getSingleOrNull();
    if (local != null) return local;

    // Remote fallback
    if (_remote != null) {
      final rows = await _remote.exams();
      final m = rows.firstWhere(
        (e) => _asInt(e['id']) == id,
        orElse: () => const <String, dynamic>{},
      );
      if (m.isEmpty) return null;
      return Exam(
        id: _asInt(m['id']) ?? id,
        title: (m['title'] as String?) ?? '',
        description: (m['description'] as String?) ?? '',
        categoryId: _asInt(m['category_id']) ?? 0,
        subcategoryId: _asInt(m['subcategory_id']),
        questionCount: _asInt(m['question_count']) ?? 0,
        published: (m['published'] as bool?) ?? false,
        timeLimitMinutes: _asInt(m['time_limit_minutes']) ?? 0,
        shuffleOptions: (m['shuffle_options'] as bool?) ?? true,
        negativeMarking: (m['negative_marking'] as bool?) ?? false,
        passPercent: _asInt(m['pass_percent']) ?? 60,
        themeKey: _asInt(m['theme_key']) ?? 0,
        pdfUrl: (m['pdf_url'] as String?) ?? '',
      );
    }
    return null;
  }

  Future<List<QuestionWithOptions>> questionsForExam(int examId) async {
    // Local first
    final joins = await (_db.select(_db.examQuestions)
          ..where((e) => e.examId.equals(examId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.order)]))
        .get();
    final qIds = joins.map((j) => j.questionId).toSet().toList();

    if (qIds.isNotEmpty) {
      final qRows =
          await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
      final options = await (_db.select(_db.choices)
            ..where((o) => o.questionId.isIn(qIds))
            ..orderBy([(o) => drift.OrderingTerm.asc(o.order)]))
          .get();
      final lang = await _lang();

      return [
        for (final j in joins)
          QuestionWithOptions(
            question:
                await _translateQuestion(qRows.firstWhere((q) => q.id == j.questionId), lang),
            options: [
              for (final o in options.where((o) => o.questionId == j.questionId))
                await _translateChoice(o, lang)
            ],
          )
      ];
    }

    // Remote fallback
    if (_remote != null) {
      final data = await _remote.examQuestions(examId);
      final order = _asListOfMap(data['order']);
      final qs = _asListOfMap(data['questions']);
      final cs = _asListOfMap(data['choices']);
      final lang = await _lang();

      Question mapQ(int qid) {
        final m = qs.firstWhere((q) => _asInt(q['id']) == qid,
            orElse: () => const <String, dynamic>{});
        if (m.isEmpty) {
          return Question(
              id: qid, body: '', explanation: '', multiple: false, locked: false);
        }
        return Question(
          id: _asInt(m['id']) ?? qid,
          body: (m['body'] as String?) ?? '',
          explanation: (m['explanation'] as String?) ?? '',
          multiple: (m['multiple'] as bool?) ?? false,
          locked: (m['locked'] as bool?) ?? false,
        );
      }

      return [
        for (final j in order)
          QuestionWithOptions(
            question: await _translateQuestion(mapQ(_asInt(j['question_id']) ?? 0), lang),
            options: [
              for (final o in (cs
                    .where((o) => _asInt(o['question_id']) == _asInt(j['question_id']))
                    .toList()
                  ..sort((a, b) =>
                      (_asInt(a['order']) ?? 0).compareTo(_asInt(b['order']) ?? 0))))
                await _translateChoice(
                  Choice(
                    id: _asInt(o['id']) ?? 0,
                    questionId: _asInt(o['question_id']) ?? 0,
                    label: (o['label'] as String?) ?? '',
                    isCorrect: (o['is_correct'] as bool?) ?? false,
                    order: _asInt(o['order']) ?? 0,
                  ),
                  lang,
                )
            ],
          ),
      ];
    }
    return [];
  }

  Future<List<QuestionWithOptions>> questionsForCategory(int categoryId) async {
    // Local aggregate across category & its subcategories
    final examRows =
        await (_db.select(_db.exams)..where((e) => e.categoryId.equals(categoryId))).get();
    final subIds = await (_db.select(_db.subcategories)
            ..where((s) => s.categoryId.equals(categoryId)))
        .get()
        .then((l) => l.map((s) => s.id).toList());
    final subExams = subIds.isEmpty
        ? <Exam>[]
        : await (_db.select(_db.exams)..where((e) => e.subcategoryId.isIn(subIds))).get();

    final allExamIds = {...examRows.map((e) => e.id), ...subExams.map((e) => e.id)}.toList();
    if (allExamIds.isNotEmpty) {
      final joins = await (_db.select(_db.examQuestions)
            ..where((j) => j.examId.isIn(allExamIds))
            ..orderBy([(j) => drift.OrderingTerm.asc(j.order)]))
          .get();
      if (joins.isNotEmpty) {
        final uniqueIds = <int>[];
        final seen = <int>{};
        for (final j in joins) {
          if (seen.add(j.questionId)) uniqueIds.add(j.questionId);
        }
        if (uniqueIds.isNotEmpty) {
          final qs =
              await (_db.select(_db.questions)..where((q) => q.id.isIn(uniqueIds))).get();
          final qMap = {for (final q in qs) q.id: q};
          final opts = await (_db.select(_db.choices)
                ..where((o) => o.questionId.isIn(uniqueIds))
                ..orderBy([(o) => drift.OrderingTerm.asc(o.order)]))
              .get();
          final optMap = <int, List<Choice>>{};
          for (final o in opts) {
            optMap.putIfAbsent(o.questionId, () => <Choice>[]).add(o);
          }
          final lang = await _lang();
          final out = <QuestionWithOptions>[];
          for (final id in uniqueIds) {
            final question = qMap[id];
            if (question == null) continue;
            final optionList = optMap[id];
            if (optionList == null || optionList.isEmpty) continue;
            out.add(QuestionWithOptions(
              question: await _translateQuestion(question, lang),
              options: [for (final o in optionList) await _translateChoice(o, lang)],
            ));
          }
          if (out.isNotEmpty) return out;
        }
      }
    }

    // Remote fallback: expand each exam in the category
    if (_remote != null) {
      final exs = await _remote.exams(categoryId: categoryId);
      final out = <QuestionWithOptions>[];
      for (final e in exs) {
        final id = _asInt(e['id']);
        if (id == null) continue;
        final part = await questionsForExam(id);
        out.addAll(part);
      }
      return out;
    }
    return [];
  }

  Future<int> startAttempt({
    required int examId,
    required String mode,
    required String userEmail,
  }) async {
    final id = await _db.into(_db.attempts).insert(AttemptsCompanion(
          examId: drift.Value(examId),
          mode: drift.Value(mode),
          startedAt: drift.Value(DateTime.now()),
        ));
    await _db.customStatement(
      'UPDATE attempts SET user_email = ? WHERE id = ?',
      [userEmail, id],
    );
    return id;
  }

  Future<Attempt?> findOngoingAttemptForExam(int examId, String userEmail) async {
    final row = await _db
        .customSelect(
          'SELECT id FROM attempts '
          'WHERE exam_id = ? AND ended_at IS NULL AND user_email = ? '
          'ORDER BY started_at DESC LIMIT 1',
          variables: [drift.Variable(examId), drift.Variable(userEmail)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final id = (row.data['id'] as int);
    return await (_db.select(_db.attempts)..where((t) => t.id.equals(id))).getSingleOrNull();
    }

  Future<List<Attempt>> attemptsForExam(int examId, String userEmail) async {
    final rows = await _db.customSelect(
      'SELECT id, exam_id, mode, started_at, ended_at, score, score_percent, '
      'grade_label, synced FROM attempts WHERE exam_id = ? AND user_email = ? '
      'ORDER BY started_at DESC',
      variables: [drift.Variable(examId), drift.Variable(userEmail)],
    ).get();
    final list = <Attempt>[];
    for (final r in rows) {
      final d = r.data;
      list.add(Attempt(
        id: d['id'] as int,
        examId: d['exam_id'] as int,
        mode: d['mode'] as String,
        startedAt: DateTime.parse(d['started_at'] as String),
        endedAt: d['ended_at'] == null ? null : DateTime.parse(d['ended_at'] as String),
        score: d['score'] as int?,
        scorePercent: (d['score_percent'] as int?) ?? 0,
        gradeLabel: (d['grade_label'] as String?) ?? '',
        synced: ((d['synced'] as int?) ?? 0) == 1,
        userEmail: userEmail,
      ));
    }
    return list;
  }

  Future<Map<int, List<int>>> loadSelections(int attemptId) async {
    final rows =
        await (_db.select(_db.attemptAnswers)..where((a) => a.attemptId.equals(attemptId)))
            .get();
    final map = <int, List<int>>{};
    for (final r in rows) {
      final list = (jsonDecode(r.selected) as List)
          .map((e) => (e as num).toInt())
          .toList();
      map[r.questionId] = list;
    }
    return map;
  }

  Future<void> saveAnswer({
    required int attemptId,
    required int questionId,
    required List<int> selectedOptionIds,
    required int points,
    required bool isCorrect,
    int timeMs = 0,
  }) async {
    await (_db.delete(_db.attemptAnswers)
          ..where((a) => a.attemptId.equals(attemptId) & a.questionId.equals(questionId)))
        .go();
    await _db.into(_db.attemptAnswers).insert(AttemptAnswersCompanion(
      attemptId: drift.Value(attemptId),
      questionId: drift.Value(questionId),
      selected: drift.Value(jsonEncode(selectedOptionIds)),
      timeMs: drift.Value(timeMs),
      isCorrect: drift.Value(isCorrect),
      points: drift.Value(points),
    ));
  }

  // ---------- Practice (category) progress/answers ----------
  Future<int> practiceProgress({required int categoryId, required String userEmail}) async {
    try {
      final row = await _db.customSelect(
        'SELECT index FROM practice_progress WHERE category_id = ? AND user_email = ? LIMIT 1',
        variables: [drift.Variable(categoryId), drift.Variable(userEmail)],
      ).getSingleOrNull();
      return (row == null) ? 0 : (((row.data['index'] as num?) ?? 0).toInt());
    } catch (_) {
      return 0;
    }
  }

  Future<void> savePracticeProgress({required int categoryId, required String userEmail, required int index}) async {
    try {
      await _db.customStatement(
        'INSERT INTO practice_progress(category_id, user_email, index, updated_at) VALUES (?,?,?,CURRENT_TIMESTAMP) '
        'ON CONFLICT(user_email, category_id) DO UPDATE SET index = excluded.index, updated_at = excluded.updated_at',
        [categoryId, userEmail, index],
      );
    } catch (_) {}
  }

  Future<void> resetPracticeProgress({required int categoryId, required String userEmail}) async {
    try {
      await _db.customStatement('DELETE FROM practice_progress WHERE category_id = ? AND user_email = ?', [categoryId, userEmail]);
    } catch (_) {}
  }

  Future<void> savePracticeAnswer({
    required int categoryId,
    required int questionId,
    required String userEmail,
    required bool isCorrect,
  }) async {
    try {
      await _db.customStatement(
        'INSERT INTO practice_answers(user_email, category_id, question_id, is_correct, updated_at) VALUES (?,?,?,?,CURRENT_TIMESTAMP) '
        'ON CONFLICT(user_email, question_id) DO UPDATE SET is_correct = excluded.is_correct, updated_at = excluded.updated_at',
        [userEmail, categoryId, questionId, isCorrect ? 1 : 0],
      );
    } catch (_) {}
  }

  Future<void> submitAttempt(int attemptId) async {
    // Gather answers (latest per question)
    final answers = await (_db.select(_db.attemptAnswers)
          ..where((a) => a.attemptId.equals(attemptId))
          ..orderBy([(a) => drift.OrderingTerm.asc(a.id)]))
        .get();
    final attempt = await (_db.select(_db.attempts)..where((a) => a.id.equals(attemptId))).getSingle();

    // Try local exam first; fall back to remote metadata
    Exam? exam = await (_db.select(_db.exams)..where((e) => e.id.equals(attempt.examId))).getSingleOrNull();
    int passPercent = 60;
    if (exam == null && _remote != null) {
      try {
        final rows = await _remote!.exams();
        final m = rows.firstWhere((e) => _asInt(e['id']) == attempt.examId, orElse: () => const <String, dynamic>{});
        if (m.isNotEmpty) {
          passPercent = _asInt(m['pass_percent']) ?? 60;
        }
      } catch (_) {}
    } else if (exam != null) {
      passPercent = exam.passPercent;
    }

    // Compute total points; local join sum if present, else from remote order length/points, else answers count
    int totalPoints = 0;
    try {
      totalPoints = await (_db
              .customSelect(
                'SELECT COALESCE(SUM(points),0) AS p FROM exam_questions WHERE exam_id = ?',
                variables: [drift.Variable(attempt.examId)],
              )
              .getSingle())
          .then((r) => (r.data['p'] as int?) ?? 0);
    } catch (_) {
      totalPoints = 0;
    }
    if (totalPoints == 0 && _remote != null) {
      try {
        final data = await _remote!.examQuestions(attempt.examId);
        final order = _asListOfMap(data['order']);
        // Sum provided points if present, otherwise 1 per question
        totalPoints = order.fold<int>(0, (s, j) => s + (_asInt(j['points']) ?? 1));
        if (totalPoints == 0) totalPoints = order.length;
        if (totalPoints == 0) totalPoints = answers.length; // last resort
      } catch (_) {
        totalPoints = answers.length; // last resort
      }
    }

    final latest = <int, AttemptAnswer>{};
    for (final a in answers) {
      latest[a.questionId] = a;
    }
    final scored = latest.values.fold<int>(0, (s, a) => s + (a.isCorrect ? (a.points) : 0));
    final percent = totalPoints <= 0 ? 0 : ((scored * 100) ~/ totalPoints);

    // Grade label: use bands if available locally; otherwise simple pass/fail against passPercent
    String label = '';
    try {
      final bands = await (_db.select(_db.examGradeBands)
            ..where((b) => b.examId.equals(attempt.examId))
            ..orderBy([(b) => drift.OrderingTerm.desc(b.minPercent)]))
          .get();
      for (final b in bands) {
        if (percent >= b.minPercent) {
          label = b.label;
          break;
        }
      }
    } catch (_) {}
    if (label.isEmpty && passPercent > 0) {
      label = percent >= passPercent ? 'Pass' : '';
    }

    await (_db.update(_db.attempts)..where((t) => t.id.equals(attemptId))).write(
      AttemptsCompanion(
        endedAt: drift.Value(DateTime.now()),
        score: drift.Value(scored),
        scorePercent: drift.Value(percent),
        gradeLabel: drift.Value(label),
      ),
    );
  }

  Future<Attempt?> findOngoingAttempt(String userEmail) async {
    final row = await _db
        .customSelect(
          'SELECT id FROM attempts WHERE ended_at IS NULL AND user_email = ? '
          'ORDER BY started_at DESC LIMIT 1',
          variables: [drift.Variable(userEmail)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final id = (row.data['id'] as int);
    return await (_db.select(_db.attempts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> countAnswers(int attemptId) async {
    final res = await _db
        .customSelect(
          'SELECT COUNT(DISTINCT question_id) AS c FROM attempt_answers WHERE attempt_id = ?',
          variables: [drift.Variable(attemptId)],
        )
        .getSingle();
    return (res.data['c'] as int?) ?? 0;
  }

  Future<void> submitReport({
    required int examId,
    required String userEmail,
    required String comment,
  }) async {
    await _db.into(_db.reports).insert(
          ReportsCompanion.insert(
            examId: examId,
            userEmail: userEmail,
            comment: comment,
          ),
        );
  }

  // PDF progress
  Future<int> pdfProgress({required int examId, required String userEmail}) async {
    try {
      final row = await _db
          .customSelect(
            'SELECT page FROM pdf_progress WHERE exam_id = ? AND user_email = ? LIMIT 1',
            variables: [drift.Variable(examId), drift.Variable(userEmail)],
          )
          .getSingleOrNull();
      return (row == null) ? 0 : (((row.data['page'] as num?) ?? 0).toInt());
    } catch (_) {
      return 0;
    }
  }

  Future<void> savePdfProgress({
    required int examId,
    required String userEmail,
    required int page,
  }) async {
    try {
      await _db.customStatement(
        'INSERT INTO pdf_progress(exam_id, user_email, page, updated_at) VALUES (?,?,?,CURRENT_TIMESTAMP) '
        'ON CONFLICT(user_email, exam_id) DO UPDATE SET page = excluded.page, updated_at = excluded.updated_at',
        [examId, userEmail, page],
      );
    } catch (_) {}
  }

  Future<bool> isSaved({required int questionId, required String userEmail}) async {
    final res = await (_db.select(_db.savedQuestions)
          ..where((t) => t.questionId.equals(questionId) & t.userEmail.equals(userEmail)))
        .getSingleOrNull();
    return res != null;
  }

  Future<void> toggleSaved({required int questionId, required String userEmail}) async {
    final existing = await (_db.select(_db.savedQuestions)
          ..where((t) => t.questionId.equals(questionId) & t.userEmail.equals(userEmail)))
        .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.savedQuestions)
          .insert(SavedQuestionsCompanion.insert(questionId: questionId, userEmail: userEmail));
    } else {
      await (_db.delete(_db.savedQuestions)..where((t) => t.id.equals(existing.id))).go();
    }
  }

  Future<List<Question>> savedQuestions(String userEmail) async {
    final saved =
        await (_db.select(_db.savedQuestions)..where((s) => s.userEmail.equals(userEmail))).get();
    if (saved.isEmpty) return [];
    final qIds = saved.map((s) => s.questionId).toList();
    final qs = await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
    final lang = await _lang();
    return [for (final q in qs) await _translateQuestion(q, lang)];
  }

  Future<List<({Question question, List<Choice> options, List<int> selected, bool isCorrect})>>
      attemptReview(int attemptId) async {
    final attempt =
        await (_db.select(_db.attempts)..where((a) => a.id.equals(attemptId))).getSingle();
    final joins = await (_db.select(_db.examQuestions)
          ..where((j) => j.examId.equals(attempt.examId))
          ..orderBy([(j) => drift.OrderingTerm.asc(j.order)]))
        .get();
    final qIds = joins.map((j) => j.questionId).toList();
    if (qIds.isEmpty) return [];
    final qs = await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
    final opts =
        await (_db.select(_db.choices)..where((o) => o.questionId.isIn(qIds))).get();
    final ans =
        await (_db.select(_db.attemptAnswers)..where((a) => a.attemptId.equals(attemptId))).get();
    final latest = <int, AttemptAnswer>{};
    for (final a in ans) {
      latest[a.questionId] = a;
    }
    final lang = await _lang();
    return [
      for (final j in joins)
        (
          question: await _translateQuestion(qs.firstWhere((q) => q.id == j.questionId), lang),
          options: [
            for (final o in opts.where((o) => o.questionId == j.questionId))
              await _translateChoice(o, lang)
          ],
          selected: (latest[j.questionId] == null)
              ? <int>[]
              : (List<int>.from(
                  (jsonDecode(latest[j.questionId]!.selected) as List).map((e) => (e as num).toInt()))),
          isCorrect: latest[j.questionId]?.isCorrect ?? false,
        )
    ];
  }
}

class QuestionWithOptions {
  final Question question;
  final List<Choice> options;
  const QuestionWithOptions({required this.question, required this.options});
}

extension on ExamRepository {
  Future<String> _lang() async {
    try {
      final row = await (_db.select(_db.appSettings)
            ..where((s) => s.key.equals('lang_code')))
          .getSingleOrNull();
      return row?.value.isNotEmpty == true ? row!.value : 'en';
    } catch (_) {
      return 'en';
    }
  }

  Future<Question> _translateQuestion(Question q, String lang) async {
    if (lang == 'en') return q;
    try {
      final row = await _db.customSelect(
        'SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
        variables: [
          drift.Variable('questions'),
          drift.Variable(q.id),
          drift.Variable(lang),
          drift.Variable('body')
        ],
      ).getSingleOrNull();
      final body = row == null ? q.body : ((row.data['v'] as String?) ?? q.body);

      final expRow = await _db.customSelect(
        'SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
        variables: [
          drift.Variable('questions'),
          drift.Variable(q.id),
          drift.Variable(lang),
          drift.Variable('explanation')
        ],
      ).getSingleOrNull();
      final explanation = expRow == null ? q.explanation : ((expRow.data['v'] as String?) ?? q.explanation);

      return Question(id: q.id, body: body, explanation: explanation, multiple: q.multiple, locked: q.locked);
    } catch (_) {
      return q;
    }
  }

  Future<Choice> _translateChoice(Choice c, String lang) async {
    if (lang == 'en') return c;
    try {
      final row = await _db.customSelect(
        'SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
        variables: [
          drift.Variable('choices'),
          drift.Variable(c.id),
          drift.Variable(lang),
          drift.Variable('label')
        ],
      ).getSingleOrNull();
      final label = row == null ? c.label : ((row.data['v'] as String?) ?? c.label);
      return Choice(id: c.id, questionId: c.questionId, label: label, isCorrect: c.isCorrect, order: c.order);
    } catch (_) {
      return c;
    }
  }
}

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  final hasApi = env != null && env.apiBaseUrl.isNotEmpty;
  final remote = hasApi ? ref.watch(contentApiProvider) : null;
  return ExamRepository(dbi, remote);
});
