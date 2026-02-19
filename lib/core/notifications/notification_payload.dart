import 'dart:convert';

class NotificationPayload {
  final String type;
  final int? examId;
  final int? attemptId;

  const NotificationPayload({
    required this.type,
    this.examId,
    this.attemptId,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (examId != null) 'examId': examId,
        if (attemptId != null) 'attemptId': attemptId,
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
    return NotificationPayload(
      type: type,
      examId: parseInt(map['examId']),
      attemptId: parseInt(map['attemptId']),
    );
  }
}
