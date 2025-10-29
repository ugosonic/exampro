import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminRepository {
  final AppDatabase _db;
  AdminRepository(this._db);

  Future<int> createCategory(String name, {int order = 0, String imageUrl = ''}) async {
    return _db.into(_db.categories).insert(CategoriesCompanion.insert(
          name: name,
          order: drift.Value(order),
          imageUrl: drift.Value(imageUrl),
        ));
  }

  Future<int> createSubcategory(int categoryId, String name, {int order = 0, String imageUrl = ''}) async {
    return _db.into(_db.subcategories).insert(SubcategoriesCompanion.insert(
          categoryId: categoryId,
          name: name,
          order: drift.Value(order),
          imageUrl: drift.Value(imageUrl),
        ));
  }

  Future<int> createExam({
    required String title,
    String description = '',
    required int categoryId,
    int? subcategoryId,
    int timeLimitMinutes = 0,
    int passPercent = 60,
    bool shuffleOptions = true,
    bool negativeMarking = false,
    bool published = false,
    int themeKey = 0,
  }) async {
    final id = await _db.into(_db.exams).insert(ExamsCompanion.insert(
          title: title,
          description: drift.Value(description),
          categoryId: categoryId,
          subcategoryId: drift.Value(subcategoryId),
          timeLimitMinutes: drift.Value(timeLimitMinutes),
          passPercent: drift.Value(passPercent),
          shuffleOptions: drift.Value(shuffleOptions),
          negativeMarking: drift.Value(negativeMarking),
          published: drift.Value(published),
          themeKey: drift.Value(themeKey),
        ));
    // default grade bands
    await _db.batch((b) {
      b.insertAll(_db.examGradeBands, [
        ExamGradeBandsCompanion.insert(examId: id, minPercent: 90, label: 'Distinction'),
        ExamGradeBandsCompanion.insert(examId: id, minPercent: 75, label: 'Merit'),
        ExamGradeBandsCompanion.insert(examId: id, minPercent: passPercent, label: 'Pass'),
      ]);
    });
    return id;
  }

  Future<int> addQuestionWithOptions({
    required int examId,
    required String text,
    String explanation = '',
    required List<({String text, bool correct})> options,
    int points = 1,
    int order = 0,
  }) async {
    return await _db.transaction(() async {
      final qId = await _db
          .into(_db.questions)
          .insert(QuestionsCompanion.insert(body: text, explanation: drift.Value(explanation)));
      await _db.batch((b) {
        b.insertAll(_db.choices, [
          for (var i = 0; i < options.length; i++)
            ChoicesCompanion.insert(
              questionId: qId,
              label: options[i].text,
              isCorrect: drift.Value(options[i].correct),
              order: drift.Value(i),
            )
        ]);
      });
      await _db.into(_db.examQuestions).insert(
            ExamQuestionsCompanion.insert(examId: examId, questionId: qId, order: drift.Value(order), points: drift.Value(points)),
          );
      // update exam.questionCount
      final count = await _db.customSelect('SELECT COUNT(*) AS c FROM exam_questions WHERE exam_id = ?',
              variables: [drift.Variable(examId)])
          .getSingle()
          .then((r) => (r.data['c'] as int?) ?? 0);
      await (_db.update(_db.exams)..where((e) => e.id.equals(examId))).write(ExamsCompanion(questionCount: drift.Value(count)));
      return qId;
    });
  }

  Stream<List<Category>> watchCategories() => _db.select(_db.categories).watch();
  Stream<List<Subcategory>> watchSubcategories(int categoryId) =>
      (_db.select(_db.subcategories)..where((s) => s.categoryId.equals(categoryId))).watch();
  Future<List<Subcategory>> allSubcategories() async => _db.select(_db.subcategories).get();

  Future<List<Category>> categories() async {
    return await _db.select(_db.categories).get();
  }

  // Users
  Stream<List<DbUser>> watchUsers() => _db.select(_db.users).watch();
  Future<List<DbUser>> allUsers() async => _db.select(_db.users).get();

  Future<void> updateCategory(int id, {String? name, int? order, int? passPercent, String? imageUrl}) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(
          name: name != null ? drift.Value(name) : const drift.Value.absent(),
          order: order != null ? drift.Value(order) : const drift.Value.absent(),
          passPercent: passPercent != null ? drift.Value(passPercent) : const drift.Value.absent(),
          imageUrl: imageUrl != null ? drift.Value(imageUrl) : const drift.Value.absent(),
        ));
  }

  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  Future<Category?> getCategory(int id) async {
    return await (_db.select(_db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateSubcategory(int id, {String? name, int? order, String? imageUrl, bool? locked}) async {
    await (_db.update(_db.subcategories)..where((s) => s.id.equals(id))).write(SubcategoriesCompanion(
          name: name != null ? drift.Value(name) : const drift.Value.absent(),
          order: order != null ? drift.Value(order) : const drift.Value.absent(),
          imageUrl: imageUrl != null ? drift.Value(imageUrl) : const drift.Value.absent(),
          locked: locked != null ? drift.Value(locked) : const drift.Value.absent(),
        ));
  }

  Future<List<Subcategory>> subcategories(int categoryId) async {
    return await (_db.select(_db.subcategories)..where((s) => s.categoryId.equals(categoryId))).get();
  }

  Future<void> deleteSubcategory(int id) async {
    await (_db.delete(_db.subcategories)..where((s) => s.id.equals(id))).go();
  }

  // Questions management
  Future<List<Question>> allQuestions({int limit = 200}) async {
    final q = _db.select(_db.questions)..orderBy([(t) => drift.OrderingTerm.desc(t.id)])..limit(limit);
    return q.get();
  }

  Stream<List<Question>> watchQuestions({int limit = 200}) {
    final q = _db.select(_db.questions)..orderBy([(t) => drift.OrderingTerm.desc(t.id)])..limit(limit);
    return q.watch();
  }

  Future<List<Category>> categoriesForQuestion(int questionId) async {
    final joins = await (_db.select(_db.questionCategories)..where((qc) => qc.questionId.equals(questionId))).get();
    if (joins.isEmpty) return [];
    final catIds = joins.map((e) => e.categoryId).toList();
    return await (_db.select(_db.categories)..where((c) => c.id.isIn(catIds))).get();
  }

  Future<void> setCategoriesForQuestion(int questionId, List<int> categoryIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.questionCategories)..where((qc) => qc.questionId.equals(questionId))).go();
      if (categoryIds.isEmpty) return;
      await _db.batch((b) {
        b.insertAll(_db.questionCategories, [
          for (final id in categoryIds)
            QuestionCategoriesCompanion.insert(questionId: questionId, categoryId: id),
        ]);
      });
    });
  }

  Future<List<Subcategory>> subcategoriesForQuestion(int questionId) async {
    final joins = await (_db.select(_db.questionSubcategories)..where((qs) => qs.questionId.equals(questionId))).get();
    if (joins.isEmpty) return [];
    final ids = joins.map((e) => e.subcategoryId).toList();
    return await (_db.select(_db.subcategories)..where((s) => s.id.isIn(ids))).get();
  }

  Future<void> setSubcategoriesForQuestion(int questionId, List<int> subcategoryIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.questionSubcategories)..where((qs) => qs.questionId.equals(questionId))).go();
      if (subcategoryIds.isEmpty) return;
      await _db.batch((b) {
        b.insertAll(_db.questionSubcategories, [
          for (final id in subcategoryIds) QuestionSubcategoriesCompanion.insert(questionId: questionId, subcategoryId: id),
        ]);
      });
    });
  }

  Future<void> deleteQuestion(int questionId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.choices)..where((t) => t.questionId.equals(questionId))).go();
      await (_db.delete(_db.examQuestions)..where((t) => t.questionId.equals(questionId))).go();
      await (_db.delete(_db.questionCategories)..where((t) => t.questionId.equals(questionId))).go();
      await (_db.delete(_db.questions)..where((t) => t.id.equals(questionId))).go();
    });
  }

  // Exams
  Stream<List<Exam>> watchExams() => _db.select(_db.exams).watch();
  Future<void> setExamPublished(int examId, bool published) async {
    await (_db.update(_db.exams)..where((t) => t.id.equals(examId))).write(ExamsCompanion(published: drift.Value(published)));
  }
  Future<void> deleteExam(int examId) async {
    await _db.transaction(() async {
      // Remove attempt answers, attempts, joins, grade bands, reports, then exam
      final attemptsForExam = await (_db.select(_db.attempts)..where((a) => a.examId.equals(examId))).get();
      final attemptIds = attemptsForExam.map((a) => a.id).toList();
      if (attemptIds.isNotEmpty) {
        await (_db.delete(_db.attemptAnswers)..where((aa) => aa.attemptId.isIn(attemptIds))).go();
        await (_db.delete(_db.attempts)..where((a) => a.id.isIn(attemptIds))).go();
      }
      await (_db.delete(_db.examQuestions)..where((eq) => eq.examId.equals(examId))).go();
      await (_db.delete(_db.examGradeBands)..where((g) => g.examId.equals(examId))).go();
      await (_db.delete(_db.reports)..where((r) => r.examId.equals(examId))).go();
      await (_db.delete(_db.exams)..where((e) => e.id.equals(examId))).go();
    });
  }
  Future<List<({Question question, List<Choice> options, ExamQuestion join})>> examQuestions(int examId) async {
    final joins = await (_db.select(_db.examQuestions)
          ..where((e) => e.examId.equals(examId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.order)])).
        get();
    final qIds = joins.map((j) => j.questionId).toList();
    if (qIds.isEmpty) return [];
    final qs = await (_db.select(_db.questions)..where((q) => q.id.isIn(qIds))).get();
    final opts = await (_db.select(_db.choices)..where((o) => o.questionId.isIn(qIds))).get();
    return [
      for (final j in joins)
        (
          question: qs.firstWhere((q) => q.id == j.questionId),
          options: opts.where((o) => o.questionId == j.questionId).toList(),
          join: j,
        )
    ];
  }

  Future<void> reorderExamQuestions(int examId, List<int> questionIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < questionIds.length; i++) {
        await (_db.update(_db.examQuestions)
              ..where((t) => t.examId.equals(examId) & t.questionId.equals(questionIds[i])))
            .write(ExamQuestionsCompanion(order: drift.Value(i)));
      }
    });
  }

  Future<void> removeQuestionFromExam(int examId, int questionId) async {
    await (_db.delete(_db.examQuestions)..where((t) => t.examId.equals(examId) & t.questionId.equals(questionId))).go();
    final count = await _db.customSelect('SELECT COUNT(*) AS c FROM exam_questions WHERE exam_id = ?', variables: [drift.Variable(examId)])
        .getSingle()
        .then((r) => (r.data['c'] as int?) ?? 0);
    await (_db.update(_db.exams)..where((e) => e.id.equals(examId))).write(ExamsCompanion(questionCount: drift.Value(count)));
  }

  Future<void> updateQuestionAndOptions({required int questionId, required String body, String explanation = '', required List<({String text, bool correct})> options}) async {
    await _db.transaction(() async {
      await (_db.update(_db.questions)..where((q) => q.id.equals(questionId))).write(QuestionsCompanion(body: drift.Value(body), explanation: drift.Value(explanation)));
      await (_db.delete(_db.choices)..where((o) => o.questionId.equals(questionId))).go();
      await _db.batch((b) {
        b.insertAll(_db.choices, [
          for (var i = 0; i < options.length; i++)
            ChoicesCompanion.insert(questionId: questionId, label: options[i].text, isCorrect: drift.Value(options[i].correct), order: drift.Value(i))
        ]);
      });
    });
  }

  Future<void> setCategoryLocked(int id, bool locked) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(locked: drift.Value(locked)));
  }

  Future<void> setQuestionLocked(int id, bool locked) async {
    await (_db.update(_db.questions)..where((q) => q.id.equals(id))).write(QuestionsCompanion(locked: drift.Value(locked)));
  }

  // App settings (e.g., prices)
  Future<void> setSetting(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(AppSettingsCompanion(key: drift.Value(key), value: drift.Value(value)));
  }
  Future<String?> getSetting(String key) async {
    final row = await (_db.select(_db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // Payments
  Future<List<Payment>> listPayments({int limit = 50, int offset = 0}) async {
    return await (_db.select(_db.payments)
          ..orderBy([(p) => drift.OrderingTerm.desc(p.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<int> addPayment({required String email, required int amountMinor, required String currency, String intentId = '', String status = 'paid'}) async {
    return await _db.into(_db.payments).insert(PaymentsCompanion.insert(userEmail: email, amountMinor: amountMinor, currency: currency, stripePaymentIntentId: drift.Value(intentId), status: drift.Value(status)));
  }

  Future<void> markRefunded(int id) async {
    await (_db.update(_db.payments)..where((p) => p.id.equals(id))).write(PaymentsCompanion(refunded: const drift.Value(true), status: const drift.Value('refunded')));
  }

  Future<void> setUserPro(String email, bool isPro) async {
    await (_db.update(_db.users)..where((u) => u.email.equals(email))).write(UsersCompanion(isPro: drift.Value(isPro)));
  }

  // Reports
  Future<List<({Report report, Exam exam})>> listReports({bool unresolvedOnly = false, int limit = 200, int offset = 0}) async {
    final query = _db.select(_db.reports)
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);
    if (unresolvedOnly) {
      query.where((r) => r.resolved.equals(false));
    }
    final reps = await query.get();
    final examIds = reps.map((r) => r.examId).toSet().toList();
    final exams = await (_db.select(_db.exams)..where((e) => e.id.isIn(examIds))).get();
    return [for (final r in reps) (report: r, exam: exams.firstWhere((e) => e.id == r.examId))];
  }
  Future<void> deleteReport(int id) async {
    await (_db.delete(_db.reports)..where((r) => r.id.equals(id))).go();
  }

  Future<void> markReportResolved(int id, bool resolved) async {
    await (_db.update(_db.reports)..where((r) => r.id.equals(id))).write(ReportsCompanion(resolved: drift.Value(resolved)));
  }

  // Paging questions
  Future<List<Question>> pagedQuestions({required int limit, required int offset}) async {
    final q = _db.select(_db.questions)
      ..orderBy([(t) => drift.OrderingTerm.desc(t.id)])
      ..limit(limit, offset: offset);
    return q.get();
  }

  // Filters and bulk ops for questions
  Future<List<Question>> unassignedQuestions({int limit = 500, int offset = 0}) async {
    final res = await _db.customSelect(
      'SELECT q.* FROM questions q '
      'LEFT JOIN question_categories qc ON qc.question_id = q.id '
      'LEFT JOIN question_subcategories qs ON qs.question_id = q.id '
      'WHERE qc.id IS NULL AND qs.id IS NULL '
      'ORDER BY q.id DESC LIMIT ? OFFSET ?',
      variables: [drift.Variable(limit), drift.Variable(offset)],
      readsFrom: { _db.questions, _db.questionCategories, _db.questionSubcategories },
    ).get();
    return res.map((r) => _db.questions.map(r.data)).toList();
  }

  Future<List<Question>> questionsInCategory(int categoryId, {int limit = 500, int offset = 0}) async {
    final res = await _db.customSelect(
      'SELECT q.* FROM questions q '
      'JOIN question_categories qc ON qc.question_id = q.id '
      'WHERE qc.category_id = ? '
      'ORDER BY q.id DESC LIMIT ? OFFSET ?',
      variables: [drift.Variable(categoryId), drift.Variable(limit), drift.Variable(offset)],
      readsFrom: { _db.questions, _db.questionCategories },
    ).get();
    return res.map((r) => _db.questions.map(r.data)).toList();
  }

  Future<List<Question>> questionsInSubcategory(int subcategoryId, {int limit = 500, int offset = 0}) async {
    final res = await _db.customSelect(
      'SELECT q.* FROM questions q '
      'JOIN question_subcategories qs ON qs.question_id = q.id '
      'WHERE qs.subcategory_id = ? '
      'ORDER BY q.id DESC LIMIT ? OFFSET ?',
      variables: [drift.Variable(subcategoryId), drift.Variable(limit), drift.Variable(offset)],
      readsFrom: { _db.questions, _db.questionSubcategories },
    ).get();
    return res.map((r) => _db.questions.map(r.data)).toList();
  }

  Future<void> moveQuestionsTo({required List<int> questionIds, int? categoryId, int? subcategoryId}) async {
    if (questionIds.isEmpty) return;
    await _db.transaction(() async {
      if (categoryId != null) {
        // Remove previous category links, then add the new one
        await (_db.delete(_db.questionCategories)..where((qc) => qc.questionId.isIn(questionIds))).go();
        await _db.batch((b) {
          b.insertAll(_db.questionCategories, [
            for (final q in questionIds) QuestionCategoriesCompanion.insert(questionId: q, categoryId: categoryId),
          ]);
        });
      }
      if (subcategoryId != null) {
        await (_db.delete(_db.questionSubcategories)..where((qs) => qs.questionId.isIn(questionIds))).go();
        await _db.batch((b) {
          b.insertAll(_db.questionSubcategories, [
            for (final q in questionIds) QuestionSubcategoriesCompanion.insert(questionId: q, subcategoryId: subcategoryId),
          ]);
        });
      }
    });
  }

  Future<void> randomAssign({List<int> categoryIds = const [], List<int> subcategoryIds = const [], int perCategory = 0, int perSubcategory = 0}) async {
    await _db.transaction(() async {
      for (final cid in categoryIds) {
        if (perCategory <= 0) break;
        final rows = await _db.customSelect(
          'SELECT q.id FROM questions q '
          'WHERE q.id NOT IN (SELECT question_id FROM question_categories WHERE category_id = ?) '
          'ORDER BY RANDOM() LIMIT ?',
          variables: [drift.Variable(cid), drift.Variable(perCategory)],
          readsFrom: { _db.questions, _db.questionCategories },
        ).get();
        final ids = rows.map((r) => r.data['id'] as int).toList();
        await _db.batch((b) {
          b.insertAll(_db.questionCategories, [for (final id in ids) QuestionCategoriesCompanion.insert(questionId: id, categoryId: cid)]);
        });
      }
      for (final sid in subcategoryIds) {
        if (perSubcategory <= 0) break;
        final rows = await _db.customSelect(
          'SELECT q.id FROM questions q '
          'WHERE q.id NOT IN (SELECT question_id FROM question_subcategories WHERE subcategory_id = ?) '
          'ORDER BY RANDOM() LIMIT ?',
          variables: [drift.Variable(sid), drift.Variable(perSubcategory)],
          readsFrom: { _db.questions, _db.questionSubcategories },
        ).get();
        final ids = rows.map((r) => r.data['id'] as int).toList();
        await _db.batch((b) {
          b.insertAll(_db.questionSubcategories, [for (final id in ids) QuestionSubcategoriesCompanion.insert(questionId: id, subcategoryId: sid)]);
        });
      }
    });
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository(ref.watch(dbProvider)));
