import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/core/network/network_status.dart';
import 'package:exampro/core/config/remote_config.dart';
import 'package:exampro/core/db/db_provider.dart';
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

    final offlineBar = ref.watch(onlineStatusProvider).maybeWhen(
      data: (on) => on ? const SizedBox.shrink() : Container(
        width: double.infinity,
        color: Colors.orange.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const SafeArea(top: true, bottom: false, child: Text('No internet connection. Please reconnect.', style: TextStyle(color: Colors.white))),
      ),
      orElse: () => const SizedBox.shrink(),
    );

    final upgradeBar = Builder(builder: (context) {
      final cfg = ref.watch(remoteConfigProvider).maybeWhen(data: (c) => c, orElse: () => const RemoteConfig(upgradeDisabled: false));
      final u = ref.watch(currentUserProvider);
      if (cfg.upgradeDisabled) return const SizedBox.shrink();
      if (u == null) return const SizedBox.shrink();
      final db = ref.watch(dbProvider);
      return FutureBuilder(
        future: (db.select(db.users)..where((r) => r.email.equals(u.email))).getSingleOrNull(),
        builder: (context, snap) {
          final isPro = snap.data?.isPro ?? false;
          if (isPro) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SafeArea(
              top: offlineBar is SizedBox ? true : false,
              bottom: false,
              child: Row(children: [
                const Icon(Icons.workspace_premium, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('Upgrade to Pro to unlock all categories and features.')),
                TextButton(onPressed: () => GoRouter.of(context).go('/upgrade'), child: const Text('Upgrade')),
              ]),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Column(children: [
        offlineBar,
        upgradeBar,
        Expanded(child: child),
      ]),
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
