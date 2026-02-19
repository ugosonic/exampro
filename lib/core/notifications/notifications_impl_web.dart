// Web implementation: no-ops to avoid plugin use on web
Future<void> init({void Function(String? payload)? onNotificationTap}) async {}
Future<void> showNow(int id, {required String title, required String body, String? payload}) async {}
Future<void> scheduleDaily(int id, int hour, int minute, {required String title, required String body, String? payload}) async {}
Future<void> cancel(int id) async {}
Future<void> cancelAll() async {}

