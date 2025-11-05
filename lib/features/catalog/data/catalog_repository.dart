import 'package:exampro/core/db/app_database.dart' as db;
import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/catalog/domain/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/features/catalog/data/content_api.dart';

class CatalogRepository {
  final db.AppDatabase _db;
  final ContentApi? _remote;
  CatalogRepository(this._db, [this._remote]);

  Future<String> _lang() async {
    try {
      final row = await (_db.select(_db.appSettings)..where((s) => s.key.equals('lang_code'))).getSingleOrNull();
      return row?.value.isNotEmpty == true ? row!.value : 'en';
    } catch (_) {
      return 'en';
    }
  }

  Future<String> _translate(String entity, int id, String key, String fallback) async {
    final lang = await _lang();
    if (lang == 'en') return fallback;
    try {
      final rows = await _db.customSelect('SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
          variables: [drift.Variable(entity), drift.Variable(id), drift.Variable(lang), drift.Variable(key)]).get();
      if (rows.isNotEmpty) return (rows.first.data['v'] as String?) ?? fallback;
    } catch (_) {}
    return fallback;
  }

  Future<List<models.Category>> categories() async {
    if (_remote != null) {
      final rows = await _remote!.categories();
      return [
        for (final m in rows)
          models.Category(
            id: (m['id'] as num).toInt(),
            name: await _translate('categories', (m['id'] as num).toInt(), 'name', (m['name'] as String)),
            order: (m['order'] as num?)?.toInt() ?? 0,
            imageUrl: (m['image_url'] as String?) ?? '',
            locked: (m['locked'] as bool?) ?? false,
          ),
      ];
    }
    final rows = await (_db.select(_db.categories)
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.order),
            (t) => drift.OrderingTerm.asc(t.name),
          ]))
        .get();
    final out = <models.Category>[];
    for (final r in rows) {
      final name = await _translate('categories', r.id, 'name', r.name);
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
    if (_remote != null) {
      final rows = await _remote!.exams(categoryId: categoryId);
      return [
        for (final m in rows)
          models.ExamSummary(
            id: (m['id'] as num).toInt(),
            title: await _translate('exams', (m['id'] as num).toInt(), 'title', (m['title'] as String? ?? '')),
            categoryId: (m['category_id'] as num).toInt(),
            subcategoryId: (m['subcategory_id'] as num?)?.toInt(),
            questionCount: (m['question_count'] as num?)?.toInt() ?? 0,
            published: (m['published'] as bool?) ?? false,
            themeKey: (m['theme_key'] as num?)?.toInt() ?? 0,
          ),
      ];
    }
    final query = (categoryId == null)
        ? _db.select(_db.exams)
        : (_db.select(_db.exams)..where((tbl) => tbl.categoryId.equals(categoryId)));
    query.where((e) => e.published.equals(true));
    final rows = await query.get();
    return [
      for (final r in rows)
        models.ExamSummary(
              id: r.id,
              title: await _translate('exams', r.id, 'title', r.title),
              categoryId: r.categoryId,
              subcategoryId: r.subcategoryId,
              questionCount: r.questionCount,
              published: r.published,
              themeKey: r.themeKey,
            )
    ];
  }

  Stream<List<models.Category>> watchCategories() {
    if (_remote != null) {
      // Simple one-shot stream; refreshes happen when the screen pulls again
      return Stream.fromFuture(categories());
    }
    return (_db.select(_db.categories)
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.order),
            (t) => drift.OrderingTerm.asc(t.name),
          ]))
        .watch()
        .asyncMap((rows) async {
      final out = <models.Category>[];
      for (final r in rows) {
        final name = await _translate('categories', r.id, 'name', r.name);
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
  }

  Future<bool> isCategoryLocked(int id) async {
    if (_remote != null) {
      final rows = await _remote!.categories();
      final m = rows.firstWhere((e) => (e['id'] as num).toInt() == id, orElse: () => {} as Map<String, dynamic>);
      return (m.isEmpty) ? false : ((m['locked'] as bool?) ?? false);
    }
    final row = await (_db.select(_db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
    return row?.locked ?? false;
  }
}

// Providers
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  final hasApi = env != null && env!.apiBaseUrl.isNotEmpty;
  final remote = hasApi ? ref.watch(contentApiProvider) : null;
  return CatalogRepository(dbi, remote);
});

final categoriesProvider = StreamProvider<List<models.Category>>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.watchCategories();
});
