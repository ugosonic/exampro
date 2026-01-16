<<<<<<< HEAD
import 'package:exampro/app/router.dart';
import 'package:exampro/app/theme/app_theme.dart';
import 'package:exampro/app/theme/theme_controller.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/core/config/feature_flags.dart';
import 'package:exampro/features/auth/application/session_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
=======
﻿import 'package:citizentest/app/router.dart';
import 'package:citizentest/app/theme/app_theme.dart';
import 'package:citizentest/app/theme/theme_controller.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/config/feature_flags.dart';
import 'package:citizentest/core/i18n/locale_controller.dart';
import 'package:citizentest/features/auth/application/session_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

class ExamProApp extends ConsumerWidget {
  const ExamProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envAsync = ref.watch(envLoaderProvider);
    final router = ref.watch(appRouterProvider);
    // Ensure env + feature flags providers are initialized
    final _ = ref.watch(featureFlagsProvider);
    final themeMode = ref.watch(themeModeProvider);
<<<<<<< HEAD
    ref.watch(sessionInitializerProvider);

    return envAsync.when(
      data: (_) {
        return MaterialApp.router(
          title: 'ExamPro',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
=======
    final locale = ref.watch(localeProvider);

    return envAsync.when(
      data: (_) {
        // Initialize session and locale after env is loaded to avoid accessing
        // env-dependent providers before they are ready.
        ref.watch(sessionInitializerProvider);
        ref.watch(localeInitializerProvider);
        final env = ref.read(envLoaderProvider).requireValue;
        if ((env.stripePublishableKey).isNotEmpty) {
          Stripe.publishableKey = env.stripePublishableKey;
        }
        return MaterialApp.router(
          title: 'Citizen Test',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: locale,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
<<<<<<< HEAD
          supportedLocales: const [Locale('en')],
=======
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
            Locale('pt'),
            Locale('tr'),
            Locale('ar'),
          ],
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(boldText: MediaQuery.of(context).boldText),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      error: (e, st) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load config: $e')),
        ),
<<<<<<< HEAD
=======
        debugShowCheckedModeBanner: false,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
<<<<<<< HEAD
=======
        debugShowCheckedModeBanner: false,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      ),
    );
  }
}
