// Provide a single NotificationsService API and choose an implementation
// per-platform via conditional imports.
import 'notifications_impl_mobile.dart' if (dart.library.html) 'notifications_impl_web.dart' as impl;

class NotificationsService {
  static Future<void> init() => impl.init();
  static Future<void> scheduleDaily(int id, int hour, int minute, {required String title, required String body}) =>
      impl.scheduleDaily(id, hour, minute, title: title, body: body);
  static Future<void> cancel(int id) => impl.cancel(id);
}
