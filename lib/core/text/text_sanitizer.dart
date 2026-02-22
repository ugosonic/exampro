import 'dart:convert';

final RegExp _suspiciousMojibake = RegExp(r'(\u00c3|\u00c2|\u00e2\u20ac)');

const Map<String, String> _mojibakeReplacements = <String, String>{
  // Common mojibake seen in app content.
  '\u00e2\u20ac\u00a2': ' - ', // â€¢
  '\u00e2\u20ac\u201c': '-', // â€“
  '\u00e2\u20ac\u201d': '-', // â€”
  '\u00e2\u20ac\u02dc': "'", // â€˜
  '\u00e2\u20ac\u2122': "'", // â€™
  '\u00e2\u20ac\u0153': '"', // â€œ
  '\u00e2\u20ac\ufffd': '"', // â€�
  '\u00e2\u20ac\u00a6': '...', // â€¦
  '\u00c2': '', // stray Â
  // Double-encoded variants.
  '\u00c3\u00a2\u00e2\u201a\u00ac\u00c2\u00a2': ' - ',
  '\u00c3\u00a2\u00e2\u201a\u00ac\u201c': '-',
  '\u00c3\u00a2\u00e2\u201a\u00ac\u00e2\u20ac\u009d': '-',
  '\u00c3\u00a2\u00e2\u201a\u00ac\u00cb\u0153': "'",
  '\u00c3\u00a2\u00e2\u201a\u00ac\u00e2\u201e\u00a2': "'",
  '\u00c3\u00a2\u00e2\u201a\u00ac\u00c5\u201c': '"',
  '\u00c3\u00a2\u00e2\u201a\u00ac\ufffd': '"',
  '\u00c3\u00a2\u00e2\u201a\u00ac\u00c2\u00a6': '...',
};

String sanitizeDisplayText(String value) {
  if (value.isEmpty) return value;

  var out = value;
  _mojibakeReplacements.forEach((from, to) {
    out = out.replaceAll(from, to);
  });

  if (_suspiciousMojibake.hasMatch(out)) {
    try {
      final repaired = utf8.decode(latin1.encode(out), allowMalformed: true);
      if (!_suspiciousMojibake.hasMatch(repaired) || repaired != out) {
        out = repaired;
      }
    } catch (_) {
      // Keep original text when repair fails.
    }
  }

  return out.replaceAll('\u00A0', ' ');
}

extension CleanDisplayTextX on String {
  String get cleanDisplayText => sanitizeDisplayText(this);
}
