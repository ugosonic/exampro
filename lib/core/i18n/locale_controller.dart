import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _langKey = 'lang_code';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

final localeInitializerProvider = FutureProvider<void>((ref) async {
  final db = ref.read(dbProvider);
  try {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(_langKey))).getSingleOrNull();
    if (row != null && row.value.isNotEmpty) {
      ref.read(localeProvider.notifier).state = Locale(row.value);
    }
  } catch (_) {}
});

Future<void> setAppLocale(WidgetRef ref, Locale locale) async {
  final db = ref.read(dbProvider);
  try {
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion(key: Value(_langKey), value: Value(locale.languageCode)));
  } catch (_) {}
  ref.read(localeProvider.notifier).state = locale;
}
