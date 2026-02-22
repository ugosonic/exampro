import 'package:citizentest/app/theme/theme_controller.dart';
import 'package:citizentest/common/widgets/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:citizentest/features/exam/data/exam_repository.dart';
import 'package:citizentest/features/catalog/data/catalog_repository.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:citizentest/common/widgets/neon_glass.dart';
import 'package:citizentest/features/sync/data/sync_repository.dart';
import 'package:citizentest/features/dashboard/data/progress_repository.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/review/review_prompt.dart';
import 'package:citizentest/core/text/text_sanitizer.dart';

// Top-level helper widget for category thumbnails (supports file or https URLs)
class _CategoryImage extends ConsumerWidget {
  final String src;
  const _CategoryImage({required this.src});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const w = 90.0, h = 60.0;
    final border = BorderRadius.circular(10);
    final resolved = src.trim();
    if (resolved.isEmpty) return fallback(w, h);
    Widget network(String url) => ClipRRect(
      borderRadius: border,
      child: Image.network(
        url,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(w, h),
      ),
    );
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return network(resolved);
    }
    if (resolved.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: border,
        child: Image.asset(resolved, width: w, height: h, fit: BoxFit.cover),
      );
    }
    final env = ref
        .watch(envLoaderProvider)
        .maybeWhen(data: (e) => e, orElse: () => null);
    if (resolved.startsWith('/')) {
      final base = env?.apiBaseUrl ?? '';
      if (base.isNotEmpty) {
        final url =
            '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}$resolved';
        return network(url);
      }
      return fallback(w, h);
    }
    final uri = Uri.tryParse(resolved);
    if (uri != null && uri.scheme == 'file') {
      final file = File.fromUri(uri);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: border,
          child: Image.file(file, width: w, height: h, fit: BoxFit.cover),
        );
      }
    }
    final file = File(resolved);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: border,
        child: Image.file(file, width: w, height: h, fit: BoxFit.cover),
      );
    }
    final base = env?.apiBaseUrl ?? '';
    if (base.isNotEmpty) {
      final normalizedBase = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;
      final path = resolved.startsWith('/') ? resolved.substring(1) : resolved;
      final url = '$normalizedBase/$path';
      return network(url);
    }
    return fallback(w, h);
  }

  Widget fallback(double w, double h) => Container(
    width: w,
    height: h,
    color: Colors.white.withValues(alpha: 0.06),
    child: const Icon(Icons.image_not_supported, color: Colors.white70),
  );
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // No rebuilds on every scroll tick; use AnimatedBuilder in the widget tree instead
    // Ensure recent attempts sync from server so progress is portable across devices
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await ReviewPrompt.maybeShow(context, ref);
      }
      final u = ref.read(currentUserProvider);
      final email = u?.email;
      if (email != null && email.isNotEmpty) {
        try {
          await ref.read(syncRepositoryProvider).pullUserProgress(email);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    // Manual content update banner removed; content now auto-syncs after sign-in.
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Test'),
        actions: [
          IconButton(
            tooltip: 'Theme',
            onPressed: () {
              final next = mode == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
              ref.read(themeModeProvider.notifier).state = next;
            },
            icon: Icon(
              mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
        ],
      ),
      body: NeonBackground(
        child: SafeArea(
          child: user == null
              ? _signedOutHome(context)
              : Stack(
                  children: [
                    // Header gradient (match onboarding dark gradient)
                    Container(
                      height: 260,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2A2E79), Color(0xFF161A4F)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Scrollable content
                    ListView(
                      controller: _scroll,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Auto-sync enabled: no manual update card
                        // Main white card slides subtly with scroll
                        AnimatedBuilder(
                          animation: _scroll,
                          builder: (context, child) {
                            final off = _scroll.hasClients
                                ? (_scroll.offset / 400).clamp(0.0, 0.25)
                                : 0.0;
                            return AnimatedSlide(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              offset: Offset(0, off),
                              child: NeonGlassCard(
                                child: _greetingAndProgress(context, ref),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        NeonGlassCard(child: _quickActionsGrid(context, ref)),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Center(
                            child: Text(
                              'Select Country',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.95)
                                        : Colors.black.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        NeonGlassCard(child: _homeCategoriesGrid(context)),
                        const SizedBox(height: 20),
                        NeonGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Progress',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withValues(alpha: 0.95)
                                          : Colors.black.withValues(
                                              alpha: 0.85,
                                            ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              _progressChart(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        NeonGlassCard(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent attempts',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.95,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.85,
                                                ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/attempts'),
                                    child: const Text('View all'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _recentAttempts(context, ref),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(child: _zenovFooter(context)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _signedOutHome(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NeonGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.95)
                        : Colors.black.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to sync progress across devices, or explore categories without an account.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => GoRouter.of(context).go('/auth'),
                      child: const Text('Sign in'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => GoRouter.of(context).go('/categories'),
                      child: const Text('Explore'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _homeCategoriesGrid(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final catsAsync = ref.watch(categoriesProvider);
        final db = ref.watch(dbProvider);
        final user = ref.watch(currentUserProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return catsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Failed to load categories: $e'),
          data: (cats) {
            return FutureBuilder<bool>(
              future: () async {
                if (user == null) return false;
                final row = await (db.select(
                  db.users,
                )..where((u) => u.email.equals(user.email))).getSingleOrNull();
                return row?.isPro ?? false;
              }(),
              builder: (context, snap) {
                final isPro = snap.data ?? false;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: cats.length,
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    final icon = [
                      Icons.biotech,
                      Icons.science,
                      Icons.bubble_chart,
                      Icons.functions,
                    ][i % 4];
                    return TapScale(
                      onTap: () {
                        context.go('/categories/${c.id}');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: c.imageUrl.isEmpty
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.12),
                                    Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.10),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                        ),
                        child: Card(
                          elevation: 0,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              if (c.locked && !isPro)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.lock,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (c.imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: _CategoryImage(src: c.imageUrl),
                                      )
                                    else
                                      CircleAvatar(
                                        radius: 22,
                                        child: Icon(icon, size: 24),
                                      ),
                                    const SizedBox(height: 10),
                                    Text(
                                      sanitizeDisplayText(c.name),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _greetingAndProgress(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${user?.email.split('@').first ?? 'User'}!',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Start a new Test',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        _searchBar(context),
        const SizedBox(height: 16),
        _categoryProgressBlock(context, ref),
      ],
    );
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search, color: Colors.black38),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Search a course',
              ),
            ),
          ),
          InkWell(
            onTap: () => GoRouter.of(context).go('/categories'),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryProgressBlock(BuildContext context, WidgetRef ref) {
    final email = (ref.watch(currentUserProvider)?.email) ?? 'guest@local';
    final async = ref.watch(liveCategoryProgressProvider(email));
    return async.when(
      data: (items) {
        if (items.isEmpty) return const Text('No categories yet');
        final hasMany = items.length > 1;
        final controller = PageController(viewportFraction: 0.88);
        final height = 280.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: controller,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final color = _piePalette[i % _piePalette.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: _PieCard.big(item: items[i], color: color),
                  );
                },
              ),
            ),
            if (hasMany)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Swipe to see more >',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Failed to load progress: $e'),
    );
  }

  Widget _progressChart(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Consumer(
        builder: (context, ref, _) {
          final db = ref.watch(dbProvider);
          final user = ref.watch(currentUserProvider);
          final email = user?.email ?? 'guest@local';
          return FutureBuilder(
            future:
                (db.select(db.attempts)
                      ..where(
                        (t) =>
                            t.endedAt.isNotNull() & t.userEmail.equals(email),
                      )
                      ..orderBy([(t) => drift.OrderingTerm.desc(t.startedAt)])
                      ..limit(7))
                    .get(),
            builder: (context, snap) {
              final items = (snap.data ?? const <Attempt>[]).reversed.toList();
              if (items.isEmpty) {
                return NeonGlassCard(
                  padding: const EdgeInsets.all(12),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('No attempts yet'),
                    ),
                  ),
                );
              }
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final lineColor = Theme.of(context).colorScheme.primary;
              final spots = [
                for (var i = 0; i < items.length; i++)
                  FlSpot(i.toDouble(), items[i].scorePercent.toDouble()),
              ];
              return NeonGlassCard(
                padding: const EdgeInsets.all(12),
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            if (i < 0 || i >= items.length)
                              return const SizedBox.shrink();
                            final d = items[i].startedAt;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${d.month}/${d.day}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, meta) {
                            if (v % 25 != 0) return const SizedBox.shrink();
                            return Text(
                              '${v.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: lineColor,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: lineColor.withValues(alpha: 0.18),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 3,
                                color: lineColor,
                                strokeWidth: 1,
                                strokeColor: isDark
                                    ? Colors.white24
                                    : Colors.black12,
                              ),
                        ),
                        spots: spots,
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _recentAttempts(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'guest@local';
    return FutureBuilder(
      future:
          (db.select(db.attempts)
                ..where((t) => t.userEmail.equals(email))
                ..orderBy([(t) => drift.OrderingTerm.desc(t.startedAt)])
                ..limit(10))
              .get(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Failed to load attempts: ${snap.error}');
        }
        final attempts = snap.data ?? const <Attempt>[];
        return FutureBuilder(
          future: () async {
            final exams = attempts.isEmpty
                ? <Exam>[]
                : await (db.select(db.exams)..where(
                        (e) => e.id.isIn(
                          attempts.map((a) => a.examId).toSet().toList(),
                        ),
                      ))
                      .get();
            final cats = exams.isEmpty
                ? <Category>[]
                : await (db.select(db.categories)..where(
                        (c) => c.id.isIn(
                          exams.map((e) => e.categoryId).toSet().toList(),
                        ),
                      ))
                      .get();
            final subIds = exams
                .map((e) => e.subcategoryId)
                .where((id) => id != null)
                .cast<int>()
                .toSet()
                .toList();
            final subs = subIds.isEmpty
                ? <Subcategory>[]
                : await (db.select(
                    db.subcategories,
                  )..where((s) => s.id.isIn(subIds))).get();
            return (exams: exams, cats: cats, subs: subs);
          }(),
          builder: (context, snap2) {
            if (snap2.hasError)
              return Text('Failed to load exam info: ${snap2.error}');
            final extras = snap2.data;
            if (attempts.isEmpty)
              return const Text('No attempts yet. Start from Categories.');
            final exams = (extras?.exams ?? const <Exam>[]);
            final cats = (extras?.cats ?? const <Category>[]);
            final subs = (extras?.subs ?? const <Subcategory>[]);
            return Column(
              children: [
                for (var i = 0; i < attempts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NeonGlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(
                          (attempts[i].endedAt == null)
                              ? Icons.play_arrow
                              : Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: () {
                          final a = attempts[i];
                          final ex = exams.firstWhere(
                            (e) => e.id == a.examId,
                            orElse: () => Exam(
                              id: a.examId,
                              title: 'Exam ${a.examId}',
                              description: '',
                              categoryId: 0,
                              subcategoryId: null,
                              questionCount: 0,
                              published: false,
                              timeLimitMinutes: 0,
                              shuffleOptions: true,
                              negativeMarking: false,
                              passPercent: 0,
                              themeKey: 0,
                              pdfUrl: '',
                            ),
                          );
                          final cat = cats.firstWhere(
                            (c) => c.id == ex.categoryId,
                            orElse: () => Category(
                              id: ex.categoryId,
                              name: 'Category',
                              order: 0,
                              passPercent: 0,
                              imageUrl: '',
                              locked: false,
                            ),
                          );
                          final sub = (ex.subcategoryId != null)
                              ? subs.firstWhere(
                                  (s) => s.id == ex.subcategoryId,
                                  orElse: () => Subcategory(
                                    id: ex.subcategoryId!,
                                    categoryId: ex.categoryId,
                                    name: 'Sub',
                                    order: 0,
                                    imageUrl: '',
                                    locked: false,
                                  ),
                                )
                              : null;
                          final label = sub == null
                              ? sanitizeDisplayText(cat.name)
                              : '${sanitizeDisplayText(cat.name)} - ${sanitizeDisplayText(sub.name)}';
                          final on = Theme.of(context).colorScheme.onSurface;
                          return Text(
                            '${sanitizeDisplayText(ex.title)} - $label',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: on.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }(),
                        subtitle: Builder(
                          builder: (context) {
                            final on = Theme.of(context).colorScheme.onSurface;
                            return Text(
                              '${attempts[i].endedAt == null ? 'In progress' : 'Score ${attempts[i].scorePercent}%'} - ${attempts[i].startedAt.toLocal()}'
                                  .split('.')
                                  .first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: on.withValues(alpha: 0.7),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          final a = attempts[i];
                          if (a.endedAt == null) {
                            context.go('/player/${a.examId}?aid=${a.id}');
                          } else {
                            context.go('/result/${a.id}');
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Minimal palette: three very light tints for a calm, professional look
  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: NeonGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final font = (w * 0.12).clamp(12.0, 16.0);
            final on = Theme.of(context).colorScheme.onSurface;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: on.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: on.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                    fontSize: font,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _quickActionsGrid(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final tilesPerRow = (width ~/ 120).clamp(2, 3);
    final items = <({String label, IconData icon, VoidCallback onTap})>[
      (
        label: 'Categories',
        icon: Icons.category,
        onTap: () => context.go('/categories'),
      ),
      (
        label: 'Continue',
        icon: Icons.play_arrow,
        onTap: () async {
          final repo = ref.read(examRepositoryProvider);
          final user = ref.read(currentUserProvider);
          final email = user?.email ?? 'guest@local';
          final attempt = await repo.findOngoingAttempt(email);
          if (attempt == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No ongoing exam. Start one from Categories.'),
                ),
              );
            }
            return;
          }
          if (context.mounted)
            context.go('/player/${attempt.examId}?aid=${attempt.id}');
        },
      ),
      (label: 'Saved', icon: Icons.bookmark, onTap: () => context.go('/saved')),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tilesPerRow,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final a = items[i];
        return _actionCard(
          context,
          icon: a.icon,
          label: a.label,
          index: i,
          onTap: a.onTap,
        );
      },
    );
  }
}

const List<Color> _piePalette = [
  Color(0xFF6C63FF),
  Color(0xFF4CAF50),
  Color(0xFFFF7043),
  Color(0xFFFFC107),
  Color(0xFF26C6DA),
  Color(0xFFAB47BC),
];

class _PieCard extends StatelessWidget {
  final CategoryProgress item;
  final Color color;
  final bool big;
  const _PieCard({required this.item, required this.color}) : big = false;
  const _PieCard.big({required this.item, required this.color}) : big = true;
  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onSurface;
    final diameter = big ? 180.0 : 90.0;
    final width = big ? MediaQuery.of(context).size.width - 48 : 150.0;
    final pendingColor = Colors.grey.withValues(alpha: 0.25);
    return SizedBox(
      width: width,
      child: NeonGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: diameter,
              width: diameter,
              child: _AnimatedPie(
                completed: item.completed,
                total: item.total,
                color: color,
                pendingColor: pendingColor,
                showCounts: true,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              sanitizeDisplayText(item.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: on.withValues(alpha: 0.95),
                fontSize: big ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPie extends StatefulWidget {
  final int completed;
  final int total;
  final Color color;
  final Color? pendingColor;
  final bool showCounts;
  const _AnimatedPie({
    required this.completed,
    required this.total,
    required this.color,
    this.pendingColor,
    this.showCounts = false,
  });
  @override
  State<_AnimatedPie> createState() => _AnimatedPieState();
}

class _AnimatedPieState extends State<_AnimatedPie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();
  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.total == 0 ? 1 : widget.total;
    final completed = widget.completed.clamp(0, total);
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_ac.value);
        final done = (completed * t).toDouble();
        final remain = (total.toDouble() - done)
            .clamp(0.0, total.toDouble())
            .toDouble();
        final percent = ((done / total) * 100).round();
        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                sections: [
                  PieChartSectionData(
                    color: widget.color,
                    value: done,
                    title: '',
                    radius: 64,
                  ),
                  PieChartSectionData(
                    color:
                        widget.pendingColor ??
                        Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.14),
                    value: remain,
                    title: '',
                    radius: 58,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (widget.showCounts)
                  Text(
                    '${widget.completed}/${widget.total}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

Widget _zenovFooter(BuildContext context) {
  final on = Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black87;
  final sub = on.withValues(alpha: 0.75);
  return Column(
    children: [
      Text(
        'Developed by ZenovTech (c) 2025',
        style: TextStyle(color: sub, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      Text('info@zenovtech.com', style: TextStyle(color: sub)),
      const SizedBox(height: 4),
      Text(
        'Contact for websites and mobile app development',
        style: TextStyle(color: sub),
      ),
    ],
  );
}
