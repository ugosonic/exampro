import 'package:citizentest/app/router.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/notifications/notification_payload.dart';
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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
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
  );
});

const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class PushNotificationsService {
  PushNotificationsService({required AppDatabase db, required GoRouter router})
    : _db = db,
      _router = router;

  final AppDatabase _db;
  final GoRouter _router;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb || _isFlutterTest) return;
    _initialized = true;

    await NotificationsService.init(onNotificationTap: _handleLocalTap);

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseMessaging.instance.requestPermission();
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await NotificationSettings.setFcmToken(_db, token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      if (t.isNotEmpty) {
        NotificationSettings.setFcmToken(_db, t);
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
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
      _handleMessageTap(message.data);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _handleMessageTap(initial.data);
    }

    try {
      await PendingTestReminderService.sync(_db);
    } catch (_) {
      // Reminder scheduling must not block app startup or sign-in flow.
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
