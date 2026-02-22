import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/notifications/notification_payload.dart';
import 'package:citizentest/core/notifications/notification_settings.dart';
import 'package:citizentest/core/notifications/notifications.dart';
import 'package:flutter/foundation.dart';

class PendingTestReminderService {
  static const int notificationId = 2002;
  static const String payloadType = 'pending_test';

  static Future<void> sync(AppDatabase db) async {
    final enabled = await NotificationSettings.getEnabled(db);
    if (!enabled) {
      debugPrint('[reminder notifications] disabled -> cancel notification');
      await NotificationsService.cancel(notificationId);
      return;
    }
    final hour = await NotificationSettings.getReminderHour(db);
    final minute = await NotificationSettings.getReminderMinute(db);
    debugPrint(
      '[reminder notifications] sync enabled=true at '
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    );

    final attempt = await _latestPendingAttempt(db);
    if (attempt != null) {
      final exam = await (db.select(
        db.exams,
      )..where((e) => e.id.equals(attempt.examId))).getSingleOrNull();
      final payload = NotificationPayload(
        type: payloadType,
        examId: attempt.examId,
        attemptId: attempt.id,
        mode: attempt.mode,
      ).toEncoded();
      final examTitle = exam?.title ?? 'your test';
      debugPrint(
        '[reminder notifications] scheduling pending assignment reminder '
        'attempt=${attempt.id} exam=${attempt.examId}',
      );
      await NotificationsService.scheduleDaily(
        notificationId,
        hour,
        minute,
        title: 'Pending test reminder',
        body: 'Continue $examTitle',
        payload: payload,
      );
      return;
    }

    final practice = await _latestPendingPracticeCategory(db);
    if (practice != null) {
      final category = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(practice.categoryId))).getSingleOrNull();
      final payload = NotificationPayload(
        type: payloadType,
        examId: 0,
        categoryId: practice.categoryId,
        mode: 'practice',
      ).toEncoded();
      final label = category?.name ?? 'practice';
      debugPrint(
        '[reminder notifications] scheduling pending practice reminder '
        'category=${practice.categoryId} index=${practice.index}/${practice.total}',
      );
      await NotificationsService.scheduleDaily(
        notificationId,
        hour,
        minute,
        title: 'Pending practice reminder',
        body: 'Continue $label',
        payload: payload,
      );
      return;
    }

    debugPrint(
      '[reminder notifications] no pending assignment/practice -> cancel notification',
    );
    await NotificationsService.cancel(notificationId);
  }

  static Future<void> clear() => NotificationsService.cancel(notificationId);

  static Future<Attempt?> _latestPendingAttempt(AppDatabase db) async {
    final rows = await db
        .customSelect(
          'SELECT id FROM attempts WHERE ended_at IS NULL ORDER BY started_at DESC LIMIT 1',
        )
        .get();
    if (rows.isEmpty) return null;
    final id = rows.first.data['id'] as int;
    return await (db.select(
      db.attempts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  static Future<({int categoryId, int index, int total})?>
  _latestPendingPracticeCategory(AppDatabase db) async {
    final rows = await db
        .customSelect(
          'SELECT p.category_id AS cid, p."index" AS idx, '
          'COALESCE(COUNT(DISTINCT eq.question_id), 0) AS total '
          'FROM practice_progress p '
          'LEFT JOIN exams e ON e.category_id = p.category_id '
          'LEFT JOIN exam_questions eq ON eq.exam_id = e.id '
          'GROUP BY p.category_id, p."index", p.updated_at '
          'HAVING p."index" > 0 AND p."index" < total '
          'ORDER BY p.updated_at DESC LIMIT 1',
        )
        .get();
    if (rows.isEmpty) return null;
    final row = rows.first.data;
    final cid = (row['cid'] as num?)?.toInt();
    final idx = (row['idx'] as num?)?.toInt();
    final total = (row['total'] as num?)?.toInt();
    if (cid == null || idx == null || total == null || total <= 0) return null;
    return (categoryId: cid, index: idx, total: total);
  }
}
