import 'package:citizentest/core/db/app_database.dart' as db;
import 'package:citizentest/core/config/env_loader.dart';
import 'package:drift/drift.dart' as drift;
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/features/catalog/data/content_api.dart';
import 'package:citizentest/features/catalog/domain/models.dart' as models;
import 'package:citizentest/core/text/text_sanitizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogRepository {
  final db.AppDatabase _db;
  final ContentApi? _remote;
  bool _hydratingFromRemote = false;

  CatalogRepository(this._db, [this._remote]);

  Future<String> _loadLang() async {
    try {
      final row = await (_db.select(
        _db.appSettings,
      )..where((s) => s.key.equals('lang_code'))).getSingleOrNull();
      return row?.value.isNotEmpty == true ? row!.value : 'en';
    } catch (_) {
      return 'en';
    }
  }

  Future<String> translate(
    String entity,
    int id,
    String key,
    String fallback,
  ) async {
    final languageCode = await _loadLang();
    final fallbackText = sanitizeDisplayText(fallback);
    if (languageCode == 'en') return fallbackText;
    try {
      final rows = await _db
          .customSelect(
            'SELECT v FROM translations WHERE entity = ? AND entity_id = ? AND lang = ? AND k = ? LIMIT 1',
            variables: [
              drift.Variable(entity),
              drift.Variable(id),
              drift.Variable(languageCode),
              drift.Variable(key),
            ],
          )
          .get();
      if (rows.isNotEmpty) {
        return sanitizeDisplayText(
          (rows.first.data['v'] as String?) ?? fallbackText,
        );
      }
    } catch (_) {}
    return fallbackText;
  }

  Future<List<models.Category>> categories() async {
    var rows =
        await (_db.select(_db.categories)..orderBy([
              (t) => drift.OrderingTerm.asc(t.order),
              (t) => drift.OrderingTerm.asc(t.name),
            ]))
            .get();
    if (rows.isEmpty) {
      await _tryHydrateCategoriesFromRemote();
      rows =
          await (_db.select(_db.categories)..orderBy([
                (t) => drift.OrderingTerm.asc(t.order),
                (t) => drift.OrderingTerm.asc(t.name),
              ]))
              .get();
    }
    return _toModelCategories(rows);
  }

  Future<List<models.ExamSummary>> exams({int? categoryId}) async {
    final query = (categoryId == null)
        ? _db.select(_db.exams)
        : (_db.select(_db.exams)
            ..where((tbl) => tbl.categoryId.equals(categoryId)));
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
        ),
    ];
  }

  Stream<List<models.Category>> watchCategories() {
    // Watch local DB for reactive updates
    final stream =
        (_db.select(_db.categories)..orderBy([
              (t) => drift.OrderingTerm.asc(t.order),
              (t) => drift.OrderingTerm.asc(t.name),
            ]))
            .watch()
            .asyncMap((rows) async {
              if (rows.isEmpty) {
                await _tryHydrateCategoriesFromRemote();
                final refreshed =
                    await (_db.select(_db.categories)..orderBy([
                          (t) => drift.OrderingTerm.asc(t.order),
                          (t) => drift.OrderingTerm.asc(t.name),
                        ]))
                        .get();
                return _toModelCategories(refreshed);
              }
              return _toModelCategories(rows);
            });
    return stream;
  }

  Future<bool> isCategoryLocked(int id) async {
    final row = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    return row?.locked ?? false;
  }

  Future<List<models.Category>> _toModelCategories(
    List<db.Category> rows,
  ) async {
    final out = <models.Category>[];
    for (final r in rows) {
      final name = await translate('categories', r.id, 'name', r.name);
      out.add(
        models.Category(
          id: r.id,
          name: name,
          order: r.order,
          imageUrl: r.imageUrl,
          locked: r.locked,
        ),
      );
    }
    return out;
  }

  Future<void> _tryHydrateCategoriesFromRemote() async {
    if (_remote == null || _hydratingFromRemote) return;
    _hydratingFromRemote = true;
    try {
      final rows = await _remote.categories();
      if (rows.isEmpty) return;
      await _db.transaction(() async {
        for (final m in rows) {
          final id = _asInt(m['id']);
          final name = sanitizeDisplayText((m['name'] ?? '').toString().trim());
          if (id == null || name.isEmpty) continue;
          await _db
              .into(_db.categories)
              .insertOnConflictUpdate(
                db.CategoriesCompanion(
                  id: drift.Value(id),
                  name: drift.Value(name),
                  order: drift.Value(_asInt(m['order']) ?? 0),
                  passPercent: drift.Value(_asInt(m['pass_percent']) ?? 60),
                  imageUrl: drift.Value((m['image_url'] ?? '').toString()),
                  locked: drift.Value(_asBool(m['locked'])),
                ),
              );
        }
      });
    } catch (_) {
      // Keep local-only mode when remote hydration fails.
    } finally {
      _hydratingFromRemote = false;
    }
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1';
  }
}

// Providers
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  final env = ref
      .watch(envLoaderProvider)
      .maybeWhen(data: (e) => e, orElse: () => null);
  final remote = (env != null && env.apiBaseUrl.isNotEmpty)
      ? ref.watch(contentApiProvider)
      : null;
  return CatalogRepository(dbi, remote);
});

final categoriesProvider = StreamProvider<List<models.Category>>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.watchCategories();
});
