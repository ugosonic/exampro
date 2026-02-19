import 'package:citizentest/core/db/app_database.dart' as db;
import 'package:drift/drift.dart' as drift;
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/features/catalog/domain/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogRepository {
  final db.AppDatabase _db;
  CatalogRepository(this._db);

  Future<String> _loadLang() async {
    try {
      final row = await (_db.select(_db.appSettings)..where((s) => s.key.equals('lang_code'))).getSingleOrNull();
      return row?.value.isNotEmpty == true ? row!.value : 'en';
    } catch (_) {
      return 'en';
    }
  }

  Future<String> translate(String entity, int id, String key, String fallback) async {
    final languageCode = await _loadLang();
    if (languageCode == 'en') return fallback;
    try {
      final rows = await _db.customSelect('SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
          variables: [drift.Variable(entity), drift.Variable(id), drift.Variable(languageCode), drift.Variable(key)]).get();
      if (rows.isNotEmpty) return (rows.first.data['v'] as String?) ?? fallback;
    } catch (_) {}
    return fallback;
  }

  Future<List<models.Category>> categories() async {
    final rows = await (_db.select(_db.categories)
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.order),
            (t) => drift.OrderingTerm.asc(t.name),
          ]))
        .get();
    final out = <models.Category>[];
    for (final r in rows) {
      final name = await translate('categories', r.id, 'name', r.name);
      out.add(models.Category(
        id: r.id,
        name: name,
        order: r.order,
        imageUrl: r.imageUrl,
        locked: r.locked,
      ));
    }
    return out;
  }

  Future<List<models.ExamSummary>> exams({int? categoryId}) async {
    final query = (categoryId == null)
        ? _db.select(_db.exams)
        : (_db.select(_db.exams)..where((tbl) => tbl.categoryId.equals(categoryId)));
    query.where((e) => e.published.equals(true));
    final rows = await query.get();
    return [
      for (final r in rows)
        models.ExamSummary(
              id: r.id,
              title: await translate('exams', r.id, 'title', r.title),
              categoryId: r.categoryId,
              subcategoryId: r.subcategoryId,
              questionCount: r.questionCount,
              published: r.published,
              themeKey: r.themeKey,
            )
    ];
  }

  Stream<List<models.Category>> watchCategories() {
    // Watch local DB for reactive updates
    final stream = (_db.select(_db.categories)
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.order),
            (t) => drift.OrderingTerm.asc(t.name),
          ]))
        .watch()
        .asyncMap((rows) async {
      final out = <models.Category>[];
      for (final r in rows) {
        final name = await translate('categories', r.id, 'name', r.name);
        out.add(models.Category(
          id: r.id,
          name: name,
          order: r.order,
          imageUrl: r.imageUrl,
          locked: r.locked,
        ));
      }
      return out;
    });
    return stream;
  }

  Future<bool> isCategoryLocked(int id) async {
    final row = await (_db.select(_db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
    return row?.locked ?? false;
  }
}

// Providers
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  return CatalogRepository(dbi);
});

final categoriesProvider = StreamProvider<List<models.Category>>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.watchCategories();
});
