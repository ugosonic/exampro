import 'package:exampro/app/router.dart';
import 'package:exampro/app/theme/app_theme.dart';
import 'package:exampro/app/theme/theme_controller.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/core/config/feature_flags.dart';
import 'package:exampro/features/auth/application/session_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamProApp extends ConsumerWidget {
  const ExamProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envAsync = ref.watch(envLoaderProvider);
    final router = ref.watch(appRouterProvider);
    // Ensure env + feature flags providers are initialized
    final _ = ref.watch(featureFlagsProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(sessionInitializerProvider);

    return envAsync.when(
      data: (_) {
        return MaterialApp.router(
          title: 'ExamPro',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
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
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
