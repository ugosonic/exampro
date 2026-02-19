import 'package:citizentest/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('Onboarding golden', (tester) async {
    await loadAppFonts();
    const widget = ProviderScope(
      child: MaterialApp(
        home: TickerMode(
          enabled: false,
          child: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpWidgetBuilder(
      widget,
      surfaceSize: const Size(430, 932),
    );
    await tester.pump();
    await screenMatchesGolden(tester, 'onboarding_initial');
  });
}

