import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
    onDidReceiveNotificationResponse: (details) =>
        _tapHandler?.call(details.payload),
  );
  tzdata.initializeTimeZones();
  await _ensureAndroidPermissions();
  debugPrint('[reminder notifications] initialized');
  _initialized = true;
}

Future<void> showNow(
  int id, {
  required String title,
  required String body,
  String? payload,
}) async {
  await _ensureReady();
  if (!await _ensureAndroidPermissions()) return;
  const androidDetails = AndroidNotificationDetails(
    _defaultChannelId,
    _defaultChannelName,
    importance: Importance.high,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);
  await _plugin.show(id, title, body, details, payload: payload);
  debugPrint('[reminder notifications] showNow id=$id title=$title');
}

Future<void> scheduleDaily(
  int id,
  int hour,
  int minute, {
  required String title,
  required String body,
  String? payload,
}) async {
  await _ensureReady();
  if (!await _ensureAndroidPermissions()) return;
  const androidDetails = AndroidNotificationDetails(
    _defaultChannelId,
    _defaultChannelName,
    importance: Importance.high,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);
  final when = _nextInstanceOfTime(hour, minute);
  try {
    debugPrint(
      '[reminder notifications] scheduleDaily exact id=$id at=$when hour=$hour minute=$minute',
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } on PlatformException catch (e) {
    if (e.code != 'exact_alarms_not_permitted') rethrow;
    debugPrint(
      '[reminder notifications] exact alarm not permitted, falling back to inexact '
      'id=$id at=$when',
    );
    // Android 13+/14 may block exact alarms. Fall back to inexact so reminders
    // still work instead of crashing exam load/resume flows.
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint(
      '[reminder notifications] scheduleDaily inexact id=$id at=$when',
    );
  } catch (e) {
    debugPrint('[reminder notifications] scheduleDaily failed id=$id error=$e');
  }
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

Future<void> cancel(int id) async => _plugin.cancel(id);
Future<void> cancelAll() async => _plugin.cancelAll();

Future<void> _ensureReady() async {
  if (_initialized) return;
  await init();
}

Future<bool> _ensureAndroidPermissions() async {
  final androidPlugin = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (androidPlugin == null) return true;
  final notifEnabledBefore = await androidPlugin.areNotificationsEnabled();
  final canExactBefore = await androidPlugin.canScheduleExactNotifications();
  debugPrint(
    '[reminder notifications] pre-permission '
    'notifications=$notifEnabledBefore exact=$canExactBefore',
  );

  final notifRequestResult = await androidPlugin
      .requestNotificationsPermission();
  debugPrint(
    '[reminder notifications] requestNotificationsPermission '
    'result=$notifRequestResult',
  );

  try {
    if (canExactBefore == false) {
      final exactResult = await androidPlugin.requestExactAlarmsPermission();
      debugPrint(
        '[reminder notifications] requestExactAlarmsPermission '
        'result=$exactResult',
      );
    }
  } catch (_) {
    // Exact alarm permission API can be unavailable on some Android versions.
  }
  final enabled = await androidPlugin.areNotificationsEnabled() ?? true;
  final canExactAfter = await androidPlugin.canScheduleExactNotifications();
  debugPrint(
    '[reminder notifications] post-permission '
    'notifications=$enabled exact=$canExactAfter',
  );
  if (!enabled) {
    debugPrint(
      '[reminder notifications] blocked: notifications permission denied',
    );
  }
  return enabled;
}
