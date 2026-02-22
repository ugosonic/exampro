import 'dart:convert';

class NotificationPayload {
  final String type;
  final int? examId;
  final int? attemptId;
  final int? categoryId;
  final String? mode;

  const NotificationPayload({
    required this.type,
    this.examId,
    this.attemptId,
    this.categoryId,
    this.mode,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (examId != null) 'examId': examId,
        if (attemptId != null) 'attemptId': attemptId,
        if (categoryId != null) 'categoryId': categoryId,
        if (mode != null && mode!.isNotEmpty) 'mode': mode,
      };

  String toEncoded() => jsonEncode(toJson());

  static NotificationPayload? fromEncoded(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload);
      if (map is! Map) return null;
      return fromMap(map.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  static NotificationPayload? fromMap(Map<String, dynamic> map) {
    final type = (map['type'] as String?)?.trim();
    if (type == null || type.isEmpty) return null;
    int? parseInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');
    String? parseString(dynamic v) {
      final s = v?.toString().trim();
      if (s == null || s.isEmpty) return null;
      return s;
    }
    return NotificationPayload(
      type: type,
      examId: parseInt(map['examId'] ?? map['exam_id']),
      attemptId: parseInt(map['attemptId'] ?? map['attempt_id']),
      categoryId: parseInt(map['categoryId'] ?? map['category_id']),
      mode: parseString(map['mode']),
    );
  }
}
