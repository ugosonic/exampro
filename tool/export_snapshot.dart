import 'dart:convert';
import 'dart:io';
import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  final out = args.isNotEmpty ? args.first : 'snapshot.json';
  final url = Platform.environment['DATABASE_URL'] ?? _readUrl();
  if (url.isEmpty) {
    stderr.writeln('DATABASE_URL not set (postgres).');
    exit(1);
  }
  final uri = Uri.parse(url);
  final endpoint = Endpoint(
    host: uri.host,
    port: uri.hasPort ? uri.port : 5432,
    database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '',
    username: uri.userInfo.split(':').first,
    password: uri.userInfo.split(':').length > 1 ? uri.userInfo.split(':')[1] : null,
  );
  final useSsl = (uri.queryParameters['sslmode'] ?? '').contains('require');
  final settings = ConnectionSettings(sslMode: useSsl ? SslMode.require : SslMode.disable);
  final conn = await Connection.open(endpoint, settings: settings);

  Future<List<Map<String, dynamic>>> all(String table) async {
    final rs = await conn.execute(Sql('SELECT * FROM $table'));
    return rs.map((r) => r.toColumnMap()).toList();
  }

  final data = <String, dynamic>{
    'version': DateTime.now().toUtc().toIso8601String(),
    'categories': await all('categories'),
    'subcategories': await all('subcategories'),
    'exams': await all('exams'),
    'questions': await all('questions'),
    'choices': await all('choices'),
    'exam_questions': await all('exam_questions'),
    'exam_grade_bands': await all('exam_grade_bands'),
  };

  await conn.close();
  File(out).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  stdout.writeln('Wrote $out');
}

String _readUrl() {
  try {
    final lines = File('assets/env/vc.env').readAsLinesSync();
    for (final l in lines) {
      if (l.startsWith('DATABASE_URL=')) return l.substring('DATABASE_URL='.length).trim();
    }
  } catch (_) {}
  return '';
}

