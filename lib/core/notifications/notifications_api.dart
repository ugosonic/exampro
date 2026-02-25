import 'package:citizentest/core/network/dio_client.dart';
import 'package:citizentest/core/notifications/notification_payload.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<void> registerToken({
    required String token,
    required String platform,
    String appVersion = '',
  }) async {
    await _dio.post(
      '/notifications/register-token',
      data: {'token': token, 'platform': platform, 'app_version': appVersion},
    );
  }

  Future<void> sendReminderPreview({
    required String title,
    required String body,
    required NotificationPayload payload,
  }) async {
    await _dio.post(
      '/notifications/reminder-preview',
      data: {'title': title, 'body': body, 'payload': payload.toJson()},
    );
  }
}

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.watch(dioProvider)),
);
