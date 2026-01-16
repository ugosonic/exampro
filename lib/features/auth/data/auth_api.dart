import 'package:dio/dio.dart';
<<<<<<< HEAD
import 'package:exampro/core/network/dio_client.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthApi {
  Future<Tokens> signIn({required String email, required String password});
  Future<Tokens> signUp({required String email, required String password});
  Future<User> me();
  Future<Tokens> refresh({required String refreshToken});
  Future<void> requestDeleteCode({required String email});
  Future<void> deleteAccount({required String email, required String code});
=======
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
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
}

class AuthApiImpl implements AuthApi {
  final Dio _dio;
<<<<<<< HEAD
  AuthApiImpl(this._dio);
=======
  final TokenStore _store;
  AuthApiImpl(this._dio, this._store);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    final res = await _dio.post('/auth/sign-in', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
<<<<<<< HEAD
  Future<Tokens> signUp({required String email, required String password}) async {
    final res = await _dio.post('/auth/sign-up', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<User> me() async {
    final res = await _dio.get('/auth/me');
=======
  Future<User> me() async {
    final token = await _store.getAccessToken();
    final res = await _dio.get(
      '/auth/me',
      options: token == null
          ? null
          : Options(headers: {'Authorization': 'Bearer $token'}),
    );
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tokens> refresh({required String refreshToken}) async {
    final res = await _dio.post('/auth/refresh', data: {'refresh': refreshToken});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
<<<<<<< HEAD
  Future<void> requestDeleteCode({required String email}) async {
    await _dio.post('/auth/delete-account/request', data: {'email': email});
  }

  @override
  Future<void> deleteAccount({required String email, required String code}) async {
    await _dio.post('/auth/delete-account/confirm', data: {'email': email, 'code': code});
=======
  Future<Tokens> register({required String email, required String password}) async {
    final res = await _dio.post('/auth/register', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  }
}

// Simple mock for local development
class AuthApiMock implements AuthApi {
<<<<<<< HEAD
  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Tokens(access: 'mock-access-token', refresh: 'mock-refresh-token');
  }

  @override
  Future<Tokens> signUp({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
=======
  static String? _currentEmail;
  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentEmail = email;
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    return const Tokens(access: 'mock-access-token', refresh: 'mock-refresh-token');
  }

  @override
  Future<User> me() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
<<<<<<< HEAD
    return const User(id: 'u_1', email: 'demo@example.com', role: 'user');
=======
    if (_currentEmail == null) {
      // Not signed in: signal to caller so UI can show Sign In instead of a placeholder email
      throw Exception('No active session');
    }
    final email = _currentEmail!;
    final role = email.toLowerCase().contains('admin') ? 'admin' : 'user';
    return User(id: 'u_1', email: email, role: role);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  }

  @override
  Future<Tokens> refresh({required String refreshToken}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const Tokens(access: 'mock-access-token-ref', refresh: 'mock-refresh-token-ref');
  }

  @override
<<<<<<< HEAD
  Future<void> requestDeleteCode({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> deleteAccount({required String email, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
=======
  Future<Tokens> register({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentEmail = email;
    return const Tokens(access: 'mock-access-token-new', refresh: 'mock-refresh-token-new');
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
<<<<<<< HEAD
  // Use separate raw dio to avoid interceptor cycles
  final dio = ref.watch(authDioProvider);
  return AuthApiImpl(dio);
  // return AuthApiMock();
=======
  // Use real API when API_BASE_URL is configured; fall back to mock otherwise.
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  if (env == null || env.apiBaseUrl.isEmpty) {
    return AuthApiMock();
  }
  // Use separate raw dio to avoid interceptor cycles
  final dio = ref.watch(authDioProvider);
  final store = ref.watch(tokenStoreProvider);
  return AuthApiImpl(dio, store);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
});
