import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;
  const AppShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.role == 'admin';
    final items = <_NavItem>[
      if (user == null) ...[
        const _NavItem('Home', '/onboarding', Icons.home_outlined),
        const _NavItem('Explore', '/categories', Icons.category_outlined),
        const _NavItem('Sign In', '/auth', Icons.person_outline),
      ] else ...[
        const _NavItem('Home', '/dashboard', Icons.home_outlined),
        const _NavItem('Explore', '/categories', Icons.category_outlined),
        if (isAdmin) const _NavItem('Admin', '/admin', Icons.admin_panel_settings_outlined),
        const _NavItem('Profile', '/profile', Icons.person_outline),
      ],
    ];

    final location = state.matchedLocation;
    int currentIndex = items.indexWhere((i) => location == i.path || location.startsWith(i.path + '/'));
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: [
          for (final i in items)
            NavigationDestination(icon: Icon(i.icon), label: i.label),
        ],
        onDestinationSelected: (i) => context.go(items[i].path),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String path;
  final IconData icon;
  const _NavItem(this.label, this.path, this.icon);
}
