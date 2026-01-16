import 'package:drift/drift.dart' as drift;
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/features/admin/data/admin_api.dart';
import 'package:citizentest/features/catalog/data/content_api.dart';

class AdminRepository {
  final AppDatabase _db;
  final AdminApi? _adminApi;
  final ContentApi? _contentApi;
  AdminRepository(this._db, [this._adminApi, this._contentApi]);

  Future<int> createCategory(String name, {int order = 0, String imageUrl = ''}) async {
    if (_adminApi != null) {
      final id = await _adminApi.createCategory(name: name, order: order, imageUrl: imageUrl);
      try {
        await _db.into(_db.categories).insertOnConflictUpdate(
          CategoriesCompanion.insert(
            id: drift.Value(id),
            name: name,
            order: drift.Value(order),
            imageUrl: drift.Value(imageUrl),
          ),
        );
      } catch (_) {}
      return id;
    }
    return _db.into(_db.categories).insert(CategoriesCompanion.insert(
          name: name,
          order: drift.Value(order),
          imageUrl: drift.Value(imageUrl),
        ));
  }

  Future<int> createSubcategory(int categoryId, String name, {int order = 0, String imageUrl = ''}) async {
    if (_adminApi != null) {
      final id = await _adminApi.createSubcategory(categoryId: categoryId, name: name, order: order, imageUrl: imageUrl);
      try {
        await _db.into(_db.subcategories).insertOnConflictUpdate(
          SubcategoriesCompanion.insert(
            id: drift.Value(id),
            categoryId: categoryId,
            name: name,
            order: drift.Value(order),
            imageUrl: drift.Value(imageUrl),
          ),
        );
      } catch (_) {}
      return id;
    }
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
    String pdfUrl = '',
  }) async {
    if (_adminApi != null) {
      return _adminApi.createExam(
        title: title,
        description: description,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        timeLimitMinutes: timeLimitMinutes,
        passPercent: passPercent,
        shuffleOptions: shuffleOptions,
        negativeMarking: negativeMarking,
        published: published,
        themeKey: themeKey,
        pdfUrl: pdfUrl,
      );
    }
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
          pdfUrl: drift.Value(pdfUrl),
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

  Future<void> updateExam(int examId, {
    String? title,
    String? description,
    int? categoryId,
    int? subcategoryId,
    int? timeLimitMinutes,
    int? passPercent,
    bool? shuffleOptions,
    bool? negativeMarking,
    bool? published,
    int? themeKey,
    String? pdfUrl,
  }) async {
    if (_adminApi != null) {
      await _adminApi.updateExam(
        examId,
        title: title,
        description: description,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        timeLimitMinutes: timeLimitMinutes,
        passPercent: passPercent,
        shuffleOptions: shuffleOptions,
        negativeMarking: negativeMarking,
        published: published,
        themeKey: themeKey,
        pdfUrl: pdfUrl,
      );
      return;
    }
    await (_db.update(_db.exams)..where((e) => e.id.equals(examId))).write(ExamsCompanion(
      title: title != null ? drift.Value(title) : const drift.Value.absent(),
      description: description != null ? drift.Value(description) : const drift.Value.absent(),
      categoryId: categoryId != null ? drift.Value(categoryId) : const drift.Value.absent(),
      subcategoryId: subcategoryId != null ? drift.Value(subcategoryId) : const drift.Value.absent(),
      timeLimitMinutes: timeLimitMinutes != null ? drift.Value(timeLimitMinutes) : const drift.Value.absent(),
      passPercent: passPercent != null ? drift.Value(passPercent) : const drift.Value.absent(),
      shuffleOptions: shuffleOptions != null ? drift.Value(shuffleOptions) : const drift.Value.absent(),
      negativeMarking: negativeMarking != null ? drift.Value(negativeMarking) : const drift.Value.absent(),
      published: published != null ? drift.Value(published) : const drift.Value.absent(),
      themeKey: themeKey != null ? drift.Value(themeKey) : const drift.Value.absent(),
      pdfUrl: pdfUrl != null ? drift.Value(pdfUrl) : const drift.Value.absent(),
    ));
  }

  Future<void> setCategoryLocked(int id, bool locked) async {
    if (_adminApi != null) {
      await _adminApi.updateCategory(id, locked: locked);
      try { await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(locked: drift.Value(locked))); } catch (_) {}
      return;
    }
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(locked: drift.Value(locked)));
  }

  Future<int> addQuestionWithOptions({
    required int examId,
    required String text,
    String explanation = '',
    required List<({String text, bool correct})> options,
    int points = 1,
    int order = 0,
  }) async {
    if (_adminApi != null) {
      return _adminApi.addQuestionWithOptions(examId: examId, text: text, explanation: explanation, options: options, points: points, order: order);
    }
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

  Stream<List<Category>> watchCategories() {
    if (_contentApi != null) {
      return Stream.fromFuture(_contentApi.categories().then((rows) => [
            for (final m in rows)
              Category(
                id: (m['id'] as num).toInt(),
                name: m['name'] as String,
                order: (m['order'] as num?)?.toInt() ?? 0,
                passPercent: (m['pass_percent'] as num?)?.toInt() ?? 60,
                imageUrl: (m['image_url'] as String?) ?? '',
                locked: (m['locked'] as bool?) ?? false,
              ),
          ]));
    }
    return _db.select(_db.categories).watch();
  }
  Stream<List<Subcategory>> watchSubcategories(int categoryId) {
    if (_contentApi != null) {
      return Stream.fromFuture(_contentApi.subcategories(categoryId: categoryId).then((rows) => [
            for (final m in rows)
              Subcategory(
                id: (m['id'] as num).toInt(),
                categoryId: (m['category_id'] as num).toInt(),
                name: m['name'] as String,
                order: (m['order'] as num?)?.toInt() ?? 0,
                imageUrl: (m['image_url'] as String?) ?? '',
                locked: (m['locked'] as bool?) ?? false,
              ),
          ]));
    }
    return (_db.select(_db.subcategories)..where((s) => s.categoryId.equals(categoryId))).watch();
  }
  Future<List<Subcategory>> allSubcategories() async => _db.select(_db.subcategories).get();

  Future<List<Category>> categories() async {
    return await _db.select(_db.categories).get();
  }

  // Users – prefer online database when API is configured; fall back to local
  // When using the API, poll periodically to pick up new users.
  Stream<List<DbUser>> watchUsers() {
    if (_adminApi != null) {
      return () async* {
        while (true) {
          try {
            final rows = await _adminApi!.users();
            yield [
              for (final m in rows)
                DbUser(
                  id: (m['id'] as num).toInt(),
                  email: (m['email'] as String?) ?? '',
                  password: '',
                  role: (m['role'] as String?) ?? 'user',
                  isPro: false,
                )
            ];
          } catch (_) {
            // Fall back to local snapshot on error
            yield await _db.select(_db.users).get();
          }
          await Future.delayed(const Duration(seconds: 10));
        }
      }();
    }
    return _db.select(_db.users).watch();
  }
  Future<List<DbUser>> allUsers() async {
    if (_adminApi != null) {
      try {
        final rows = await _adminApi.users();
        return [
          for (final m in rows)
            DbUser(
              id: (m['id'] as num).toInt(),
              email: (m['email'] as String?) ?? '',
              password: '',
              role: (m['role'] as String?) ?? 'user',
              isPro: false,
            )
        ];
      } catch (_) {
        return _db.select(_db.users).get();
      }
    }
    return _db.select(_db.users).get();
  }

  Future<void> updateCategory(int id, {String? name, int? order, int? passPercent, String? imageUrl}) async {
    if (_adminApi != null) {
      await _adminApi.updateCategory(id, name: name, order: order, passPercent: passPercent, imageUrl: imageUrl);
      try {
        await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(
              name: name != null ? drift.Value(name) : const drift.Value.absent(),
              order: order != null ? drift.Value(order) : const drift.Value.absent(),
              passPercent: passPercent != null ? drift.Value(passPercent) : const drift.Value.absent(),
              imageUrl: imageUrl != null ? drift.Value(imageUrl) : const drift.Value.absent(),
            ));
      } catch (_) {}
      return;
    }
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(
          name: name != null ? drift.Value(name) : const drift.Value.absent(),
          order: order != null ? drift.Value(order) : const drift.Value.absent(),
          passPercent: passPercent != null ? drift.Value(passPercent) : const drift.Value.absent(),
          imageUrl: imageUrl != null ? drift.Value(imageUrl) : const drift.Value.absent(),
        ));
  }

  Future<void> deleteCategory(int id) async {
    if (_adminApi != null) { await _adminApi.deleteCategory(id); try { await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go(); } catch (_) {} return; }
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  Future<Category?> getCategory(int id) async {
    return await (_db.select(_db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateSubcategory(int id, {String? name, int? order, String? imageUrl, bool? locked}) async {
    if (_adminApi != null) {
      await _adminApi.updateSubcategory(id, name: name, order: order, imageUrl: imageUrl, locked: locked);
      try {
        await (_db.update(_db.subcategories)..where((s) => s.id.equals(id))).write(SubcategoriesCompanion(
              name: name != null ? drift.Value(name) : const drift.Value.absent(),
              order: order != null ? drift.Value(order) : const drift.Value.absent(),
              imageUrl: imageUrl != null ? drift.Value(imageUrl) : const drift.Value.absent(),
              locked: locked != null ? drift.Value(locked) : const drift.Value.absent(),
            ));
      } catch (_) {}
      return;
    }
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
    if (_adminApi != null) { await _adminApi.deleteSubcategory(id); try { await (_db.delete(_db.subcategories)..where((s) => s.id.equals(id))).go(); } catch (_) {} return; }
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
  Stream<List<Exam>> watchExams() => _contentApi != null
      ? Stream.fromFuture(_contentApi.exams().then((rows) => [
            for (final m in rows)
              Exam(
                id: (m['id'] as num).toInt(),
                title: m['title'] as String,
                description: (m['description'] as String?) ?? '',
                categoryId: (m['category_id'] as num).toInt(),
                subcategoryId: (m['subcategory_id'] as num?)?.toInt(),
                questionCount: (m['question_count'] as num?)?.toInt() ?? 0,
                published: (m['published'] as bool?) ?? false,
                timeLimitMinutes: (m['time_limit_minutes'] as num?)?.toInt() ?? 0,
                shuffleOptions: (m['shuffle_options'] as bool?) ?? true,
                negativeMarking: (m['negative_marking'] as bool?) ?? false,
                passPercent: (m['pass_percent'] as num?)?.toInt() ?? 60,
                themeKey: (m['theme_key'] as num?)?.toInt() ?? 0,
                pdfUrl: (m['pdf_url'] as String?) ?? '',
              ),
          ]))
      : _db.select(_db.exams).watch();

  // Localized exams stream: reacts to language and translation changes immediately
  Stream<List<Exam>> watchExamsLocalized() {
    if (_contentApi != null) {
      return Stream.fromFuture(_contentApi.exams().then((rows) => [
            for (final m in rows)
              Exam(
                id: (m['id'] as num).toInt(),
                title: m['title'] as String,
                description: (m['description'] as String?) ?? '',
                categoryId: (m['category_id'] as num).toInt(),
                subcategoryId: (m['subcategory_id'] as num?)?.toInt(),
                questionCount: (m['question_count'] as num?)?.toInt() ?? 0,
                published: (m['published'] as bool?) ?? false,
                timeLimitMinutes: (m['time_limit_minutes'] as num?)?.toInt() ?? 0,
                shuffleOptions: (m['shuffle_options'] as bool?) ?? true,
                negativeMarking: (m['negative_marking'] as bool?) ?? false,
                passPercent: (m['pass_percent'] as num?)?.toInt() ?? 60,
                themeKey: (m['theme_key'] as num?)?.toInt() ?? 0,
                pdfUrl: (m['pdf_url'] as String?) ?? '',
              ),
          ]));
    }
    const sql =
        'SELECT e.id, '
        "COALESCE(NULLIF(t.v, ''), e.title) AS title, "
        'e.description, e.category_id, e.subcategory_id, e.question_count, e.published, '
        'e.time_limit_minutes, e.shuffle_options, e.negative_marking, e.pass_percent, e.theme_key, e.pdf_url '
        'FROM exams e '
        "LEFT JOIN app_settings s ON s.key = 'lang_code' "
        "LEFT JOIN translations t ON t.entity = 'exams' AND t.entity_id = e.id AND t.k = 'title' AND t.lang = COALESCE(s.value, 'en') "
        'ORDER BY e.id DESC';
    return _db
        .customSelect(sql, readsFrom: { _db.exams, _db.appSettings })
        .watch()
        .map((rows) => [for (final r in rows) _db.exams.map(r.data)]);
  }
  Future<void> setExamPublished(int examId, bool published) async {
    await (_db.update(_db.exams)..where((t) => t.id.equals(examId))).write(ExamsCompanion(published: drift.Value(published)));
  }
  Future<void> deleteExam(int examId) async {
    if (_adminApi != null) {
      await _adminApi.deleteExam(examId);
      return;
    }
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
    if (_adminApi != null) {
      await _adminApi.deleteQuestionFromExam(examId: examId, questionId: questionId);
      return;
    }
    await (_db.delete(_db.examQuestions)..where((t) => t.examId.equals(examId) & t.questionId.equals(questionId))).go();
    final count = await _db.customSelect('SELECT COUNT(*) AS c FROM exam_questions WHERE exam_id = ?', variables: [drift.Variable(examId)])
        .getSingle()
        .then((r) => (r.data['c'] as int?) ?? 0);
    await (_db.update(_db.exams)..where((e) => e.id.equals(examId))).write(ExamsCompanion(questionCount: drift.Value(count)));
  }

  Future<void> updateQuestionAndOptions({required int questionId, required String body, String explanation = '', required List<({String text, bool correct})> options}) async {
    if (_adminApi != null) {
      await _adminApi.updateQuestionAndOptions(questionId: questionId, body: body, explanation: explanation, options: options);
      return;
    }
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

  // Exam flags stored in app_settings to avoid codegen: key = 'exam_readonly_<id>' value '1'/'0'
  Future<bool> getExamReadOnly(int examId) async {
    final key = 'exam_readonly_$examId';
    final row = await (_db.select(_db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value == '1';
  }
  Future<void> setExamReadOnly(int examId, bool readOnly) async {
    final key = 'exam_readonly_$examId';
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(AppSettingsCompanion(key: drift.Value(key), value: drift.Value(readOnly ? '1' : '0')));
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

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  final hasApi = env != null && env.apiBaseUrl.isNotEmpty;
  final adminApi = hasApi ? ref.watch(adminApiProvider) : null;
  final contentApi = hasApi ? ref.watch(contentApiProvider) : null;
  return AdminRepository(dbi, adminApi, contentApi);
});
