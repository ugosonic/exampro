import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_controller.dart';

final translationPopulatorProvider = Provider<TranslationPopulator>((ref) => TranslationPopulator(ref));

class TranslationPopulator {
  final Ref ref;
  TranslationPopulator(this.ref);

  Dio get _dio => Dio(BaseOptions(connectTimeout: const Duration(seconds: 20), receiveTimeout: const Duration(seconds: 40)));

  Future<String> _translate(String text, String toLang) async {
    if (text.trim().isEmpty) return text;
    final url = Uri.https('translate.googleapis.com', '/translate_a/single', {
      'client': 'gtx',
      'sl': 'auto',
      'tl': toLang,
      'dt': 't',
      'q': text,
    });
    final resp = await _dio.getUri(url);
    // Response format: [[["translated","original",null,null, ... ]]]
    try {
      final data = resp.data;
      if (data is List && data.isNotEmpty) {
        final first = data[0];
        if (first is List && first.isNotEmpty && first[0] is List) {
          final seg = first[0];
          if (seg is List && seg.isNotEmpty && seg[0] is String) {
            return seg[0] as String;
          }
        }
      }
    } catch (_) {}
    // Fallback attempt: JSON decode string body
    try {
      final arr = jsonDecode(resp.data as String) as List;
      return (((arr[0] as List)[0] as List)[0] as String);
    } catch (_) {}
    return text;
  }

  Future<void> populateAll(String lang) async {
    if (lang == 'en') return; // base language
    final db = ref.read(dbProvider);
    // Helper to upsert translation row
    Future<void> upsert(String entity, int id, String k, String v) async {
      try {
        final exists = await db.customSelect(
          'SELECT 1 FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
          variables: [drift.Variable(entity), drift.Variable(id), drift.Variable(lang), drift.Variable(k)],
        ).getSingleOrNull();
        if (exists == null) {
          await db.customStatement(
            'INSERT INTO translations(entity, entity_id, lang, k, v) VALUES (?,?,?,?,?)',
            [entity, id, lang, k, v],
          );
        } else {
          await db.customStatement(
            'UPDATE translations SET v = ? WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ?',
            [v, entity, id, lang, k],
          );
        }
      } catch (_) {}
    }

    // Categories
    final cats = await db.select(db.categories).get();
    for (final c in cats) {
      final t = await _translate(c.name, lang);
      await upsert('categories', c.id, 'name', t);
    }
    // Subcategories
    final subs = await db.select(db.subcategories).get();
    for (final s in subs) {
      final t = await _translate(s.name, lang);
      await upsert('subcategories', s.id, 'name', t);
    }
    // Exams
    final exams = await db.select(db.exams).get();
    for (final e in exams) {
      final title = await _translate(e.title, lang);
      await upsert('exams', e.id, 'title', title);
      if (e.description.isNotEmpty) {
        final desc = await _translate(e.description, lang);
        await upsert('exams', e.id, 'description', desc);
      }
    }
    // Questions
    final qs = await db.select(db.questions).get();
    for (final q in qs) {
      final body = await _translate(q.body, lang);
      await upsert('questions', q.id, 'body', body);
      if (q.explanation.isNotEmpty) {
        final exp = await _translate(q.explanation, lang);
        await upsert('questions', q.id, 'explanation', exp);
      }
    }
    // Choices
    final ch = await db.select(db.choices).get();
    for (final c in ch) {
      final lbl = await _translate(c.label, lang);
      await upsert('choices', c.id, 'label', lbl);
    }
    // Grade bands
    final gb = await db.select(db.examGradeBands).get();
    for (final b in gb) {
      final lbl = await _translate(b.label, lang);
      await upsert('exam_grade_bands', b.id, 'label', lbl);
    }
  }
}

Future<void> applyLanguageAndTranslate(WidgetRef ref, Locale locale, {VoidCallback? onProgress}) async {
  await setAppLocale(ref, locale);
  try {
    onProgress?.call();
  } catch (_) {}
  await ref.read(translationPopulatorProvider).populateAll(locale.languageCode);
  // Nudge watchers dependent on app_settings to refresh after translations are written
  try {
    final db = ref.read(dbProvider);
    await db.into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(key: drift.Value('_i18n_tick'), value: drift.Value(DateTime.now().millisecondsSinceEpoch.toString())),
    );
  } catch (_) {}
}
