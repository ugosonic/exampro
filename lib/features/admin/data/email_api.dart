import 'package:dio/dio.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailApi {
  final Dio _dio;
  final String _url;
  final String _key;
  EmailApi(this._dio, {required String url, required String key})
      : _url = url,
        _key = key;

  Future<void> sendEmail({required List<String> to, required String subject, String? text, String? html}) async {
    if (_url.isEmpty) {
      throw StateError('Email API URL not configured');
    }
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_key.isNotEmpty) headers['Authorization'] = 'Bearer $_key';
    await _dio.post(_url,
        options: Options(headers: headers),
        data: {
          'to': to,
          'subject': subject,
          if (text != null) 'text': text,
          if (html != null) 'html': html,
        });
  }
}

final emailApiProvider = Provider<EmailApi>((ref) {
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  final dio = ref.watch(dioProvider); // includes JWT via AuthInterceptor
  String url = env?.emailApiUrl ?? '';
  if ((url.isEmpty) && (env?.apiBaseUrl.isNotEmpty == true)) {
    final base = env!.apiBaseUrl.endsWith('/') ? env.apiBaseUrl.substring(0, env.apiBaseUrl.length - 1) : env.apiBaseUrl;
    url = '$base/admin/send-email';
  }
  final key = env?.emailApiKey ?? '';
  return EmailApi(dio, url: url, key: key);
});
