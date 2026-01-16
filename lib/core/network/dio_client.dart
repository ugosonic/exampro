import 'package:dio/dio.dart';
<<<<<<< HEAD
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/core/network/auth_interceptor.dart';
import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/data/auth_api.dart';
=======
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/network/auth_interceptor.dart';
import 'package:citizentest/core/auth/token_store.dart';
import 'package:citizentest/features/auth/data/auth_api.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authDioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
<<<<<<< HEAD
  return Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
=======
  _enforceHttpsInProd(env.apiBaseUrl, env.environment);
  return Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 90),
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    headers: {'Accept': 'application/json'},
  ));
});

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
  final tokenStore = ref.watch(tokenStoreProvider);
  final authApi = ref.watch(authApiProvider);
<<<<<<< HEAD
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
=======
  _enforceHttpsInProd(env.apiBaseUrl, env.environment);
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    AuthInterceptor(tokenStore, authApi),
  ]);
  return dio;
});
<<<<<<< HEAD
=======

void _enforceHttpsInProd(String baseUrl, String environment) {
  final isProd = environment.toLowerCase().contains('prod');
  if (isProd && baseUrl.toLowerCase().startsWith('http://')) {
    throw StateError('Insecure API_BASE_URL over HTTP in production. Use HTTPS.');
  }
}
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
