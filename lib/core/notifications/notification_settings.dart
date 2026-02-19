import 'package:citizentest/core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;

class NotificationSettings {
  static const _enabledKey = 'notifications_enabled';
  static const _reminderHourKey = 'pending_reminder_hour';
  static const _reminderMinuteKey = 'pending_reminder_minute';
  static const _reviewPromptLastKey = 'review_prompt_last';
  static const _fcmTokenKey = 'fcm_token';

  static Future<bool> getEnabled(AppDatabase db) async {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(_enabledKey))).getSingleOrNull();
    final v = row?.value.trim();
    if (v == null || v.isEmpty) return true;
    return v == '1' || v.toLowerCase() == 'true';
  }

  static Future<void> setEnabled(AppDatabase db, bool enabled) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(key: drift.Value(_enabledKey), value: drift.Value(enabled ? '1' : '0')),
        );
  }

  static Future<int> getReminderHour(AppDatabase db) async {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(_reminderHourKey))).getSingleOrNull();
    final v = int.tryParse(row?.value ?? '');
    return v ?? 19;
  }

  static Future<int> getReminderMinute(AppDatabase db) async {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(_reminderMinuteKey))).getSingleOrNull();
    final v = int.tryParse(row?.value ?? '');
    return v ?? 0;
  }

  static Future<void> setReminderTime(AppDatabase db, {required int hour, required int minute}) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(key: drift.Value(_reminderHourKey), value: drift.Value(hour.toString())),
        );
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(key: drift.Value(_reminderMinuteKey), value: drift.Value(minute.toString())),
        );
  }

  static Future<DateTime?> getReviewPromptLast(AppDatabase db) async {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(_reviewPromptLastKey))).getSingleOrNull();
    final ms = int.tryParse(row?.value ?? '');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> setReviewPromptLast(AppDatabase db, DateTime when) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(key: drift.Value(_reviewPromptLastKey), value: drift.Value(when.millisecondsSinceEpoch.toString())),
        );
  }

  static Future<void> setFcmToken(AppDatabase db, String token) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(key: drift.Value(_fcmTokenKey), value: drift.Value(token)),
        );
  }
}
