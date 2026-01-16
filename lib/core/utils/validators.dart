class Validators {
  static bool isEmail(String input) => RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(input);
  static String? required(String? v, {String field = 'Field'}) => (v == null || v.trim().isEmpty) ? '$field is required' : null;
}

