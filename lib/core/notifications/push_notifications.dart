import 'package:citizentest/app/router.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/notifications/notification_payload.dart';
import 'package:citizentest/core/notifications/notifications_api.dart';
import 'package:citizentest/core/notifications/notification_settings.dart';
import 'package:citizentest/core/notifications/notifications.dart';
import 'package:citizentest/core/notifications/pending_test_reminder.dart';
import 'package:citizentest/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  debugPrint(
    '[push notifications] background message '
    'id=${message.messageId} data=${message.data}',
  );
  await NotificationsService.init();
  final data = message.data;
  final payload = NotificationPayload.fromMap(data);
  if (payload == null) return;
  await NotificationsService.showNow(
    PendingTestReminderService.notificationId,
    title: message.notification?.title ?? 'Pending test reminder',
    body: message.notification?.body ?? 'Continue your test',
    payload: payload.toEncoded(),
  );
}

final pushNotificationsProvider = Provider<PushNotificationsService>((ref) {
  return PushNotificationsService(
    db: ref.watch(dbProvider),
    router: ref.watch(appRouterProvider),
    api: ref.watch(notificationsApiProvider),
  );
});

const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class PushNotificationsService {
  PushNotificationsService({
    required AppDatabase db,
    required GoRouter router,
    required NotificationsApi api,
  }) : _db = db,
       _router = router,
       _api = api;

  final AppDatabase _db;
  final GoRouter _router;
  final NotificationsApi _api;
  bool _initialized = false;
  String? _lastUploadedToken;

  Future<void> init() async {
    if (_initialized || kIsWeb || _isFlutterTest) return;
    _initialized = true;

    await NotificationsService.init(onNotificationTap: _handleLocalTap);

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      final permission = await FirebaseMessaging.instance.requestPermission();
      debugPrint(
        '[push notifications] requestPermission '
        'status=${permission.authorizationStatus}',
      );
    }

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint(
      '[push notifications] fcm token '
      '${token == null ? 'null' : '${token.substring(0, token.length > 14 ? 14 : token.length)}...'}',
    );
    if (token != null && token.isNotEmpty) {
      await NotificationSettings.setFcmToken(_db, token);
      await _uploadTokenIfPossible(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
      if (t.isNotEmpty) {
        await NotificationSettings.setFcmToken(_db, t);
        await _uploadTokenIfPossible(t);
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(
        '[push notifications] onMessage '
        'id=${message.messageId} data=${message.data}',
      );
      final enabled = await NotificationSettings.getEnabled(_db);
      if (!enabled) return;
      final payload = NotificationPayload.fromMap(message.data);
      if (payload == null) return;
      await NotificationsService.showNow(
        PendingTestReminderService.notificationId,
        title: message.notification?.title ?? 'Pending test reminder',
        body: message.notification?.body ?? 'Continue your test',
        payload: payload.toEncoded(),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
        '[push notifications] onMessageOpenedApp '
        'id=${message.messageId} data=${message.data}',
      );
      _handleMessageTap(message.data);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint(
        '[push notifications] getInitialMessage '
        'id=${initial.messageId} data=${initial.data}',
      );
      _handleMessageTap(initial.data);
    }

    try {
      await PendingTestReminderService.sync(_db);
    } catch (_) {
      // Reminder scheduling must not block app startup or sign-in flow.
    }
  }

  Future<void> syncTokenWithBackend() async {
    if (kIsWeb || _isFlutterTest) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _uploadTokenIfPossible(token, force: true);
      }
    } catch (e) {
      debugPrint('[push notifications] syncTokenWithBackend failed: $e');
    }
  }

  Future<void> sendReminderPreviewForCurrentPending() async {
    if (kIsWeb || _isFlutterTest) return;
    final reminder = await PendingTestReminderService.nextReminder(_db);
    if (reminder == null) {
      debugPrint(
        '[push notifications] reminder preview skipped (no pending item)',
      );
      return;
    }
    try {
      await _api.sendReminderPreview(
        title: reminder.title,
        body: reminder.body,
        payload: reminder.payload,
      );
      debugPrint(
        '[push notifications] reminder preview sent payload=${reminder.payload.toJson()}',
      );
    } catch (e) {
      debugPrint('[push notifications] reminder preview failed: $e');
    }
  }

  Future<void> _uploadTokenIfPossible(
    String token, {
    bool force = false,
  }) async {
    if (!force && _lastUploadedToken == token) return;
    try {
      final info = await PackageInfo.fromPlatform();
      await _api.registerToken(
        token: token,
        platform: defaultTargetPlatform.name,
        appVersion: info.version,
      );
      _lastUploadedToken = token;
      debugPrint('[push notifications] token registered on backend');
    } catch (e) {
      debugPrint('[push notifications] token register failed: $e');
    }
  }

  void _handleLocalTap(String? payload) {
    final parsed = NotificationPayload.fromEncoded(payload);
    if (parsed == null) return;
    _routeFromPayload(parsed);
  }

  void _handleMessageTap(Map<String, dynamic> data) {
    final parsed = NotificationPayload.fromMap(data);
    if (parsed == null) return;
    _routeFromPayload(parsed);
  }

  void _routeFromPayload(NotificationPayload payload) {
    if (payload.type != PendingTestReminderService.payloadType) return;
    final examId = payload.examId;
    final attemptId = payload.attemptId;
    final categoryId = payload.categoryId;
    final mode = payload.mode ?? 'practice';

    if (examId != null && attemptId != null) {
      _router.go('/player/$examId?aid=$attemptId');
      return;
    }
    if (mode == 'practice' && categoryId != null) {
      _router.go('/player/0?mode=practice&cat=$categoryId');
      return;
    }
    if (examId != null) {
      _router.go('/player/$examId?mode=$mode');
    }
  }
}
