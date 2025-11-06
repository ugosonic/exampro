import 'dart:async';

import 'package:exampro/app/router_notifier.dart';
import 'package:exampro/app/app_shell.dart';
import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/admin/presentation/admin_console_screen.dart';
import 'package:exampro/features/auth/presentation/sign_in_screen.dart';
import 'package:exampro/features/catalog/presentation/categories_screen.dart';
import 'package:exampro/features/catalog/presentation/exams_by_category_screen.dart';
import 'package:exampro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:exampro/features/exam/presentation/exam_detail_screen.dart';
import 'package:exampro/features/exam/presentation/exam_player_screen.dart';
import 'package:exampro/features/exam/presentation/exam_result_screen.dart';
import 'package:exampro/features/exam/presentation/saved_questions_screen.dart';
import 'package:exampro/features/exam/presentation/attempts_list_screen.dart';
import 'package:exampro/features/exam/presentation/attempt_review_screen.dart';
import 'package:exampro/features/payments/presentation/upgrade_screen.dart';
import 'package:exampro/features/onboarding/presentation/onboarding_screen.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/features/profile/presentation/profile_screen.dart';
import 'package:exampro/features/auth/presentation/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _RouteSaver extends NavigatorObserver {
  final Ref ref;
  _RouteSaver(this.ref);
  Future<void> _save(NavigatorState? nav) async {
    if (nav == null) return;
    try {
      final loc = GoRouter.of(nav.context).routeInformationProvider.value.uri.toString();
      final db = ref.read(dbProvider);
      await db
          .into(db.appSettings)
          .insertOnConflictUpdate(AppSettingsCompanion(key: const drift.Value('last_route'), value: drift.Value(loc)));
    } catch (_) {}
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _save(navigator);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _save(navigator);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _save(navigator);
    super.didPop(route, previousRoute);
  }
}
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: notifier,
    observers: [_RouteSaver(ref)],
    redirect: (context, state) => _redirect(ref, tokenStore, state),
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/onboarding',
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/onboarding',
            pageBuilder: (context, state) => _fade(state, const OnboardingScreen()),
          ),
          GoRoute(
            path: '/auth',
            pageBuilder: (context, state) => _softSlide(state, const SignInScreen()),
          ),
          GoRoute(
            path: '/register',
            pageBuilder: (context, state) => _softSlide(state, const SignUpScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _fade(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) => _softSlide(state, const CategoriesScreen()),
          ),
          GoRoute(
            path: '/categories/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '0';
              return _softSlide(state, ExamsByCategoryScreen(categoryId: id));
            },
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _softSlide(state, const ProfileScreen()),
          ),
          GoRoute(
            path: '/exam/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '0';
              return _softSlide(state, ExamDetailScreen(examId: id));
            },
          ),
          GoRoute(
            path: '/player/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '0';
              final aid = int.tryParse(state.uri.queryParameters['aid'] ?? '');
              final mode = state.uri.queryParameters['mode'];
              final cat = int.tryParse(state.uri.queryParameters['cat'] ?? '');
              return _softSlide(state, ExamPlayerScreen(examId: id, attemptId: aid, mode: mode, categoryId: cat));
            },
          ),
          GoRoute(
            path: '/result/:attemptId',
            pageBuilder: (context, state) {
              final id = state.pathParameters['attemptId'] ?? '0';
              return _softSlide(state, ExamResultScreen(attemptId: id));
            },
          ),
          GoRoute(
            path: '/saved',
            pageBuilder: (context, state) => _softSlide(state, const SavedQuestionsScreen()),
          ),
          GoRoute(
            path: '/attempts',
            pageBuilder: (context, state) => _softSlide(state, const AttemptsListScreen()),
          ),
          GoRoute(
            path: '/review/:attemptId',
            pageBuilder: (context, state) {
              final id = state.pathParameters['attemptId'] ?? '0';
              return _softSlide(state, AttemptReviewScreen(attemptId: id));
            },
          ),
          GoRoute(
            path: '/upgrade',
            pageBuilder: (context, state) => _softSlide(state, const UpgradeScreen()),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) => _fade(state, const AdminConsoleScreen()),
          ),
        ],
      ),
    ],
  );
});

FutureOr<String?> _redirect(Ref ref, TokenStore tokens, GoRouterState state) async {
  final user = ref.read(currentUserProvider);
  final hasTokens = await tokens.hasTokens();
  final signedIn = hasTokens && user != null;
  final loc = state.matchedLocation;
  final loggingIn = loc == '/auth';
  final registering = loc == '/register';
  final onboarding = loc == '/onboarding';
  final exploring = loc == '/categories' || loc.startsWith('/categories/');
  final goingAdmin = loc.startsWith('/admin');

  // Not signed in: allow auth/onboarding/explore; otherwise push to /auth
  if (!signedIn) {
    if (loggingIn || registering || onboarding || exploring) return null;
    return '/auth';
  }
  // Has tokens
  if (loggingIn || registering || onboarding) {
    if (user?.role == 'admin') return '/admin';
    return '/dashboard';
  }
  if (goingAdmin && (user == null || user.role != 'admin')) return '/dashboard';
  // Restore last route when available and appropriate
  try {
    final db = ref.read(dbProvider);
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals('last_route'))).getSingleOrNull();
    final saved = row?.value ?? '';
    if (saved.isNotEmpty && saved != loc) {
      final canShow = !loggingIn && !registering && !onboarding; // allow dashboard/categories/player/etc.
      if (canShow) {
        return saved;
      }
    }
  } catch (_) {}
  return null;
}

CustomTransitionPage _fade(GoRouterState state, Widget child) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut), child: child),
    );

CustomTransitionPage _softSlide(GoRouterState state, Widget child) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return SlideTransition(
          position: Tween(begin: const Offset(0.04, 0.0), end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );

