import 'package:dio/dio.dart';
import 'package:exampro/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentApi {
  final Dio _dio;
  ContentApi(this._dio);

  // ----------------- coercion helpers -----------------
  Map<String, dynamic> _asMap(dynamic v) {
    if (v == null) return <String, dynamic>{};
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    throw StateError('Expected Map, got ${v.runtimeType}');
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic v) {
    if (v == null) return const <Map<String, dynamic>>[];
    if (v is List) {
      return v.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        throw StateError('Expected element Map, got ${e.runtimeType}');
      }).toList();
    }
    throw StateError('Expected List, got ${v.runtimeType}');
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> categories() async {
    try {
      final res = await _dio.get('/catalog/categories');
      return _asListOfMap(res.data);
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        return _asListOfMap(_asMap(snap.data)['categories']);
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> subcategories({int? categoryId}) async {
    try {
      final res = await _dio.get(
        '/catalog/subcategories',
        queryParameters: { if (categoryId != null) 'category_id': categoryId },
      );
      final list = _asListOfMap(res.data);
      if (categoryId == null) return list;
      return [ for (final m in list) if (_asInt(m['category_id']) == categoryId) m ];
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        final list = _asListOfMap(_asMap(snap.data)['subcategories']);
        if (categoryId == null) return list;
        return [ for (final m in list) if (_asInt(m['category_id']) == categoryId) m ];
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> exams({int? categoryId, int? subcategoryId}) async {
    try {
      final res = await _dio.get(
        '/catalog/exams',
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (subcategoryId != null) 'subcategory_id': subcategoryId,
        },
      );
      final list = _asListOfMap(res.data);
      // keep local filtering defensive
      return [
        for (final m in list)
          if ((categoryId == null || _asInt(m['category_id']) == categoryId) &&
              (subcategoryId == null || _asInt(m['subcategory_id']) == subcategoryId))
            m
      ];
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        final list = _asListOfMap(_asMap(snap.data)['exams']);
        return [
          for (final m in list)
            if ((categoryId == null || _asInt(m['category_id']) == categoryId) &&
                (subcategoryId == null || _asInt(m['subcategory_id']) == subcategoryId))
              m
        ];
      }
      rethrow;
    }
  }

  /// Normal (single) exam questions
  /// Returns a Map with keys: order, questions, choices
  Future<Map<String, dynamic>> examQuestions(int examId) async {
    try {
      final res = await _dio.get('/catalog/exam/$examId/questions');
      return _asMap(res.data);
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        return _snapshotExamBundle(_asMap(snap.data), examId: examId);
      }
      rethrow;
    }
  }

  /// PRACTICE ALL QUESTIONS in a category (what your UI calls with examId=0).
  /// Prefer calling this method instead of faking examId==0.
  Future<Map<String, dynamic>> categoryQuestions(int categoryId) async {
    try {
      final res = await _dio.get(
        '/catalog/category/$categoryId/questions',
      );
      // backend might return the same bundle shape
      return _asMap(res.data);
    } on DioException catch (e) {
      // fall back to snapshot and *aggregate* by category
      if ((e.response?.statusCode ?? 0) == 404) {
        final snap = await _dio.get('/sync/snapshot');
        return _snapshotCategoryBundle(_asMap(snap.data), categoryId: categoryId);
      }
      rethrow;
    }
  }

  // ---------- snapshot helpers ----------
  Map<String, dynamic> _snapshotExamBundle(Map<String, dynamic> snap, {required int examId}) {
    final joins = _asListOfMap(snap['exam_questions'])
      ..retainWhere((m) => _asInt(m['exam_id']) == examId)
      ..sort((a, b) => (_asInt(a['order']) ?? 0).compareTo(_asInt(b['order']) ?? 0));

    final qids = {
      for (final j in joins) _asInt(j['question_id'])
    }..remove(null);

    final questions = _asListOfMap(snap['questions'])
        .where((m) => qids.contains(_asInt(m['id'])))
        .toList();

    final choices = _asListOfMap(snap['choices'])
        .where((m) => qids.contains(_asInt(m['question_id'])))
        .toList();

    return {
      'order': joins,
      'questions': questions,
      'choices': choices,
    };
  }

  Map<String, dynamic> _snapshotCategoryBundle(Map<String, dynamic> snap, {required int categoryId}) {
    final examsInCategory = _asListOfMap(snap['exams'])
        .where((e) => _asInt(e['category_id']) == categoryId)
        .map((e) => _asInt(e['id']))
        .whereType<int>()
        .toSet();

    final joins = _asListOfMap(snap['exam_questions'])
        .where((j) => examsInCategory.contains(_asInt(j['exam_id'])))
        .toList()
      ..sort((a, b) => (_asInt(a['order']) ?? 0).compareTo(_asInt(b['order']) ?? 0));

    final qids = {
      for (final j in joins) _asInt(j['question_id'])
    }..remove(null);

    final questions = _asListOfMap(snap['questions'])
        .where((m) => qids.contains(_asInt(m['id'])))
        .toList();

    final choices = _asListOfMap(snap['choices'])
        .where((m) => qids.contains(_asInt(m['question_id'])))
        .toList();

    return {
      'order': joins,
      'questions': questions,
      'choices': choices,
    };
  }
}

final contentApiProvider = Provider<ContentApi>(
  (ref) => ContentApi(ref.watch(dioProvider)),
);
