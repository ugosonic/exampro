import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

final _plugin = FlutterLocalNotificationsPlugin();
const _defaultChannelId = 'reminders';
const _defaultChannelName = 'Reminders';
bool _initialized = false;
void Function(String? payload)? _tapHandler;

Future<void> init({void Function(String? payload)? onNotificationTap}) async {
  if (onNotificationTap != null) {
    _tapHandler = onNotificationTap;
  }
  if (_initialized) return;
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await _plugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) => _tapHandler?.call(details.payload),
  );
  tzdata.initializeTimeZones();
  final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
  _initialized = true;
}

Future<void> showNow(
  int id, {
  required String title,
  required String body,
  String? payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    _defaultChannelId,
    _defaultChannelName,
    importance: Importance.high,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);
  await _plugin.show(id, title, body, details, payload: payload);
}

Future<void> scheduleDaily(
  int id,
  int hour,
  int minute, {
  required String title,
  required String body,
  String? payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    _defaultChannelId,
    _defaultChannelName,
    importance: Importance.high,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);
  await _plugin.zonedSchedule(
    id,
    title,
    body,
    _nextInstanceOfTime(hour, minute),
    details,
    payload: payload,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

Future<void> cancel(int id) async => _plugin.cancel(id);
Future<void> cancelAll() async => _plugin.cancelAll();

