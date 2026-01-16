import 'package:citizentest/core/db/db_provider.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_controller.dart';

class Translator {
  final Ref ref;
  Translator(this.ref);

  Future<String> t(String entity, int id, String key, String fallback) async {
    final lang = ref.read(localeProvider).languageCode;
    if (lang == 'en') return fallback;
    try {
      final db = ref.read(dbProvider);
      final rows = await db.customSelect('SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
          variables: [Variable<String>(entity), Variable<int>(id), Variable<String>(lang), Variable<String>(key)]).get();
      if (rows.isNotEmpty) {
        final v = (rows.first.data['v'] as String?) ?? fallback;
        if (v.isNotEmpty) return v;
      }
    } catch (_) {}
    return fallback;
  }
}

final translatorProvider = Provider<Translator>((ref) => Translator(ref));
