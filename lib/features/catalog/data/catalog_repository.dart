import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/catalog/data/catalog_api.dart';
import 'package:exampro/features/catalog/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogRepository {
  final CatalogApi _api;
  final AppDatabase _db;
  CatalogRepository(this._api, this._db);

  Future<List<Category>> categories() async {
    try {
      final res = await _api.categories();
      // cache
      await _db.transaction(() async {
        for (final c in res) {
          await _db.into(_db.categories).insertOnConflictUpdate(
                CategoriesCompanion(
                  id: drift.Value(c.id),
                  name: drift.Value(c.name),
                  order: drift.Value(c.order),
                ),
              );
        }
      });
      return res;
    } catch (_) {
      final rows = await _db.select(_db.categories).get();
      return rows.map((r) => Category(id: r.id, name: r.name, order: r.order)).toList();
    }
  }

  Future<List<ExamSummary>> exams({int? categoryId}) async {
    try {
      final res = await _api.exams(categoryId: categoryId);
      // cache
      await _db.transaction(() async {
        for (final e in res) {
          await _db.into(_db.exams).insertOnConflictUpdate(
                ExamsCompanion(
                  id: drift.Value(e.id),
                  title: drift.Value(e.title),
                  categoryId: drift.Value(e.categoryId),
                  questionCount: drift.Value(e.questionCount),
                  published: drift.Value(e.published),
                ),
              );
        }
      });
      return res;
    } catch (_) {
      final query = (categoryId == null)
          ? _db.select(_db.exams)
          : (_db.select(_db.exams)..where((tbl) => tbl.categoryId.equals(categoryId)));
      final rows = await query.get();
      return rows
          .map((r) => ExamSummary(
                id: r.id,
                title: r.title,
                categoryId: r.categoryId,
                questionCount: r.questionCount,
                published: r.published,
              ))
          .toList();
    }
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final api = ref.watch(catalogApiProvider);
  final db = ref.watch(dbProvider);
  return CatalogRepository(api, db);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.categories();
});
