import 'package:exampro/core/db/app_database.dart' as db;
import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/catalog/domain/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogRepository {
  final db.AppDatabase _db;
  CatalogRepository(this._db);

  Future<List<models.Category>> categories() async {
    final rows = await (_db.select(_db.categories)
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.order),
            (t) => drift.OrderingTerm.asc(t.name),
          ]))
        .get();
    return rows
        .map((r) => models.Category(
              id: r.id,
              name: r.name,
              order: r.order,
              imageUrl: r.imageUrl,
              locked: r.locked,
            ))
        .toList();
  }

  Future<List<models.ExamSummary>> exams({int? categoryId}) async {
    final query = (categoryId == null)
        ? _db.select(_db.exams)
        : (_db.select(_db.exams)..where((tbl) => tbl.categoryId.equals(categoryId)));
    query.where((e) => e.published.equals(true));
    final rows = await query.get();
    return rows
        .map((r) => models.ExamSummary(
              id: r.id,
              title: r.title,
              categoryId: r.categoryId,
              subcategoryId: r.subcategoryId,
              questionCount: r.questionCount,
              published: r.published,
              themeKey: r.themeKey,
            ))
        .toList();
  }

  Stream<List<models.Category>> watchCategories() {
    return (_db.select(_db.categories)
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.order),
            (t) => drift.OrderingTerm.asc(t.name),
          ]))
        .watch()
        .map((rows) => rows
            .map((r) => models.Category(
                  id: r.id,
                  name: r.name,
                  order: r.order,
                  imageUrl: r.imageUrl,
                  locked: r.locked,
                ))
            .toList());
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
