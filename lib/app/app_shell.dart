import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/core/network/network_status.dart';
import 'package:citizentest/core/config/remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';
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
    int currentIndex = items.indexWhere((i) => location == i.path || location.startsWith('${i.path}/'));
    if (currentIndex == -1) currentIndex = 0;

    final offlineBar = ref.watch(onlineStatusProvider).maybeWhen(
      data: (on) => on ? const SizedBox.shrink() : Container(
        width: double.infinity,
        color: Colors.orange.withValues(alpha: 0.9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const SafeArea(top: true, bottom: false, child: Text('No internet connection. Please reconnect.', style: TextStyle(color: Colors.white))),
      ),
      orElse: () => const SizedBox.shrink(),
    );

    // App update prompt bar
    final updateBar = Builder(builder: (context) {
      final cfg = ref.watch(remoteConfigProvider).maybeWhen(data: (c) => c, orElse: () => null);
      if (cfg == null || (cfg.latestVersion == null && cfg.minVersion == null)) return const SizedBox.shrink();

      bool isLower(String a, String b) {
        List<int> pa(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        final x = pa(a), y = pa(b);
        for (var i = 0; i < (x.length > y.length ? x.length : y.length); i++) {
          final xi = i < x.length ? x[i] : 0;
          final yi = i < y.length ? y[i] : 0;
          if (xi < yi) return true;
          if (xi > yi) return false;
        }
        return false;
      }

          return FutureBuilder<({bool must, bool hasNew, String? storeUrl, String packageName})>(
            future: () async {
              final info = await PackageInfo.fromPlatform();
              final current = info.version;
              final must = cfg.minVersion != null && isLower(current, cfg.minVersion!);
              final hasNew = cfg.latestVersion != null && isLower(current, cfg.latestVersion!);
              String? storeUrl;
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
                storeUrl = cfg.androidStoreUrl ?? 'https://play.google.com/store/apps/details?id=${info.packageName}';
              } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                storeUrl = cfg.iosStoreUrl;
              }
              return (must: must, hasNew: hasNew, storeUrl: storeUrl, packageName: info.packageName);
            }(),
        builder: (context, snap) {
          final data = snap.data;
          if (data == null || (!data.must && !data.hasNew)) return const SizedBox.shrink();
          final scheme = Theme.of(context).colorScheme;
          final bg = data.must ? Colors.red.withValues(alpha: 0.95) : scheme.tertiaryContainer.withValues(alpha: 0.9);
          final fg = data.must ? Colors.white : scheme.onTertiaryContainer;
          Future<void> goStore() async {
            final url = data.storeUrl;
            if (url == null || url.isEmpty) return;
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
          return Container(
            width: double.infinity,
            color: bg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SafeArea(
              top: offlineBar is SizedBox ? true : false,
              bottom: false,
              child: Row(children: [
                Icon(Icons.system_update, size: 18, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.must
                        ? 'A new version is required to continue.'
                        : 'Update available. Tap to get the latest features.',
                    style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: goStore,
                  child: Text('Update', style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          );
        },
      );
    });

    final upgradeBar = Builder(builder: (context) {
      // Hidden as requested: suppress upgrade notification on all screens.
      return const SizedBox.shrink();
    });

    return Scaffold(
      body: Column(children: [
        offlineBar,
        updateBar,
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
