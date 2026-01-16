<<<<<<< HEAD
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  Future<void> showDailyReminderNow() async {
    const androidDetails = AndroidNotificationDetails('daily_goal', 'Daily Goal', importance: Importance.defaultImportance);
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(1, 'Keep your streak!', 'Practice for 15 minutes today', details);
  }
=======
// Provide a single NotificationsService API and choose an implementation
// per-platform via conditional imports.
import 'notifications_impl_mobile.dart' if (dart.library.html) 'notifications_impl_web.dart' as impl;

class NotificationsService {
  static Future<void> init() => impl.init();
  static Future<void> scheduleDaily(int id, int hour, int minute, {required String title, required String body}) =>
      impl.scheduleDaily(id, hour, minute, title: title, body: body);
  static Future<void> cancel(int id) => impl.cancel(id);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
}
