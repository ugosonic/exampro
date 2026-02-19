// Provide a single NotificationsService API and choose an implementation
// per-platform via conditional imports.
import 'notifications_impl_mobile.dart' if (dart.library.html) 'notifications_impl_web.dart' as impl;

class NotificationsService {
  static Future<void> init({void Function(String? payload)? onNotificationTap}) =>
      impl.init(onNotificationTap: onNotificationTap);

  static Future<void> showNow(
    int id, {
    required String title,
    required String body,
    String? payload,
  }) =>
      impl.showNow(id, title: title, body: body, payload: payload);

  static Future<void> scheduleDaily(
    int id,
    int hour,
    int minute, {
    required String title,
    required String body,
    String? payload,
  }) =>
      impl.scheduleDaily(id, hour, minute, title: title, body: body, payload: payload);

  static Future<void> cancel(int id) => impl.cancel(id);
  static Future<void> cancelAll() => impl.cancelAll();
}
