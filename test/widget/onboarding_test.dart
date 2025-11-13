import 'package:citizentest/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding shows slides and buttons', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ExamProApp()));
    await tester.pumpAndSettle();

    expect(find.text('Learn'), findsOneWidget);
    expect(find.text("I'm a Learner"), findsOneWidget);
    expect(find.text("I'm an Admin"), findsOneWidget);
  });
}

