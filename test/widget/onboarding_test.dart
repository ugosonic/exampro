import 'package:citizentest/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding shows primary CTAs', (tester) async {
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

    expect(find.text('Discover the best'), findsOneWidget);
    expect(find.text('practice tests'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('CREATE AN ACCOUNT'), findsOneWidget);
  });
}

