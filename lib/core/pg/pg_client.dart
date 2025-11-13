import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postgres/postgres.dart';

class PgClient {
  final String databaseUrl;
  const PgClient(this.databaseUrl);

  Endpoint _endpointFromUrl(String url) {
    // Accept both postgresql:// and postgres://
    final fixed = url.replaceFirst('postgresql://', 'postgres://');
    final uri = Uri.parse(fixed);
    final userInfo = uri.userInfo.split(':');
    final user = userInfo.isNotEmpty ? userInfo.first : '';
    final pass = userInfo.length > 1 ? userInfo.sublist(1).join(':') : '';
    final db = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    return Endpoint(
      host: uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: db,
      username: user,
      password: pass,
    );
  }

  Future<Connection> open() async {
    final ep = _endpointFromUrl(databaseUrl);
    return Connection.open(
      ep,
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );
  }
}

// Resolve DATABASE_URL from app_settings (key = 'database_url') with fallback to .env
final databaseUrlProvider = FutureProvider<String>((ref) async {
  final db = ref.read(dbProvider);
  try {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals('database_url'))).getSingleOrNull();
    final v = row?.value.trim() ?? '';
    if (v.isNotEmpty) return v;
  } catch (_) {}
  final env = await ref.watch(envLoaderProvider.future);
  return env.databaseUrl;
});

final pgClientProvider = FutureProvider<PgClient>((ref) async {
  final url = await ref.watch(databaseUrlProvider.future);
  if (url.isEmpty) {
    throw StateError('DATABASE_URL not configured');
  }
  return PgClient(url);
});
