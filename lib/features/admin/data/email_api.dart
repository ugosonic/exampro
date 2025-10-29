import 'package:dio/dio.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailApi {
  final Dio _dio;
  final String _url;
  final String _key;
  EmailApi(this._dio, {required String url, required String key})
      : _url = url,
        _key = key;

  Future<void> sendEmail({required List<String> to, required String subject, String? text, String? html}) async {
    if (_url.isEmpty || _key.isEmpty) {
      throw StateError('Email API not configured');
    }
    await _dio.post(_url,
        options: Options(headers: {'Authorization': 'Bearer $_key', 'Content-Type': 'application/json'}),
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
  final dio = Dio();
  return EmailApi(dio, url: env?.emailApiUrl ?? '', key: env?.emailApiKey ?? '');
});

