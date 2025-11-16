// Web implementation: no-ops to avoid plugin use on web
Future<void> init() async {}
Future<void> scheduleDaily(int id, int hour, int minute, {required String title, required String body}) async {}
Future<void> cancel(int id) async {}

