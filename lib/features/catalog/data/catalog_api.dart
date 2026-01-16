import 'package:dio/dio.dart';
import 'package:exampro/core/network/dio_client.dart';
import 'package:exampro/features/catalog/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CatalogApi {
  Future<List<Category>> categories();
  Future<List<ExamSummary>> exams({int? categoryId});
}

class CatalogApiImpl implements CatalogApi {
  final Dio _dio;
  CatalogApiImpl(this._dio);

  @override
  Future<List<Category>> categories() async {
    final res = await _dio.get('/categories');
    final list = res.data as List<dynamic>;
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ExamSummary>> exams({int? categoryId}) async {
    final res = await _dio.get('/exams', queryParameters: {if (categoryId != null) 'categoryId': categoryId});
    final list = res.data as List<dynamic>;
    return list.map((e) => ExamSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class CatalogApiMock implements CatalogApi {
  @override
  Future<List<Category>> categories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      Category(id: 1, name: 'Biology', order: 1),
      Category(id: 2, name: 'Physics', order: 2),
      Category(id: 3, name: 'Chemistry', order: 3),
      Category(id: 4, name: 'Math', order: 4),
    ];
  }

  @override
  Future<List<ExamSummary>> exams({int? categoryId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      ExamSummary(id: 10, title: 'Biology Mock A', categoryId: 1, questionCount: 50, published: true),
      ExamSummary(id: 11, title: 'Physics Practice 1', categoryId: 2, questionCount: 20, published: true),
    ];
  }
}

final catalogApiProvider = Provider<CatalogApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CatalogApiImpl(dio);
  // return CatalogApiMock();
});

