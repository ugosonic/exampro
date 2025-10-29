import 'package:dio/dio.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/core/network/auth_interceptor.dart';
import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/data/auth_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authDioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
  _enforceHttpsInProd(env.apiBaseUrl, env.environment);
  return Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 90),
    headers: {'Accept': 'application/json'},
  ));
});

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
  final tokenStore = ref.watch(tokenStoreProvider);
  final authApi = ref.watch(authApiProvider);
  _enforceHttpsInProd(env.apiBaseUrl, env.environment);
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    AuthInterceptor(tokenStore, authApi),
  ]);
  return dio;
});

void _enforceHttpsInProd(String baseUrl, String environment) {
  final isProd = environment.toLowerCase().contains('prod');
  if (isProd && baseUrl.toLowerCase().startsWith('http://')) {
    throw StateError('Insecure API_BASE_URL over HTTP in production. Use HTTPS.');
  }
}
