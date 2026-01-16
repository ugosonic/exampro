import 'package:dio/dio.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:citizentest/features/sync/data/pg_content_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncApi {
  final Dio _dio;
  SyncApi(this._dio);

  Future<Map<String, dynamic>> snapshot() async {
    final res = await _dio.get('/sync/snapshot');
    final raw = (res.data is Map) ? (res.data as Map) : <String, dynamic>{};
    return Map<String, dynamic>.from(raw);
  }

  Future<String> version() async {
    final res = await _dio.get('/sync/version');
    return (res.data is Map) ? ((res.data['version'] ?? '').toString()) : res.data.toString();
  }

  // HTTP progress endpoints
  Future<void> upsertUserProgress(String email, Map<String, dynamic> data) async {
    await _dio.post('/sync/user-progress', data: {'email': email, 'data': data});
  }

  Future<Map<String, dynamic>> fetchUserProgress(String email) async {
    final res = await _dio.get('/sync/user-progress', queryParameters: {'email': email});
    final raw = (res.data is Map) ? (res.data as Map) : <String, dynamic>{};
    return Map<String, dynamic>.from(raw);
  }
}

class PgSyncApi extends SyncApi {
  final PgContentService _pg;
  PgSyncApi(this._pg) : super(refDioPlaceholder);

  static final Dio refDioPlaceholder = Dio();

  @override
  Future<Map<String, dynamic>> snapshot() async => _pg.fetchSnapshot();

  @override
  Future<String> version() async {
    // Fetch only the deterministic content signature (counts+max ids)
    // by calling the underlying service's fetchSnapshot version routine
    // without materializing rows.
    // We reuse the service computation by opening a connection and
    // computing signature via fetchSnapshot fast path.
    // For simplicity, call fetchSnapshot() and return its 'version'.
    // This is acceptable since it runs lean queries (counts/max ids +
    // minimal selects when needed). If this becomes heavy, we can
    // expose a direct method on the service.
    final snap = await _pg.fetchSnapshot();
    return (snap['version'] ?? '').toString();
  }

  // Expose user progress helpers (Neon-direct)
  @override
  Future<void> upsertUserProgress(String email, Map<String, dynamic> data) => _pg.upsertUserProgress(email, data);
  @override
  Future<Map<String, dynamic>> fetchUserProgress(String email) => _pg.fetchUserProgress(email);
}

final syncApiProvider = Provider<SyncApi>((ref) {
  // Always use HTTP API hosted on the VPS so client devices don’t need
  // direct Postgres access or a local DATABASE_URL.
  return SyncApi(ref.watch(dioProvider));
});
