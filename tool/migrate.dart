import 'dart:io';

import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  final url = Platform.environment['DATABASE_URL'] ?? _readDatabaseUrlFromEnv();
  if (url.isEmpty) {
    stderr.writeln('DATABASE_URL not set. Set env var or assets/env/vc.env value.');
    exitCode = 1;
    return;
  }
  final sqlFile = args.isNotEmpty ? args.first : 'db/neon_schema.sql';
  final sql = await File(sqlFile).readAsString();

  final uri = Uri.parse(url);
  final useSsl = (uri.queryParameters['sslmode'] ?? '') == 'require';
  final endpoint = Endpoint(
    host: uri.host,
    port: uri.hasPort ? uri.port : 5432,
    database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '',
    username: uri.userInfo.split(':').first,
    password: uri.userInfo.split(':').length > 1 ? uri.userInfo.split(':')[1] : null,
  );
  final settings = ConnectionSettings(sslMode: useSsl ? SslMode.require : SslMode.disable);
  stdout.writeln('Connecting to ${endpoint.host}...');
  final conn = await Connection.open(endpoint, settings: settings);
  stdout.writeln('Running migration $sqlFile');
  final statements = sql
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  for (final stmt in statements) {
    await conn.execute(Sql(stmt));
  }
  await conn.close();
  stdout.writeln('Migration complete.');
}

String _readDatabaseUrlFromEnv() {
  try {
    final lines = File('assets/env/vc.env').readAsLinesSync();
    for (final l in lines) {
      if (l.startsWith('DATABASE_URL=')) {
        return l.substring('DATABASE_URL='.length).trim();
      }
    }
  } catch (_) {}
  return '';
}
