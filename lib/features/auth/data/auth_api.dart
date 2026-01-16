import 'package:dio/dio.dart';
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
}

class AuthApiImpl implements AuthApi {
  final Dio _dio;
  AuthApiImpl(this._dio);

  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    final res = await _dio.post('/auth/sign-in', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tokens> signUp({required String email, required String password}) async {
    final res = await _dio.post('/auth/sign-up', data: {'email': email, 'password': password});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<User> me() async {
    final res = await _dio.get('/auth/me');
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tokens> refresh({required String refreshToken}) async {
    final res = await _dio.post('/auth/refresh', data: {'refresh': refreshToken});
    return Tokens.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> requestDeleteCode({required String email}) async {
    await _dio.post('/auth/delete-account/request', data: {'email': email});
  }

  @override
  Future<void> deleteAccount({required String email, required String code}) async {
    await _dio.post('/auth/delete-account/confirm', data: {'email': email, 'code': code});
  }
}

// Simple mock for local development
class AuthApiMock implements AuthApi {
  @override
  Future<Tokens> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Tokens(access: 'mock-access-token', refresh: 'mock-refresh-token');
  }

  @override
  Future<Tokens> signUp({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const Tokens(access: 'mock-access-token', refresh: 'mock-refresh-token');
  }

  @override
  Future<User> me() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const User(id: 'u_1', email: 'demo@example.com', role: 'user');
  }

  @override
  Future<Tokens> refresh({required String refreshToken}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const Tokens(access: 'mock-access-token-ref', refresh: 'mock-refresh-token-ref');
  }

  @override
  Future<void> requestDeleteCode({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> deleteAccount({required String email, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  // Use separate raw dio to avoid interceptor cycles
  final dio = ref.watch(authDioProvider);
  return AuthApiImpl(dio);
  // return AuthApiMock();
});
