import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/notifications/notification_payload.dart';
import 'package:citizentest/core/notifications/notification_settings.dart';
import 'package:citizentest/core/notifications/notifications.dart';

class PendingTestReminderService {
  static const int notificationId = 2002;
  static const String payloadType = 'pending_test';

  static Future<void> sync(AppDatabase db) async {
    final enabled = await NotificationSettings.getEnabled(db);
    if (!enabled) {
      await NotificationsService.cancel(notificationId);
      return;
    }
    final attempt = await _latestPendingAttempt(db);
    if (attempt == null) {
      await NotificationsService.cancel(notificationId);
      return;
    }
    final exam = await (db.select(db.exams)..where((e) => e.id.equals(attempt.examId))).getSingleOrNull();
    final hour = await NotificationSettings.getReminderHour(db);
    final minute = await NotificationSettings.getReminderMinute(db);
    final payload = NotificationPayload(
      type: payloadType,
      examId: attempt.examId,
      attemptId: attempt.id,
    ).toEncoded();
    final examTitle = exam?.title ?? 'your test';
    await NotificationsService.scheduleDaily(
      notificationId,
      hour,
      minute,
      title: 'Pending test reminder',
      body: 'Continue $examTitle',
      payload: payload,
    );
  }

  static Future<void> clear() => NotificationsService.cancel(notificationId);

  static Future<Attempt?> _latestPendingAttempt(AppDatabase db) async {
    final rows = await db.customSelect(
      'SELECT id FROM attempts WHERE ended_at IS NULL ORDER BY started_at DESC LIMIT 1',
    ).get();
    if (rows.isEmpty) return null;
    final id = rows.first.data['id'] as int;
    return await (db.select(db.attempts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
