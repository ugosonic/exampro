import 'package:citizentest/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email validator', () {
    expect(Validators.isEmail('test@example.com'), true);
    expect(Validators.isEmail('invalid'), false);
  });
}

