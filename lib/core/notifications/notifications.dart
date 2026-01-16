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
}
