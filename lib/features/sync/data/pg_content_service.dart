import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postgres/postgres.dart';
import 'package:exampro/core/pg/pg_client.dart';

class PgContentService {
  final PgClient _pg;
  PgContentService(this._pg);

  Future<String> _contentVersion(Connection conn) async {
    Future<String> part(String table) async {
      final rs = await conn.execute('SELECT COUNT(*)::bigint AS c, COALESCE(MAX(id),0)::bigint AS m FROM $table');
      final m = rs.first.toColumnMap();
      return '$table:${m['c']}-${m['m']}';
    }
    final parts = await Future.wait([
      part('categories'),
      part('subcategories'),
      part('exams'),
      part('questions'),
      part('choices'),
      part('exam_questions'),
      part('exam_grade_bands'),
    ]);
    return parts.join('|');
  }

  Future<void> upsertSnapshot(Map<String, dynamic> snap) async {
    final conn = await _pg.open();
    try {
      await conn.execute('BEGIN');

      String _colSql(String c) => c == 'order' ? '"order"' : c;
      dynamic _pick(Map<String, dynamic> m, String key) {
        switch (key) {
          case 'category_id':
            return m['category_id'] ?? m['categoryId'];
          case 'subcategory_id':
            return m['subcategory_id'] ?? m['subcategoryId'];
          case 'question_id':
            return m['question_id'] ?? m['questionId'];
          case 'exam_id':
            return m['exam_id'] ?? m['examId'];
          case 'min_percent':
            return m['min_percent'] ?? m['minPercent'];
          case 'pass_percent':
            return m['pass_percent'] ?? m['passPercent'] ?? 60;
          case 'image_url':
            return m['image_url'] ?? m['imageUrl'] ?? '';
          case 'question_count':
            return m['question_count'] ?? m['questionCount'] ?? 0;
          case 'time_limit_minutes':
            return m['time_limit_minutes'] ?? m['timeLimitMinutes'] ?? 0;
          case 'shuffle_options':
            return m['shuffle_options'] ?? m['shuffleOptions'] ?? true;
          case 'negative_marking':
            return m['negative_marking'] ?? m['negativeMarking'] ?? false;
          case 'theme_key':
            return m['theme_key'] ?? m['themeKey'] ?? 0;
          case 'multiple':
            return m['multiple'] ?? false;
          case 'locked':
            return m['locked'] ?? false;
          case 'is_correct':
            return m['is_correct'] ?? m['isCorrect'] ?? false;
          case 'order':
            return m['order'] ?? 0;
          case 'points':
            return m['points'] ?? 1;
          case 'published':
            return m['published'] ?? false;
          case 'description':
            return m['description'] ?? '';
          case 'color':
            return m['color'] ?? '#4CAF50';
          default:
            return m[key];
        }
      }

      Future<void> _upsert(String table, List<String> keys, List<Map<String, dynamic>> rows) async {
        if (rows.isEmpty) return;
        final colsList = keys.map(_colSql).join(', ');
        final params = List.generate(keys.length, (i) => '@p$i').join(', ');
        final setList = [for (final c in keys.where((c) => c != 'id')) '${_colSql(c)} = EXCLUDED.${_colSql(c)}'].join(', ');
        final sql = 'INSERT INTO $table ($colsList) OVERRIDING SYSTEM VALUE VALUES ($params) '
            'ON CONFLICT (id) DO UPDATE SET $setList';
        for (final m in rows) {
          final values = <String, dynamic>{};
          for (var i = 0; i < keys.length; i++) {
            values['p$i'] = _pick(m, keys[i]);
          }
          await conn.execute(Sql.named(sql), parameters: values);
        }
      }

      await _upsert('categories', ['id','name','order','pass_percent','image_url','locked'],
          [for (final m in ((snap['categories'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);
      await _upsert('subcategories', ['id','category_id','name','order','image_url','locked'],
          [for (final m in ((snap['subcategories'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);
      await _upsert('exams', ['id','title','description','category_id','subcategory_id','question_count','published','time_limit_minutes','shuffle_options','negative_marking','pass_percent','theme_key'],
          [for (final m in ((snap['exams'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);
      await _upsert('questions', ['id','body','explanation','multiple','locked'],
          [for (final m in ((snap['questions'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);
      await _upsert('choices', ['id','question_id','label','is_correct','order'],
          [for (final m in ((snap['choices'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);
      await _upsert('exam_questions', ['id','exam_id','question_id','order','points'],
          [for (final m in ((snap['exam_questions'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);
      await _upsert('exam_grade_bands', ['id','exam_id','min_percent','label','color'],
          [for (final m in ((snap['exam_grade_bands'] as List?) ?? const [])) (m as Map).cast<String, dynamic>()]);

      // Optional: sync users (email, role, is_pro) without passwords
      final users = (snap['users'] as List?) ?? const [];
      if (users.isNotEmpty) {
        await conn.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, email TEXT NOT NULL UNIQUE, password TEXT NOT NULL DEFAULT '', role TEXT NOT NULL DEFAULT 'user', is_pro BOOLEAN NOT NULL DEFAULT FALSE)");
        for (final u in [for (final m in users) (m as Map).cast<String, dynamic>()]) {
          await conn.execute(Sql.named('INSERT INTO users(email, role, is_pro) VALUES (@e,@r,@p) ON CONFLICT(email) DO UPDATE SET role=EXCLUDED.role, is_pro=EXCLUDED.is_pro'), parameters: {
            'e': u['email'],
            'r': u['role'] ?? 'user',
            'p': u['is_pro'] ?? false,
          });
        }
      }

      // Optional: persist media (category/subcategory images) as base64 so other devices can restore
      await conn.execute('CREATE TABLE IF NOT EXISTS media_files (entity TEXT NOT NULL, entity_id INT NOT NULL, filename TEXT NOT NULL, content_base64 TEXT NOT NULL, PRIMARY KEY(entity, entity_id))');
      final catMedia = (snap['media_categories'] as List?) ?? const [];
      final subMedia = (snap['media_subcategories'] as List?) ?? const [];
      Future<void> _upsertMedia(String entity, List<Map<String, dynamic>> rows) async {
        for (final m in rows) {
          if ((m['content_base64'] as String?)?.isEmpty ?? true) continue;
          final sql = 'INSERT INTO media_files(entity, entity_id, filename, content_base64) VALUES (@e,@id,@f,@b) '
              'ON CONFLICT(entity, entity_id) DO UPDATE SET filename = EXCLUDED.filename, content_base64 = EXCLUDED.content_base64';
          await conn.execute(Sql.named(sql), parameters: {
            'e': entity,
            'id': m['id'],
            'f': (m['filename'] ?? 'image.jpg').toString(),
            'b': m['content_base64'],
          });
        }
      }
      await _upsertMedia('categories', catMedia.cast<Map<String, dynamic>>());
      await _upsertMedia('subcategories', subMedia.cast<Map<String, dynamic>>());

      await conn.execute('COMMIT');
    } catch (e) {
      try { await conn.execute('ROLLBACK'); } catch (_) {}
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>> fetchSnapshot() async {
    final conn = await _pg.open();
    try {
      Future<List<Map<String, dynamic>>> all(String sql) async {
        final rs = await conn.execute(sql);
        return [for (final r in rs) r.toColumnMap()];
      }
      Future<bool> hasColumn(String table, String column) async {
        final rs = await conn.execute(
          Sql.named('SELECT 1 FROM information_schema.columns WHERE table_schema=@s AND table_name=@t AND column_name=@c LIMIT 1'),
          parameters: {'s': 'public', 't': table, 'c': column},
        );
        return rs.isNotEmpty;
      }
      final version = await _contentVersion(conn);
      final result = {
        'version': version,
        'categories': await all('SELECT id, name, "order", pass_percent, image_url, locked FROM categories ORDER BY id'),
        'subcategories': await all('SELECT id, category_id, name, "order", image_url, locked FROM subcategories ORDER BY id'),
        'exams': await all('SELECT id, title, description, category_id, subcategory_id, question_count, published, time_limit_minutes, shuffle_options, negative_marking, pass_percent, theme_key FROM exams ORDER BY id'),
        'questions': await all('SELECT id, body, explanation, multiple, locked FROM questions ORDER BY id'),
        'choices': await all('SELECT id, question_id, label, is_correct, "order" FROM choices ORDER BY id'),
        'exam_questions': await all('SELECT id, exam_id, question_id, "order", points FROM exam_questions ORDER BY id'),
        'exam_grade_bands': await all('SELECT id, exam_id, min_percent, label, color FROM exam_grade_bands ORDER BY id'),
      };

      // Media files for categories/subcategories
      try {
        final media = await all('SELECT entity, entity_id, filename, content_base64 FROM media_files WHERE entity IN (\'categories\',\'subcategories\') ORDER BY entity, entity_id');
        result['media_files'] = media;
      } catch (_) {}

      try {
        final hasIsPro = await hasColumn('users', 'is_pro');
        if (hasIsPro) {
          result['users'] = await all('SELECT id, email, role, is_pro FROM users ORDER BY id');
        } else {
          final bare = await all('SELECT id, email, role FROM users ORDER BY id');
          result['users'] = [for (final m in bare) {...m, 'is_pro': false}];
        }
      } catch (_) {
        // If users table doesn't exist, just skip
      }
      return result;
    } finally {
      await conn.close();
    }
  }

  // User progress
  Future<void> upsertUserProgress(String userEmail, Map<String, dynamic> data) async {
    final conn = await _pg.open();
    try {
      await conn.execute('BEGIN');
      await conn.execute("CREATE TABLE IF NOT EXISTS user_attempts (user_email TEXT NOT NULL, local_id INT NOT NULL, exam_id INT NOT NULL, mode TEXT NOT NULL, started_at TIMESTAMPTZ NOT NULL, ended_at TIMESTAMPTZ NULL, score INT NULL, score_percent INT NOT NULL DEFAULT 0, grade_label TEXT NOT NULL DEFAULT '' , PRIMARY KEY(user_email, local_id))");
      await conn.execute("CREATE TABLE IF NOT EXISTS user_attempt_answers (user_email TEXT NOT NULL, local_attempt_id INT NOT NULL, question_id INT NOT NULL, selected TEXT NOT NULL, time_ms INT NOT NULL DEFAULT 0, is_correct BOOLEAN NOT NULL DEFAULT FALSE, points INT NOT NULL DEFAULT 0, PRIMARY KEY(user_email, local_attempt_id, question_id))");
      await conn.execute("CREATE TABLE IF NOT EXISTS user_saved_questions (user_email TEXT NOT NULL, question_id INT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), PRIMARY KEY(user_email, question_id))");

      for (final m in ((data['attempts'] as List?) ?? const [])) {
        await conn.execute(Sql.named('INSERT INTO user_attempts(user_email, local_id, exam_id, mode, started_at, ended_at, score, score_percent, grade_label) VALUES (@u,@id,@e,@m,@s,@en,@sc,@sp,@g) ON CONFLICT(user_email, local_id) DO UPDATE SET exam_id=EXCLUDED.exam_id, mode=EXCLUDED.mode, started_at=EXCLUDED.started_at, ended_at=EXCLUDED.ended_at, score=EXCLUDED.score, score_percent=EXCLUDED.score_percent, grade_label=EXCLUDED.grade_label'), parameters: {
          'u': userEmail,
          'id': m['id'],
          'e': m['exam_id'],
          'm': m['mode'],
          's': m['started_at'],
          'en': m['ended_at'],
          'sc': m['score'],
          'sp': m['score_percent'],
          'g': m['grade_label'],
        });
      }
      for (final m in ((data['answers'] as List?) ?? const [])) {
        await conn.execute(Sql.named('INSERT INTO user_attempt_answers(user_email, local_attempt_id, question_id, selected, time_ms, is_correct, points) VALUES (@u,@a,@q,@sel,@t,@ok,@p) ON CONFLICT(user_email, local_attempt_id, question_id) DO UPDATE SET selected=EXCLUDED.selected, time_ms=EXCLUDED.time_ms, is_correct=EXCLUDED.is_correct, points=EXCLUDED.points'), parameters: {
          'u': userEmail,
          'a': m['attempt_id'],
          'q': m['question_id'],
          'sel': m['selected'],
          't': m['time_ms'],
          'ok': m['is_correct'],
          'p': m['points'],
        });
      }
      for (final m in ((data['saved'] as List?) ?? const [])) {
        await conn.execute(Sql.named('INSERT INTO user_saved_questions(user_email, question_id, created_at) VALUES (@u,@q,@c) ON CONFLICT(user_email, question_id) DO UPDATE SET created_at=EXCLUDED.created_at'), parameters: {
          'u': userEmail,
          'q': m['question_id'],
          'c': m['created_at'],
        });
      }

      await conn.execute('COMMIT');
    } catch (e) {
      try { await conn.execute('ROLLBACK'); } catch (_) {}
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>> fetchUserProgress(String userEmail) async {
    final conn = await _pg.open();
    try {
      Future<List<Map<String, dynamic>>> all(String sql, Map<String, dynamic> p) async {
        final rs = await conn.execute(Sql.named(sql), parameters: p);
        return [for (final r in rs) r.toColumnMap()];
      }
      final attempts = await all('SELECT local_id AS id, exam_id, mode, started_at, ended_at, score, score_percent, grade_label FROM user_attempts WHERE user_email=@u ORDER BY started_at', {'u': userEmail});
      final answers = await all('SELECT local_attempt_id AS attempt_id, question_id, selected, time_ms, is_correct, points FROM user_attempt_answers WHERE user_email=@u ORDER BY local_attempt_id, question_id', {'u': userEmail});
      final saved = await all('SELECT question_id, created_at FROM user_saved_questions WHERE user_email=@u', {'u': userEmail});
      return {'attempts': attempts, 'answers': answers, 'saved': saved};
    } finally {
      await conn.close();
    }
  }
}

final pgContentServiceProvider = FutureProvider<PgContentService>((ref) async {
  final client = await ref.watch(pgClientProvider.future);
  return PgContentService(client);
});
