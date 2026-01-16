<<<<<<< HEAD
import 'package:exampro/app/app.dart';
import 'package:flutter/material.dart';
=======
import 'package:citizentest/app/app.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
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

