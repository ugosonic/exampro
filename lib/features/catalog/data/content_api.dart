import 'package:dio/dio.dart';
import 'package:exampro/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentApi {
  final Dio _dio;
  ContentApi(this._dio);

  Future<List<Map<String, dynamic>>> categories() async {
    try {
      final res = await _dio.get('/catalog/categories');
      return (res.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        return ((snap.data['categories'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => (m as Map).cast<String, dynamic>())
            .toList();
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> subcategories({int? categoryId}) async {
    try {
      final res = await _dio.get('/catalog/subcategories', queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
      });
      return (res.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        final list = ((snap.data['subcategories'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => (m as Map).cast<String, dynamic>())
            .toList();
        if (categoryId != null) {
          return [for (final m in list) if ((m['category_id'] as num).toInt() == categoryId) m];
        }
        return list;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> exams({int? categoryId, int? subcategoryId}) async {
    try {
      final res = await _dio.get('/catalog/exams', queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (subcategoryId != null) 'subcategory_id': subcategoryId,
      });
      return (res.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        final list = ((snap.data['exams'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => (m as Map).cast<String, dynamic>())
            .toList();
        return [
          for (final m in list)
            if ((categoryId == null || (m['category_id'] as num).toInt() == categoryId) &&
                (subcategoryId == null || (m['subcategory_id'] as num?)?.toInt() == subcategoryId))
              m
        ];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> examQuestions(int examId) async {
    try {
      final res = await _dio.get('/catalog/exam/$examId/questions');
      return (res.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        final joins = ((snap.data['exam_questions'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => (m as Map).cast<String, dynamic>())
            .where((m) => (m['exam_id'] as num).toInt() == examId)
            .toList()
          ..sort((a,b)=>((a['order'] as num?)?.toInt()??0).compareTo((b['order'] as num?)?.toInt()??0));
        final qids = joins.map((j) => (j['question_id'] as num).toInt()).toSet();
        final qs = ((snap.data['questions'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => (m as Map).cast<String, dynamic>())
            .where((m) => qids.contains((m['id'] as num).toInt()))
            .toList();
        final cs = ((snap.data['choices'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => (m as Map).cast<String, dynamic>())
            .where((m) => qids.contains((m['question_id'] as num).toInt()))
            .toList();
        return {'order': joins, 'questions': qs, 'choices': cs};
      }
      rethrow;
    }
  }
}

final contentApiProvider = Provider<ContentApi>((ref) => ContentApi(ref.watch(dioProvider)));
