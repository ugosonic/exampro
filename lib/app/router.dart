import 'dart:async';

import 'package:exampro/app/router_notifier.dart';
import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/admin/presentation/admin_console_screen.dart';
import 'package:exampro/features/auth/presentation/delete_account_screen.dart';
import 'package:exampro/features/auth/presentation/sign_in_screen.dart';
import 'package:exampro/features/auth/presentation/sign_up_screen.dart';
import 'package:exampro/features/catalog/presentation/categories_screen.dart';
import 'package:exampro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:exampro/features/exam/presentation/exam_detail_screen.dart';
import 'package:exampro/features/exam/presentation/exam_player_screen.dart';
import 'package:exampro/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: notifier,
    redirect: (context, state) => _redirect(ref, tokenStore, state),
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
        path: '/delete-account',
        pageBuilder: (context, state) => _softSlide(state, const DeleteAccountScreen()),
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
        path: '/exam/:id',
        pageBuilder: (context, state) => _softSlide(state, ExamDetailScreen(examId: state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/player/:id',
        pageBuilder: (context, state) => _softSlide(state, ExamPlayerScreen(examId: state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _fade(state, const AdminConsoleScreen()),
      ),
    ],
  );
});

FutureOr<String?> _redirect(Ref ref, TokenStore tokens, GoRouterState state) async {
  final user = ref.read(currentUserProvider);
  final hasTokens = await tokens.hasTokens();
  final loggingIn = state.matchedLocation == '/auth';
  final onboarding = state.matchedLocation == '/onboarding';
  final registering = state.matchedLocation == '/register';
  final deleting = state.matchedLocation == '/delete-account';
  final goingAdmin = state.matchedLocation.startsWith('/admin');

  if (!hasTokens) {
    if (loggingIn || onboarding || registering || deleting) return null;
    return '/onboarding';
  }
  // Has tokens
  if (loggingIn || onboarding) return '/dashboard';
  if (goingAdmin && (user == null || user.role != 'admin')) return '/dashboard';
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
