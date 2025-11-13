import 'package:citizentest/core/i18n/tr_text.dart';
import 'package:citizentest/common/widgets/tap_scale.dart';
import 'package:citizentest/features/catalog/data/catalog_repository.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:citizentest/common/widgets/neon_glass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/core/config/env_loader.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesProvider);
    final db = ref.watch(dbProvider);
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const TrText('Categories'),
      ),
      body: NeonBackground(
        child: SafeArea(
          child: catsAsync.when(
        data: (cats) => RefreshIndicator(
          onRefresh: () async => ref.refresh(categoriesProvider.future),
          child: FutureBuilder<bool>(
            future: () async {
              if (user == null) return false;
              final row = await (db.select(db.users)..where((u) => u.email.equals(user.email))).getSingleOrNull();
              return row?.isPro ?? false;
            }(),
            builder: (context, isProSnap) {
              final isPro = isProSnap.data ?? false;
              return NeonGlassCard(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
                  itemCount: cats.length,
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    final icon = [Icons.biotech, Icons.science, Icons.bubble_chart, Icons.functions][i % 4];
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return TapScale(
                      onTap: () {
                        if (c.locked && !isPro) {
                          context.go('/upgrade');
                        } else {
                          context.go('/categories/${c.id}');
                        }
                      },
                      child: NeonGlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(0),
                        child: Card(
                          elevation: 0,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Stack(children: [
                            if (c.locked && !isPro)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.lock, size: 16, color: Colors.white),
                                ),
                              ),
                            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            if (c.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _CategoryImage(src: c.imageUrl),
                              )
                            else
                              CircleAvatar(radius: 22, child: Icon(icon, size: 24)),
                            const SizedBox(height: 10),
                            Text(
                              c.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ])),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      ),
        ),
      ),
    );
  }
}

class _CategoryImage extends ConsumerWidget {
  final String src;
  const _CategoryImage({required this.src});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const w = 90.0, h = 60.0;
    final resolved = src.trim();
    if (resolved.isEmpty) return _fallback(w, h);
    Widget network(String url) => Image.network(url, width: w, height: h, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(w, h));
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return network(resolved);
    }
    if (resolved.startsWith('assets/')) {
      return Image.asset(resolved, width: w, height: h, fit: BoxFit.cover);
    }
    final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
    if (resolved.startsWith('/')) {
      final base = env?.apiBaseUrl ?? '';
      if (base.isNotEmpty) {
        final url = '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}$resolved';
        return network(url);
      }
      return _fallback(w, h);
    }
    final uri = Uri.tryParse(resolved);
    if (uri != null && uri.scheme == 'file') {
      final file = File.fromUri(uri);
      if (file.existsSync()) {
        return Image.file(file, width: w, height: h, fit: BoxFit.cover);
      }
    }
    final file = File(resolved);
    if (file.existsSync()) {
      return Image.file(file, width: w, height: h, fit: BoxFit.cover);
    }
    final base = env?.apiBaseUrl ?? '';
    if (base.isNotEmpty) {
      final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final path = resolved.startsWith('/') ? resolved.substring(1) : resolved;
      final url = '$normalizedBase/$path';
      return network(url);
    }
    return _fallback(w, h);
  }

  Widget _fallback(double w, double h) => Container(width: w, height: h, color: Colors.white.withValues(alpha: 0.06), child: const Icon(Icons.image_not_supported, color: Colors.white70));
}



