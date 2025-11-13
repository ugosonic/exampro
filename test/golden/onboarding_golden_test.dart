import 'package:citizentest/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('Onboarding golden', (tester) async {
    await loadAppFonts();
    final widget = const ProviderScope(child: ExamProApp());
    await tester.pumpWidgetBuilder(widget);
    await screenMatchesGolden(tester, 'onboarding_initial');
  });
}

