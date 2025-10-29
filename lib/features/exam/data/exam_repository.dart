import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamRepository {
  final AppDatabase _db;
  ExamRepository(this._db);

  Future<Exam?> getExam(int id) async {
    return await (_db.select(_db.exams)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<List<_QuestionWithOptions>> questionsForExam(int examId) async {
    final joins = await (_db.select(_db.examQuestions)
          ..where((e) => e.examId.equals(examId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.order)]))
        .get();
    final qIds = joins.map((j) => j.questionId).toSet().toList();
    if (qIds.isEmpty) return [];
    final qRows = await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
    final options = await (_db.select(_db.choices)..where((o) => o.questionId.isIn(qIds))..orderBy([(o) => drift.OrderingTerm.asc(o.order)])).get();
    return [
      for (final j in joins)
        _QuestionWithOptions(
          question: qRows.firstWhere((q) => q.id == j.questionId),
          options: options.where((o) => o.questionId == j.questionId).toList(),
        )
    ];
  }

  Future<List<_QuestionWithOptions>> questionsForCategory(int categoryId) async {
    // Collect question ids from all exams in this category (including subcategories)
    final examRows = await (_db.select(_db.exams)..where((e) => e.categoryId.equals(categoryId))).get();
    final subIds = await (_db.select(_db.subcategories)..where((s) => s.categoryId.equals(categoryId))).get().then((l)=>l.map((s)=>s.id).toList());
    final subExams = subIds.isEmpty
        ? <Exam>[]
        : await (_db.select(_db.exams)..where((e) => e.subcategoryId.isIn(subIds))).get();
    final allExamIds = {...examRows.map((e) => e.id), ...subExams.map((e) => e.id)}.toList();
    if (allExamIds.isEmpty) return [];
    final joins = await (_db.select(_db.examQuestions)
          ..where((j) => j.examId.isIn(allExamIds))
          ..orderBy([(j) => drift.OrderingTerm.asc(j.order)])).
        get();
    final qIds = joins.map((j) => j.questionId).toSet().toList();
    if (qIds.isEmpty) return [];
    final qs = await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
    final opts = await (_db.select(_db.choices)..where((o) => o.questionId.isIn(qIds))..orderBy([(o) => drift.OrderingTerm.asc(o.order)])).get();
    // Return in a stable order by question id
    qIds.sort();
    return [
      for (final id in qIds)
        _QuestionWithOptions(
          question: qs.firstWhere((q) => q.id == id),
          options: opts.where((o) => o.questionId == id).toList(),
        )
    ];
  }

  Future<int> startAttempt({required int examId, required String mode, required String userEmail}) async {
    final id = await _db.into(_db.attempts).insert(AttemptsCompanion(
          examId: drift.Value(examId),
          mode: drift.Value(mode),
          startedAt: drift.Value(DateTime.now()),
        ));
    // Set user_email via raw SQL to remain forward compatible without regenerated code
    await _db.customStatement('UPDATE attempts SET user_email = ? WHERE id = ?', [userEmail, id]);
    return id;
  }

  Future<Attempt?> findOngoingAttemptForExam(int examId, String userEmail) async {
    final row = await _db
        .customSelect('SELECT id FROM attempts WHERE exam_id = ? AND ended_at IS NULL AND user_email = ? ORDER BY started_at DESC LIMIT 1',
            variables: [drift.Variable(examId), drift.Variable(userEmail)])
        .getSingleOrNull();
    if (row == null) return null;
    final id = (row.data['id'] as int);
    return await (_db.select(_db.attempts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Attempt>> attemptsForExam(int examId, String userEmail) async {
    final rows = await _db.customSelect(
      'SELECT id, exam_id, mode, started_at, ended_at, score, score_percent, grade_label, synced FROM attempts WHERE exam_id = ? AND user_email = ? ORDER BY started_at DESC',
      variables: [drift.Variable(examId), drift.Variable(userEmail)],
    ).get();
    return rows
        .map((r) => Attempt(
              id: r.data['id'] as int,
              examId: r.data['exam_id'] as int,
              mode: r.data['mode'] as String,
              startedAt: DateTime.parse(r.data['started_at'] as String),
              endedAt: r.data['ended_at'] == null ? null : DateTime.parse(r.data['ended_at'] as String),
              score: r.data['score'] as int?,
              scorePercent: (r.data['score_percent'] as int?) ?? 0,
              gradeLabel: (r.data['grade_label'] as String?) ?? '',
              synced: ((r.data['synced'] as int?) ?? 0) == 1,
            ))
        .toList();
  }

  Future<Map<int, List<int>>> loadSelections(int attemptId) async {
    final rows = await (_db.select(_db.attemptAnswers)..where((a) => a.attemptId.equals(attemptId))).get();
    final map = <int, List<int>>{};
    for (final r in rows) {
      final list = (jsonDecode(r.selected) as List).map((e) => (e as num).toInt()).toList();
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

  Future<void> submitAttempt(int attemptId) async {
    // compute score using latest answer per question
    final answers = await (_db.select(_db.attemptAnswers)
          ..where((a) => a.attemptId.equals(attemptId))
          ..orderBy([(a) => drift.OrderingTerm.asc(a.id)])).
        get();
    final attempt = await (_db.select(_db.attempts)..where((a) => a.id.equals(attemptId))).getSingle();
    final exam = await (_db.select(_db.exams)..where((e) => e.id.equals(attempt.examId))).getSingle();
    final totalPoints = await (_db
            .customSelect('SELECT SUM(points) AS p FROM exam_questions WHERE exam_id = ?', variables: [drift.Variable(exam.id)])
            .getSingle())
        .then((r) => (r.data['p'] as int?) ?? 0);
    final latest = <int, AttemptAnswer>{};
    for (final a in answers) {
      latest[a.questionId] = a;
    }
    final scored = latest.values.fold<int>(0, (s, a) => s + (a.isCorrect ? a.points : 0));
    final percent = totalPoints == 0 ? 0 : ((scored * 100) ~/ totalPoints);
    // find grade band
    final bands = await (_db.select(_db.examGradeBands)..where((b) => b.examId.equals(exam.id))..orderBy([(b)=>drift.OrderingTerm.desc(b.minPercent)])).get();
    String label = '';
    for (final b in bands) {
      if (percent >= b.minPercent) { label = b.label; break; }
    }
    await (_db.update(_db.attempts)..where((t) => t.id.equals(attemptId))).write(AttemptsCompanion(
      endedAt: drift.Value(DateTime.now()),
      score: drift.Value(scored),
      scorePercent: drift.Value(percent),
      gradeLabel: drift.Value(label),
    ));
  }

  Future<Attempt?> findOngoingAttempt(String userEmail) async {
    final row = await _db
        .customSelect('SELECT id FROM attempts WHERE ended_at IS NULL AND user_email = ? ORDER BY started_at DESC LIMIT 1',
            variables: [drift.Variable(userEmail)])
        .getSingleOrNull();
    if (row == null) return null;
    final id = (row.data['id'] as int);
    return await (_db.select(_db.attempts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> countAnswers(int attemptId) async {
    final res = await _db.customSelect('SELECT COUNT(DISTINCT question_id) AS c FROM attempt_answers WHERE attempt_id = ?',
        variables: [drift.Variable(attemptId)]).getSingle();
    return (res.data['c'] as int?) ?? 0;
  }

  Future<void> submitReport({required int examId, required String userEmail, required String comment}) async {
    await _db.into(_db.reports).insert(ReportsCompanion.insert(
          examId: examId,
          userEmail: userEmail,
          comment: comment,
        ));
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
      await _db.into(_db.savedQuestions).insert(SavedQuestionsCompanion.insert(questionId: questionId, userEmail: userEmail));
    } else {
      await (_db.delete(_db.savedQuestions)..where((t) => t.id.equals(existing.id))).go();
    }
  }

  Future<List<Question>> savedQuestions(String userEmail) async {
    final saved = await (_db.select(_db.savedQuestions)..where((s) => s.userEmail.equals(userEmail))).get();
    if (saved.isEmpty) return [];
    final qIds = saved.map((s) => s.questionId).toList();
    return await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
  }

  Future<List<({Question question, List<Choice> options, List<int> selected, bool isCorrect})>> attemptReview(int attemptId) async {
    final attempt = await (_db.select(_db.attempts)..where((a) => a.id.equals(attemptId))).getSingle();
    final joins = await (_db.select(_db.examQuestions)
          ..where((j) => j.examId.equals(attempt.examId))
          ..orderBy([(j) => drift.OrderingTerm.asc(j.order)])).
        get();
    final qIds = joins.map((j) => j.questionId).toList();
    if (qIds.isEmpty) return [];
    final qs = await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
    final opts = await (_db.select(_db.choices)..where((o) => o.questionId.isIn(qIds))).get();
    final ans = await (_db.select(_db.attemptAnswers)..where((a) => a.attemptId.equals(attemptId))).get();
    final latest = <int, AttemptAnswer>{};
    for (final a in ans) {
      latest[a.questionId] = a;
    }
    return [
      for (final j in joins)
        (
          question: qs.firstWhere((q) => q.id == j.questionId),
          options: opts.where((o) => o.questionId == j.questionId).toList(),
          selected: (latest[j.questionId] == null)
              ? <int>[]
              : (List<int>.from((jsonDecode(latest[j.questionId]!.selected) as List).map((e) => (e as num).toInt()))),
          isCorrect: latest[j.questionId]?.isCorrect ?? false,
        )
    ];
  }
}

class _QuestionWithOptions {
  final Question question;
  final List<Choice> options;
  const _QuestionWithOptions({required this.question, required this.options});
}

final examRepositoryProvider = Provider<ExamRepository>((ref) => ExamRepository(ref.watch(dbProvider)));
