import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citizentest/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Onboarding screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TickerMode(
            enabled: false,
            child: OnboardingScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
