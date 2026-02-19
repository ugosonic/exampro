import 'package:citizentest/app/router.dart';
import 'package:citizentest/app/theme/app_theme.dart';
import 'package:citizentest/app/theme/theme_controller.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/config/feature_flags.dart';
import 'package:citizentest/core/i18n/locale_controller.dart';
import 'package:citizentest/core/notifications/push_notifications.dart';
import 'package:citizentest/features/auth/application/session_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class ExamProApp extends ConsumerWidget {
  const ExamProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envAsync = ref.watch(envLoaderProvider);
    final router = ref.watch(appRouterProvider);
    // Ensure env + feature flags providers are initialized.
    final _ = ref.watch(featureFlagsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return envAsync.when(
      data: (_) {
        // Initialize session and locale after env is loaded to avoid accessing
        // env-dependent providers before they are ready.
        ref.watch(sessionInitializerProvider);
        ref.watch(localeInitializerProvider);
        ref.read(pushNotificationsProvider).init();
        final env = ref.read(envLoaderProvider).requireValue;
        if (env.stripePublishableKey.isNotEmpty) {
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
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
        debugShowCheckedModeBanner: false,
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
