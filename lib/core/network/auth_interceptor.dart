import 'dart:async';

import 'package:dio/dio.dart';
import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/data/auth_api.dart';

class AuthInterceptor extends Interceptor {
  final TokenStore tokenStore;
  final AuthApi authApi;
  Future<void>? _refreshing;
  AuthInterceptor(this.tokenStore, this.authApi);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStore.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _refreshToken();
      final newAccess = await tokenStore.getAccessToken();
      if (newAccess != null) {
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        try {
          final response = await err.requestOptions.retry();
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    super.onError(err, handler);
  }

  Future<void> _refreshToken() async {
    if (_refreshing != null) {
      await _refreshing;
      return;
    }
    _refreshing = () async {
      final refresh = await tokenStore.getRefreshToken();
      if (refresh == null) return;
      try {
        final tokens = await authApi.refresh(refreshToken: refresh);
        await tokenStore.save(TokenBundle(accessToken: tokens.access, refreshToken: tokens.refresh));
      } catch (_) {}
    }();
    await _refreshing;
    _refreshing = null;
  }
}

extension _Retry on RequestOptions {
  Future<Response<dynamic>> retry() {
    final client = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));
    return client.request(path, data: data, queryParameters: queryParameters, options: Options(method: method));
  }
}
