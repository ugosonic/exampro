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
    });
  }
  return out;
}

List<Map<String, dynamic>> parseJsonQuestions(dynamic json) {
  if (json is List) {
    return json.cast<Map<String, dynamic>>();
  }
  return [];
}

