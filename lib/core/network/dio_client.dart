import 'package:dio/dio.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/core/network/auth_interceptor.dart';
import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/data/auth_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authDioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
  return Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
  ));
});

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
  final tokenStore = ref.watch(tokenStoreProvider);
  final authApi = ref.watch(authApiProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    AuthInterceptor(tokenStore, authApi),
  ]);
  return dio;
});
