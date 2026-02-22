import 'package:dio/dio.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminApi {
  final Dio _dio;
  AdminApi(this._dio);

  Future<int> createCategory({
    required String name,
    int order = 0,
    int passPercent = 60,
    String imageUrl = '',
  }) async {
    final res = await _dio.post(
      '/admin/categories',
      data: {
        'name': name,
        'order': order,
        'pass_percent': passPercent,
        'image_url': imageUrl,
      },
    );
    return (res.data['id'] as num).toInt();
  }

  Future<void> updateCategory(
    int id, {
    String? name,
    int? order,
    int? passPercent,
    String? imageUrl,
    bool? locked,
  }) async {
    await _dio.put(
      '/admin/categories/$id',
      data: {
        if (name != null) 'name': name,
        if (order != null) 'order': order,
        if (passPercent != null) 'pass_percent': passPercent,
        if (imageUrl != null) 'image_url': imageUrl,
        if (locked != null) 'locked': locked,
      },
    );
  }

  Future<void> deleteCategory(int id) async =>
      _dio.delete('/admin/categories/$id');

  Future<int> createSubcategory({
    required int categoryId,
    required String name,
    int order = 0,
    String imageUrl = '',
  }) async {
    final res = await _dio.post(
      '/admin/subcategories',
      data: {
        'category_id': categoryId,
        'name': name,
        'order': order,
        'image_url': imageUrl,
      },
    );
    return (res.data['id'] as num).toInt();
  }

  Future<void> updateSubcategory(
    int id, {
    String? name,
    int? order,
    String? imageUrl,
    bool? locked,
  }) async {
    await _dio.put(
      '/admin/subcategories/$id',
      data: {
        if (name != null) 'name': name,
        if (order != null) 'order': order,
        if (imageUrl != null) 'image_url': imageUrl,
        if (locked != null) 'locked': locked,
      },
    );
  }

  Future<void> deleteSubcategory(int id) async =>
      _dio.delete('/admin/subcategories/$id');

  Future<int> createExam({
    required String title,
    String description = '',
    required int categoryId,
    int? subcategoryId,
    int timeLimitMinutes = 0,
    int passPercent = 60,
    bool shuffleOptions = true,
    bool negativeMarking = false,
    bool published = false,
    int themeKey = 0,
    String pdfUrl = '',
  }) async {
    final res = await _dio.post(
      '/admin/exams',
      data: {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'subcategory_id': subcategoryId,
        'time_limit_minutes': timeLimitMinutes,
        'pass_percent': passPercent,
        'shuffle_options': shuffleOptions,
        'negative_marking': negativeMarking,
        'published': published,
        'theme_key': themeKey,
        'pdf_url': pdfUrl,
      },
    );
    return (res.data['id'] as num).toInt();
  }

  Future<void> updateExam(
    int id, {
    String? title,
    String? description,
    int? categoryId,
    int? subcategoryId,
    int? timeLimitMinutes,
    int? passPercent,
    bool? shuffleOptions,
    bool? negativeMarking,
    bool? published,
    int? themeKey,
    String? pdfUrl,
  }) async {
    await _dio.put(
      '/admin/exams/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (categoryId != null) 'category_id': categoryId,
        if (subcategoryId != null) 'subcategory_id': subcategoryId,
        if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
        if (passPercent != null) 'pass_percent': passPercent,
        if (shuffleOptions != null) 'shuffle_options': shuffleOptions,
        if (negativeMarking != null) 'negative_marking': negativeMarking,
        if (published != null) 'published': published,
        if (themeKey != null) 'theme_key': themeKey,
        if (pdfUrl != null) 'pdf_url': pdfUrl,
      },
    );
  }

  Future<void> deleteExam(int id) async => _dio.delete('/admin/exams/$id');

  Future<int> addQuestionWithOptions({
    required int examId,
    required String text,
    String explanation = '',
    required List<({String text, bool correct})> options,
    bool multiple = false,
    int points = 1,
    int order = 0,
  }) async {
    final res = await _dio.post(
      '/admin/exams/$examId/questions',
      data: {
        'text': text,
        'explanation': explanation,
        'options': [
          for (final o in options) {'text': o.text, 'correct': o.correct},
        ],
        'multiple': multiple,
        'points': points,
        'order': order,
      },
    );
    return (res.data['id'] as num).toInt();
  }

  Future<void> updateQuestionAndOptions({
    required int questionId,
    required String body,
    String explanation = '',
    bool multiple = false,
    required List<({String text, bool correct})> options,
  }) async {
    await _dio.put(
      '/admin/questions/$questionId',
      data: {
        'body': body,
        'explanation': explanation,
        'multiple': multiple,
        'options': [
          for (final o in options) {'text': o.text, 'correct': o.correct},
        ],
      },
    );
  }

  Future<void> deleteQuestionFromExam({
    required int examId,
    required int questionId,
  }) async {
    await _dio.delete('/admin/exams/$examId/questions/$questionId');
  }

  // Users
  Future<List<Map<String, dynamic>>> users() async {
    final res = await _dio.get('/admin/users');
    final list = (res.data as List? ?? const [])
        .cast<Map>()
        .map((m) => (m).cast<String, dynamic>())
        .toList();
    return list;
  }
}

final adminApiProvider = Provider<AdminApi>(
  (ref) => AdminApi(ref.watch(dioProvider)),
);
