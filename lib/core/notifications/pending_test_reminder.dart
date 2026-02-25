import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/notifications/notification_payload.dart';
import 'package:citizentest/core/notifications/notification_settings.dart';
import 'package:citizentest/core/notifications/notifications.dart';
import 'package:flutter/foundation.dart';

class PendingReminderDraft {
  const PendingReminderDraft({
    required this.title,
    required this.body,
    required this.payload,
  });

  final String title;
  final String body;
  final NotificationPayload payload;
}

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

    final reminder = await nextReminder(db);
    if (reminder == null) {
      debugPrint(
        '[reminder notifications] no pending assignment/practice -> cancel notification',
      );
      await NotificationsService.cancel(notificationId);
      return;
    }
    debugPrint(
      '[reminder notifications] scheduling reminder payload=${reminder.payload.toJson()}',
    );
    await NotificationsService.scheduleDaily(
      notificationId,
      hour,
      minute,
      title: reminder.title,
      body: reminder.body,
      payload: reminder.payload.toEncoded(),
    );
  }

  static Future<PendingReminderDraft?> nextReminder(AppDatabase db) async {
    final attempt = await _latestPendingAttempt(db);
    if (attempt != null) {
      final exam = await (db.select(
        db.exams,
      )..where((e) => e.id.equals(attempt.examId))).getSingleOrNull();
      final examTitle = exam?.title ?? 'your test';
      return PendingReminderDraft(
        title: 'Pending test reminder',
        body: 'Continue $examTitle',
        payload: NotificationPayload(
          type: payloadType,
          examId: attempt.examId,
          attemptId: attempt.id,
          mode: attempt.mode,
        ),
      );
    }

    final practice = await _latestPendingPracticeCategory(db);
    if (practice != null) {
      final category = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(practice.categoryId))).getSingleOrNull();
      final label = category?.name ?? 'practice';
      return PendingReminderDraft(
        title: 'Pending practice reminder',
        body: 'Continue $label',
        payload: NotificationPayload(
          type: payloadType,
          examId: 0,
          categoryId: practice.categoryId,
          mode: 'practice',
        ),
      );
    }
    return null;
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
    List<dynamic> rows;
    try {
      rows = await db
          .customSelect(
            'SELECT p.category_id AS cid, p.progress_index AS idx, '
            'COALESCE(COUNT(DISTINCT eq.question_id), 0) AS total '
            'FROM practice_progress p '
            'LEFT JOIN exams e ON e.category_id = p.category_id '
            'LEFT JOIN exam_questions eq ON eq.exam_id = e.id '
            'GROUP BY p.category_id, p.progress_index, p.updated_at '
            'HAVING p.progress_index > 0 AND p.progress_index < total '
            'ORDER BY p.updated_at DESC LIMIT 1',
          )
          .get();
    } catch (_) {
      rows = await db
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
    }
    if (rows.isEmpty) return null;
    final row = rows.first.data;
    final cid = (row['cid'] as num?)?.toInt();
    final idx = (row['idx'] as num?)?.toInt();
    final total = (row['total'] as num?)?.toInt();
    if (cid == null || idx == null || total == null || total <= 0) return null;
    return (categoryId: cid, index: idx, total: total);
  }
}
