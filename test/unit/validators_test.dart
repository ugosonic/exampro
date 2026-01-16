<<<<<<< HEAD
import 'package:exampro/core/utils/validators.dart';
=======
import 'package:citizentest/core/utils/validators.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email validator', () {
    expect(Validators.isEmail('test@example.com'), true);
    expect(Validators.isEmail('invalid'), false);
  });
}

