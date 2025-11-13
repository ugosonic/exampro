import 'package:dio/dio.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citizentest/core/auth/token_store.dart';

abstract class AuthApi {
  Future<Tokens> signIn({required String email, required String password});
  Future<User> me();
  Future<Tokens> refresh({required String refreshToken});
  Future<Tokens> register({required String email, required String password});
  Future<void> requestPasswordReset({required String email});
}

class AuthApiImpl implements AuthApi {
  final Dio _dio;
  final TokenStore _store;
  AuthApiImpl(this._dio, this._store);

  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    final res = await _dio.post('/auth/sign-in', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<User> me() async {
    final token = await _store.getAccessToken();
    final res = await _dio.get(
      '/auth/me',
      options: token == null
          ? null
          : Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tokens> refresh({required String refreshToken}) async {
    final res = await _dio.post('/auth/refresh', data: {'refresh': refreshToken});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tokens> register({required String email, required String password}) async {
    final res = await _dio.post('/auth/register', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }
}

// Simple mock for local development
class AuthApiMock implements AuthApi {
  static String? _currentEmail;
  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentEmail = email;
    return const Tokens(access: 'mock-access-token', refresh: 'mock-refresh-token');
  }

  @override
  Future<User> me() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (_currentEmail == null) {
      // Not signed in: signal to caller so UI can show Sign In instead of a placeholder email
      throw Exception('No active session');
    }
    final email = _currentEmail!;
    final role = email.toLowerCase().contains('admin') ? 'admin' : 'user';
    return User(id: 'u_1', email: email, role: role);
  }

  @override
  Future<Tokens> refresh({required String refreshToken}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const Tokens(access: 'mock-access-token-ref', refresh: 'mock-refresh-token-ref');
  }

  @override
  Future<Tokens> register({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentEmail = email;
    return const Tokens(access: 'mock-access-token-new', refresh: 'mock-refresh-token-new');
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  // Use real API when API_BASE_URL is configured; fall back to mock otherwise.
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  if (env == null || env.apiBaseUrl.isEmpty) {
    return AuthApiMock();
  }
  // Use separate raw dio to avoid interceptor cycles
  final dio = ref.watch(authDioProvider);
  final store = ref.watch(tokenStoreProvider);
  return AuthApiImpl(dio, store);
});
