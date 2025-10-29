import 'package:exampro/core/config/env_loader.dart';
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

final pgClientProvider = Provider<PgClient>((ref) {
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  if (env == null || env.databaseUrl.isEmpty) {
    throw StateError('DATABASE_URL not configured');
  }
  return PgClient(env.databaseUrl);
});

