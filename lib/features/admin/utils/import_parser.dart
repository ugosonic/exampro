<<<<<<< HEAD
List<Map<String, dynamic>> parseCsvQuestions(String csv) {
  // Expect header: text,option1,option2,option3,option4,answers,explanation
  final lines = csv.split(RegExp(r"\r?\n")).where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return [];
  final out = <Map<String, dynamic>>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split(',');
    if (parts.length < 6) continue;
    final options = parts.sublist(1, parts.length - 2);
    final answers = parts[parts.length - 2].split('|').where((e) => e.isNotEmpty).map(int.parse).toList();
    out.add({
      'text': parts[0],
      'options': options,
      'answers': answers,
      'explanation': parts.last,
=======
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
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    });
  }
  return out;
}

List<Map<String, dynamic>> parseJsonQuestions(dynamic json) {
  if (json is List) {
<<<<<<< HEAD
    return json.cast<Map<String, dynamic>>();
  }
  return [];
}

=======
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
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
