import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/sync/data/sync_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value, InsertMode, Selectable;
import 'package:drift/drift.dart' as drift show Variable;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:exampro/features/sync/data/pg_content_service.dart';

typedef Progress = void Function(double pct, String label);

class SyncRepository {
  final AppDatabase _db;
  final SyncApi _api;
  SyncRepository(this._db, this._api);

  Future<void> pullAndImport({Progress? onProgress}) async {
    onProgress?.call(0.02, 'Downloading…');
    final snap = await _api.snapshot();
    onProgress?.call(0.08, 'Preparing database…');
    await _db.transaction(() async {
      // Clear dependent tables first
      // Keep user progress and saved questions
      await _db.customStatement('DELETE FROM exam_grade_bands');
      await _db.customStatement('DELETE FROM exam_questions');
      await _db.customStatement('DELETE FROM choices');
      await _db.customStatement('DELETE FROM questions');
      await _db.customStatement('DELETE FROM exams');
      await _db.customStatement('DELETE FROM question_categories');
      await _db.customStatement('DELETE FROM question_subcategories');
      await _db.customStatement('DELETE FROM subcategories');
      await _db.customStatement('DELETE FROM categories');
      await _db.customStatement('DELETE FROM translations');

      // Do not persist media files locally; use remote image URLs only.

      onProgress?.call(0.15, 'Importing categories…');
      final cats = (snap['categories'] as List?) ?? const [];
      for (final m in cats) {
        final img = (m['image_url'] as String?);
        final path = (img != null && img.isNotEmpty) ? img : null;
        await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          id: Value((m['id'] as int)),
          name: m['name'] as String,
          order: Value((m['order'] as num?)?.toInt() ?? 0),
          passPercent: Value((m['pass_percent'] as num?)?.toInt() ?? 60),
          imageUrl: Value(path ?? ''),
          locked: Value((m['locked'] as bool?) ?? false),
        ), mode: InsertMode.insertOrReplace);
      }

      onProgress?.call(0.30, 'Importing subcategories…');
      final subs = (snap['subcategories'] as List?) ?? const [];
      for (final m in subs) {
        final img = (m['image_url'] as String?);
        final path = (img != null && img.isNotEmpty) ? img : null;
        await _db.into(_db.subcategories).insert(SubcategoriesCompanion.insert(
          id: Value((m['id'] as int)),
          categoryId: m['category_id'] as int,
          name: m['name'] as String,
          order: Value((m['order'] as num?)?.toInt() ?? 0),
          imageUrl: Value(path ?? ''),
          locked: Value((m['locked'] as bool?) ?? false),
        ), mode: InsertMode.insertOrReplace);
      }

      onProgress?.call(0.45, 'Importing exams…');
      final exams = (snap['exams'] as List?) ?? const [];
      for (final m in exams) {
        await _db.into(_db.exams).insert(ExamsCompanion.insert(
          id: Value(m['id'] as int),
          title: m['title'] as String,
          description: Value(m['description'] as String? ?? ''),
          categoryId: m['category_id'] as int,
          subcategoryId: Value((m['subcategory_id'] as num?)?.toInt()),
          questionCount: Value((m['question_count'] as num?)?.toInt() ?? 0),
          published: Value((m['published'] as bool?) ?? false),
          timeLimitMinutes: Value((m['time_limit_minutes'] as num?)?.toInt() ?? 0),
          shuffleOptions: Value((m['shuffle_options'] as bool?) ?? true),
          negativeMarking: Value((m['negative_marking'] as bool?) ?? false),
          passPercent: Value((m['pass_percent'] as num?)?.toInt() ?? 60),
          themeKey: Value((m['theme_key'] as num?)?.toInt() ?? 0),
        ), mode: InsertMode.insertOrReplace);
      }

      onProgress?.call(0.60, 'Importing questions…');
      final questions = (snap['questions'] as List?) ?? const [];
      for (final m in questions) {
        await _db.into(_db.questions).insert(QuestionsCompanion.insert(
          id: Value(m['id'] as int),
          body: m['body'] as String,
          explanation: Value(m['explanation'] as String? ?? ''),
          multiple: Value((m['multiple'] as bool?) ?? false),
          locked: Value((m['locked'] as bool?) ?? false),
        ), mode: InsertMode.insertOrReplace);
      }

      onProgress?.call(0.72, 'Importing choices…');
      final choices = (snap['choices'] as List?) ?? const [];
      for (final m in choices) {
        await _db.into(_db.choices).insert(ChoicesCompanion.insert(
          id: Value(m['id'] as int),
          questionId: m['question_id'] as int,
          label: m['label'] as String,
          isCorrect: Value((m['is_correct'] as bool?) ?? false),
          order: Value((m['order'] as num?)?.toInt() ?? 0),
        ), mode: InsertMode.insertOrReplace);
      }

      onProgress?.call(0.82, 'Linking exams…');
      final eq = (snap['exam_questions'] as List?) ?? const [];
      for (final m in eq) {
        await _db.into(_db.examQuestions).insert(ExamQuestionsCompanion.insert(
          id: Value(m['id'] as int),
          examId: m['exam_id'] as int,
          questionId: m['question_id'] as int,
          order: Value((m['order'] as num?)?.toInt() ?? 0),
          points: Value((m['points'] as num?)?.toInt() ?? 1),
        ), mode: InsertMode.insertOrReplace);
      }

      onProgress?.call(0.9, 'Importing grade bands…');
      final bands = (snap['exam_grade_bands'] as List?) ?? const [];
      for (final m in bands) {
        await _db.into(_db.examGradeBands).insert(ExamGradeBandsCompanion.insert(
          id: Value(m['id'] as int),
          examId: m['exam_id'] as int,
          minPercent: m['min_percent'] as int,
          label: m['label'] as String,
          color: Value(m['color'] as String? ?? '#4CAF50'),
        ), mode: InsertMode.insertOrReplace);
      }

      // Optional translations payload
      final trans = (snap['translations'] as List?) ?? const [];
      for (final m in trans) {
        if (m is! Map) continue;
        final entity = (m['entity'] as String?) ?? '';
        final entityId = (m['entity_id'] as num?)?.toInt() ?? 0;
        final lang = (m['lang'] as String?) ?? '';
        final k = (m['k'] as String?) ?? '';
        final v = (m['v'] as String?) ?? '';
        if (entity.isEmpty || entityId == 0 || lang.isEmpty || k.isEmpty || v.isEmpty) continue;
        await _db.customStatement('INSERT INTO translations(entity, entity_id, lang, k, v) VALUES (?,?,?,?,?)',
            [entity, entityId, lang, k, v]);
      }

      // Optionally sync user attributes (role, is_pro) if provided in snapshot
      // This updates existing users by email without altering local passwords
      final users = (snap['users'] as List?) ?? const [];
      if (users.isNotEmpty) {
        onProgress?.call(0.94, 'Updating users...');
        for (final m in users) {
          final email = (m['email'] as String?)?.trim();
          if (email == null || email.isEmpty) continue;
          final isPro = (m['is_pro'] as bool?) ?? false;
          final role = (m['role'] as String?) ?? 'user';
          await (_db.update(_db.users)..where((u) => u.email.equals(email))).write(
            UsersCompanion(
              isPro: Value(isPro),
              role: Value(role),
            ),
          );
        }
      }
    });
    // Store content version if provided
    final version = (snap['version'] ?? DateTime.now().toIso8601String()).toString();
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(AppSettingsCompanion(key: Value('content_version'), value: Value(version)));
    onProgress?.call(1.0, 'Up to date');
  }

  Future<String?> localVersion() async {
    final row = await (_db.select(_db.appSettings)..where((s) => s.key.equals('content_version'))).getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, dynamic>> dumpLocalSnapshot() async {
    Future<List<Map<String, dynamic>>> all<T>(Selectable<T> sel) async {
      final rows = await sel.get();
      return rows
          .map((r) => (r as dynamic).toJson() as Map<String, dynamic>)
          .toList();
    }
    return {
      'version': await localVersion() ?? DateTime.now().toUtc().toIso8601String(),
      'categories': await all(_db.select(_db.categories)),
      'subcategories': await all(_db.select(_db.subcategories)),
      'exams': await all(_db.select(_db.exams)),
      'questions': await all(_db.select(_db.questions)),
      'choices': await all(_db.select(_db.choices)),
      'exam_questions': await all(_db.select(_db.examQuestions)),
      'exam_grade_bands': await all(_db.select(_db.examGradeBands)),
      // Users (email/role/is_pro only) so roles carry to other devices
      'users': [
        for (final u in await _db.select(_db.users).get())
          {
            'email': u.email,
            'role': u.role,
            'is_pro': u.isPro,
          }
      ],
      // Add base64 media payloads for categories/subcategories
      'media_categories': await () async {
        final rows = await _db.select(_db.categories).get();
        final out = <Map<String, dynamic>>[];
        for (final c in rows) {
          final pathStr = c.imageUrl;
          if (pathStr.isEmpty) continue;
          final f = File(pathStr);
          if (await f.exists()) {
            final bytes = await f.readAsBytes();
            out.add({'id': c.id, 'filename': p.basename(pathStr), 'content_base64': base64Encode(bytes)});
          }
        }
        return out;
      }(),
      'media_subcategories': await () async {
        final rows = await _db.select(_db.subcategories).get();
        final out = <Map<String, dynamic>>[];
        for (final s in rows) {
          final pathStr = s.imageUrl;
          if (pathStr.isEmpty) continue;
          final f = File(pathStr);
          if (await f.exists()) {
            final bytes = await f.readAsBytes();
            out.add({'id': s.id, 'filename': p.basename(pathStr), 'content_base64': base64Encode(bytes)});
          }
        }
        return out;
      }(),
      // Also emit a combined payload compatible with the server's import-snapshot
      // endpoint, which expects media_files with entity and entity_id.
      'media_files': await () async {
        final media = <Map<String, dynamic>>[];
        final cats = await _db.select(_db.categories).get();
        for (final c in cats) {
          final pathStr = c.imageUrl;
          if (pathStr.isEmpty) continue;
          final f = File(pathStr);
          if (await f.exists()) {
            final bytes = await f.readAsBytes();
            media.add({
              'entity': 'categories',
              'entity_id': c.id,
              'filename': p.basename(pathStr),
              'content_base64': base64Encode(bytes),
            });
          }
        }
        final subs = await _db.select(_db.subcategories).get();
        for (final s in subs) {
          final pathStr = s.imageUrl;
          if (pathStr.isEmpty) continue;
          final f = File(pathStr);
          if (await f.exists()) {
            final bytes = await f.readAsBytes();
            media.add({
              'entity': 'subcategories',
              'entity_id': s.id,
              'filename': p.basename(pathStr),
              'content_base64': base64Encode(bytes),
            });
          }
        }
        return media;
      }(),
    };
  }

  // User progress sync (per-user by email)
  Future<void> pushUserProgress(String userEmail) async {
    // attempts for this user only (use raw SQL to be forward compatible)
    final attemptsRows = await _db.customSelect(
      'SELECT id, exam_id, mode, started_at, ended_at, score, score_percent, grade_label FROM attempts WHERE user_email = ? ORDER BY started_at',
      variables: [drift.Variable(userEmail)],
    ).get();
    final answersRows = await _db.customSelect(
      'SELECT a.attempt_id, a.question_id, a.selected, a.time_ms, a.is_correct, a.points FROM attempt_answers a JOIN attempts t ON t.id = a.attempt_id WHERE t.user_email = ? ORDER BY a.attempt_id, a.question_id',
      variables: [drift.Variable(userEmail)],
    ).get();
    final savedRows = await _db.customSelect(
      'SELECT question_id, created_at FROM saved_questions WHERE user_email = ? ORDER BY created_at',
      variables: [drift.Variable(userEmail)],
    ).get();
    final payload = {
      'attempts': [
        for (final r in attemptsRows)
          {
            'id': r.data['id'],
            'exam_id': r.data['exam_id'],
            'mode': r.data['mode'],
            'started_at': r.data['started_at'],
            'ended_at': r.data['ended_at'],
            'score': r.data['score'],
            'score_percent': r.data['score_percent'],
            'grade_label': r.data['grade_label'],
          }
      ],
      'answers': [
        for (final x in answersRows)
          {
            'attempt_id': x.data['attempt_id'],
            'question_id': x.data['question_id'],
            'selected': x.data['selected'],
            'time_ms': x.data['time_ms'],
            'is_correct': x.data['is_correct'],
            'points': x.data['points'],
          }
      ],
      'saved': [
        for (final s in savedRows)
          {
            'question_id': s.data['question_id'],
            'created_at': s.data['created_at'],
          }
      ],
    };
    await _api.upsertUserProgress(userEmail, payload);
  }

  Future<void> pullUserProgress(String userEmail) async {
    final data = await _api.fetchUserProgress(userEmail);
    final attempts = (data['attempts'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final answers = (data['answers'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final saved = (data['saved'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    await _db.transaction(() async {
      for (final m in attempts) {
        await _db.into(_db.attempts).insert(
              AttemptsCompanion.insert(
                id: Value((m['id'] as num).toInt()),
                examId: (m['exam_id'] as num).toInt(),
                mode: m['mode'] as String,
                startedAt: DateTime.parse(m['started_at'] as String),
                endedAt: Value((m['ended_at'] == null) ? null : DateTime.parse(m['ended_at'] as String)),
                score: Value((m['score'] as num?)?.toInt()),
                scorePercent: Value((m['score_percent'] as num?)?.toInt() ?? 0),
                gradeLabel: Value((m['grade_label'] as String?) ?? ''),
                synced: const Value(true),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final m in answers) {
        await _db.into(_db.attemptAnswers).insert(
              AttemptAnswersCompanion.insert(
                id: const Value.absent(),
                attemptId: (m['attempt_id'] as num).toInt(),
                questionId: (m['question_id'] as num).toInt(),
                selected: m['selected'] as String,
                timeMs: Value((m['time_ms'] as num?)?.toInt() ?? 0),
                isCorrect: Value((m['is_correct'] as bool?) ?? false),
                points: Value((m['points'] as num?)?.toInt() ?? 0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final m in saved) {
        await _db.into(_db.savedQuestions).insert(
              SavedQuestionsCompanion.insert(
                id: const Value.absent(),
                questionId: (m['question_id'] as num).toInt(),
                userEmail: userEmail,
                createdAt: Value(DateTime.parse(m['created_at'] as String)),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) => SyncRepository(ref.watch(dbProvider), ref.watch(syncApiProvider)));
