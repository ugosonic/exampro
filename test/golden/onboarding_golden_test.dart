<<<<<<< HEAD
import 'package:exampro/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
=======
import 'package:citizentest/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('Onboarding golden', (tester) async {
    await loadAppFonts();
    final widget = const ProviderScope(child: ExamProApp());
    await tester.pumpWidgetBuilder(widget);
    await screenMatchesGolden(tester, 'onboarding_initial');
  });
}

