import 'package:csv/csv.dart';

List<Map<String, dynamic>> parseCsvQuestions(String csv) {
  // Robust CSV parsing using package:csv with quoted fields support.
  // Expected header (comma-separated):
  // body, option1, option2, ... optionN, answers, explanation, multiple(optional)
  // - answers: 1-based indices separated by '|', e.g. "2|3"

  final converter = const CsvToListConverter(eol: '\n', shouldParseNumbers: false);
  // Normalize newlines to \n to satisfy converter eol behavior
  final normalized = csv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = converter.convert(normalized);
  if (rows.isEmpty) return [];

  // If first row looks like header (contains 'body'), skip it
  int start = 0;
  if (rows.first.isNotEmpty && rows.first.first.toString().toLowerCase().contains('body')) {
    start = 1;
  }

  final out = <Map<String, dynamic>>[];
  for (var i = start; i < rows.length; i++) {
    final row = rows[i].map((e) => (e ?? '').toString()).toList();
    if (row.where((c) => c.trim().isNotEmpty).isEmpty) continue;
    if (row.length < 6) continue; // require minimum columns

    // Tail: answers, explanation, [multiple]
    final hasMultiple = row.length >= 7;
    final answersCell = row[row.length - (hasMultiple ? 3 : 2)];
    final explanation = row[row.length - (hasMultiple ? 2 : 1)];
    final multiple = hasMultiple
        ? (row.last.trim().toLowerCase() == 'true')
        : null; // infer later if not provided

    final body = row.first.trim();
    final options = row.sublist(1, row.length - (hasMultiple ? 3 : 2)).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final answers = answersCell
        .split('|')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .where((v) => v > 0)
        .toList();
    final isMultiple = multiple ?? (answers.length > 1);

    out.add({
      'body': body,
      'options': options,
      'answers': answers,
      'explanation': explanation,
      'multiple': isMultiple,
    });
  }
  return out;
}

List<Map<String, dynamic>> parseJsonQuestions(dynamic json) {
  if (json is List) {
    // Normalize legacy keys: allow 'text' in place of 'body'
    return json
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) {
          if (m.containsKey('text') && !m.containsKey('body')) m['body'] = m['text'];
          m['multiple'] = m['multiple'] ?? ((m['answers'] is List && (m['answers'] as List).length > 1));
          return m;
        })
        .toList();
  }
  return [];
}
