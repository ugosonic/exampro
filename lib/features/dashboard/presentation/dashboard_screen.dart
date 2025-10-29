import 'package:exampro/app/theme/theme_controller.dart';
import 'package:exampro/common/widgets/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exampro/features/exam/data/exam_repository.dart';
import 'package:exampro/features/catalog/data/catalog_repository.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/notifications/notifications.dart';
import 'package:exampro/common/widgets/neon_glass.dart';
import 'package:exampro/features/sync/data/sync_api.dart';
import 'package:exampro/features/sync/data/sync_repository.dart';
import 'package:exampro/features/auth/application/auth_session.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateBanner = FutureBuilder<String?>(
      future: () async {
        try {
          final remote = await ref.read(syncApiProvider).version();
          final local = await ref.read(syncRepositoryProvider).localVersion();
          if (local == null || local != remote) return remote;
        } catch (_) {}
        return null;
      }(),
      builder: (context, snap) {
        final ver = snap.data;
        if (ver == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            color: Colors.amber.withValues(alpha: 0.12),
            child: ListTile(
              leading: const Icon(Icons.system_update, color: Colors.amber),
              title: const Text('New content available'),
              subtitle: const Text('Tap Update to sync latest questions'),
              trailing: FilledButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Update'),
              ),
            ),
          ),
        );
      },
    );
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ExamPro'), actions: [
        IconButton(
          tooltip: 'Theme',
          onPressed: () {
            final next = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            ref.read(themeModeProvider.notifier).state = next;
          },
          icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
        )
      ]),
      body: NeonBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (updateBanner != null)
                NeonGlassCard(
                  child: updateBanner,
                ),
              const SizedBox(height: 16),
              NeonGlassCard(child: _dailyGoal(context)),
              const SizedBox(height: 16),
              NeonGlassCard(child: _quickActionsGrid(context, ref)),
              const SizedBox(height: 16),
              NeonGlassCard(child: _maybeUpgradeCard(context, ref)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('Select Country', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              NeonGlassCard(child: _homeCategoriesGrid(context)),
              const SizedBox(height: 20),
              NeonGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700)),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent attempts', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700)),
                        TextButton(onPressed: () => context.go('/attempts'), child: const Text('View all')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _recentAttempts(context, ref),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

class _CategoryImage extends StatelessWidget {
  final String src;
  const _CategoryImage({required this.src});
  @override
  Widget build(BuildContext context) {
    final isHttp = src.startsWith('http://') || src.startsWith('https://');
    final w = 90.0, h = 60.0;
    final border = BorderRadius.circular(10);
    if (isHttp) {
      return ClipRRect(
        borderRadius: border,
        child: Image.network(src, width: w, height: h, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(w, h)),
      );
    }
    final f = File(src);
    if (!f.existsSync()) return _fallback(w, h);
    return Image.file(f, width: w, height: h, fit: BoxFit.cover);
  }

  Widget _fallback(double w, double h) => Container(width: w, height: h, color: Colors.white.withValues(alpha: 0.06), child: const Icon(Icons.image_not_supported, color: Colors.white70));
}

  Widget _homeCategoriesGrid(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final catsAsync = ref.watch(categoriesProvider);
      final db = ref.watch(dbProvider);
      final user = ref.watch(currentUserProvider);
      return catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Text('Failed to load categories: $e'),
        data: (cats) {
          return FutureBuilder<bool>(
            future: () async {
              if (user == null) return false;
              final row = await (db.select(db.users)..where((u) => u.email.equals(user.email))).getSingleOrNull();
              return row?.isPro ?? false;
            }(),
            builder: (context, snap) {
              final isPro = snap.data ?? false;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
                ),
                itemCount: cats.length,
                itemBuilder: (context, i) {
                  final c = cats[i];
                  final icon = [Icons.biotech, Icons.science, Icons.bubble_chart, Icons.functions][i % 4];
                  return TapScale(
                    onTap: () {
                      if (c.locked && !isPro) {
                        context.go('/upgrade');
                      } else {
                        context.go('/categories/${c.id}');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: c.imageUrl.isEmpty
                            ? LinearGradient(colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.10),
                              ], begin: Alignment.topLeft, end: Alignment.bottomRight)
                            : null,
                      ),
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
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                          ])),
                        ]),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    });
  }

  Widget _dailyGoal(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final db = ref.watch(dbProvider);
      return FutureBuilder(
        future: (db.select(db.dailyGoals)..limit(1)).getSingleOrNull(),
        builder: (context, snap) {
          final g = snap.data;
          final target = g?.minutesTarget ?? 15;
          final notify = g?.notify ?? false;
          return Container(
            decoration: BoxDecoration(
              gradient: _softGradients[0],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Daily Goal', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black.withValues(alpha: 0.85))),
                    const SizedBox(height: 4),
                    Text('$target mins • Notifications: ${notify ? 'On' : 'Off'}', style: TextStyle(color: Colors.black.withValues(alpha: 0.6)))
                  ]),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).colorScheme.primary),
                  onPressed: () => _editGoal(context, ref),
                  child: const Text('Edit'),
                )
              ],
            ),
          );
        },
      );
    });
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final existing = await (db.select(db.dailyGoals)..limit(1)).getSingleOrNull();
    final minutes = TextEditingController(text: (existing?.minutesTarget ?? 15).toString());
    bool notify = existing?.notify ?? false;
    int hour = existing?.reminderHour ?? 9;
    int minute = existing?.reminderMinute ?? 0;
    DateTime? examDate = existing?.examDate;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        return AlertDialog(
          title: const Text('Daily Goal'),
          content: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutes per day')),
              const SizedBox(height: 8),
              SwitchListTile(value: notify, onChanged: (v) => set(() => notify = v), title: const Text('Daily reminder')),
              Row(children: [
                const Text('Reminder time:'),
                const SizedBox(width: 8),
                DropdownButton<int>(value: hour, items: [for (var h=0;h<24;h++) DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2,'0')))], onChanged: (v) => set(() => hour = v ?? hour)),
                const Text(':'),
                DropdownButton<int>(value: minute, items: [for (var m=0;m<60;m+=5) DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2,'0')))], onChanged: (v) => set(() => minute = v ?? minute)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Exam date (optional):'),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () async { final picked = await showDatePicker(context: ctx, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: examDate ?? DateTime.now()); if (picked != null) set(() => examDate = picked); }, child: Text(examDate == null ? 'Pick date' : '${examDate!.year}-${examDate!.month}-${examDate!.day}')),
              ])
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
          ],
        );
      }),
    );
    if (ok == true) {
      final mins = int.tryParse(minutes.text.trim()) ?? 15;
      if (existing == null) {
        await db.into(db.dailyGoals).insert(DailyGoalsCompanion.insert(
          minutesTarget: drift.Value(mins),
          notify: drift.Value(notify),
          reminderHour: drift.Value(hour),
          reminderMinute: drift.Value(minute),
          examDate: examDate == null ? const drift.Value.absent() : drift.Value(examDate),
        ));
      } else {
        await (db.update(db.dailyGoals)..where((t) => t.id.equals(existing.id))).write(DailyGoalsCompanion(
          minutesTarget: drift.Value(mins),
          notify: drift.Value(notify),
          reminderHour: drift.Value(hour),
          reminderMinute: drift.Value(minute),
          examDate: drift.Value(examDate),
        ));
      }
      if (notify) {
        await NotificationsService.init();
        await NotificationsService.scheduleDaily(1001, hour, minute, title: 'Daily goal', body: 'Practice for $mins minutes today.');
      } else {
        await NotificationsService.cancel(1001);
      }
    }
  }

  Widget _card(BuildContext context, String label, IconData icon, {VoidCallback? onTap}) => TapScale(
        onTap: onTap,
        child: Card(
          child: SizedBox(
            height: 100,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(height: 8), Text(label)]),
            ),
          ),
        ),
      );

  Widget _examTile(BuildContext context, String title, int mins) => Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text('$mins mins'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );

  Widget _progressChart(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Consumer(builder: (context, ref, _) {
        final db = ref.watch(dbProvider);
        final user = ref.watch(currentUserProvider);
        final email = user?.email ?? 'guest@local';
        return FutureBuilder(
          future: (db.select(db.attempts)
                ..where((t) => t.endedAt.isNotNull() & t.userEmail.equals(email))
                ..orderBy([(t) => drift.OrderingTerm.desc(t.startedAt)])
                ..limit(7))
              .get(),
          builder: (context, snap) {
            final items = (snap.data ?? const <Attempt>[]).reversed.toList();
            if (items.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  color: _softSolids[2],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: const Center(child: Padding(padding: EdgeInsets.all(12.0), child: Text('No attempts yet'))),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: _softSolids[0],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= items.length) return const SizedBox.shrink();
                        final d = items[i].startedAt;
                        final label = '${d.month}/${d.day}';
                        return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label, style: const TextStyle(fontSize: 10)));
                      })),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, meta) {
                        if (v % 25 != 0) return const SizedBox.shrink();
                        return Text('${v.toInt()}', style: const TextStyle(fontSize: 10));
                      })),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < items.length; i++)
                        BarChartGroupData(x: i, barRods: [BarChartRodData(toY: items[i].scorePercent.toDouble(), width: 14, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85))])
                    ],
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    maxY: 100,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _maybeUpgradeCard(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder(
      future: (db.select(db.users)..where((u) => u.email.equals(user.email))).getSingleOrNull(),
      builder: (context, snap) {
        final row = snap.data;
        if (row?.isPro == true) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            gradient: _softGradients[1],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: ListTile(
            leading: Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary),
            title: Text('Upgrade to Pro', style: TextStyle(color: Colors.black.withValues(alpha: 0.85), fontWeight: FontWeight.w700)),
            subtitle: Text('Unlock all locked categories and questions', style: TextStyle(color: Colors.black.withValues(alpha: 0.6))),
            trailing: Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.7)),
            onTap: () => context.go('/upgrade'),
          ),
        );
      },
    );
  }

  Widget _recentAttempts(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'guest@local';
    return FutureBuilder(
      future: (db.select(db.attempts)
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
                : await (db.select(db.exams)..where((e) => e.id.isIn(attempts.map((a) => a.examId).toSet().toList()))).get();
            final cats = exams.isEmpty
                ? <Category>[]
                : await (db.select(db.categories)..where((c) => c.id.isIn(exams.map((e) => e.categoryId).toSet().toList()))).get();
            final subIds = exams.map((e) => e.subcategoryId).where((id) => id != null).cast<int>().toSet().toList();
            final subs = subIds.isEmpty ? <Subcategory>[] : await (db.select(db.subcategories)..where((s) => s.id.isIn(subIds))).get();
            return (exams: exams, cats: cats, subs: subs);
          }(),
          builder: (context, snap2) {
            if (snap2.hasError) return Text('Failed to load exam info: ${snap2.error}');
            final extras = snap2.data;
            if (attempts.isEmpty) return const Text('No attempts yet. Start from Categories.');
            final exams = (extras?.exams as List<Exam>? ?? const <Exam>[]);
            final cats = (extras?.cats as List<Category>? ?? const <Category>[]);
            final subs = (extras?.subs as List<Subcategory>? ?? const <Subcategory>[]);
            return Column(children: [
              for (var i = 0; i < attempts.length; i++)
                Container(
                  decoration: BoxDecoration(
                    color: _softSolids[i % 2],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon((attempts[i].endedAt == null) ? Icons.play_arrow : Icons.check, color: Theme.of(context).colorScheme.primary),
                    title: () {
                      final a = attempts[i];
                      final ex = exams.firstWhere((e) => e.id == a.examId, orElse: () => Exam(
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
                      ));
                      final cat = cats.firstWhere((c) => c.id == ex.categoryId, orElse: () => Category(id: ex.categoryId, name: 'Category', order: 0, passPercent: 0, imageUrl: '', locked: false));
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
                      final label = sub == null ? cat.name : '${cat.name} • ${sub.name}';
                      return Text('${ex.title} • $label', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black.withValues(alpha: 0.85), fontWeight: FontWeight.w600));
                    }(),
                    subtitle: Text('${attempts[i].endedAt == null ? 'In progress' : 'Score ${attempts[i].scorePercent}%'} • ${attempts[i].startedAt.toLocal()}'.split('.').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black.withValues(alpha: 0.6))),
                    onTap: () {
                      final a = attempts[i];
                      if (a.endedAt == null) {
                        context.go('/player/${a.examId}?aid=${a.id}');
                      } else {
                        context.go('/result/${a.id}');
                      }
                    },
                  ),
                )
            ]);
          },
        );
      },
    );
  }

  // Minimal palette: three very light tints for a calm, professional look
  List<Gradient> get _softGradients => const [
        LinearGradient(colors: [Color(0xFFF5F7FF), Color(0xFFE9EEFF)], begin: Alignment.topLeft, end: Alignment.bottomRight), // soft indigo
        LinearGradient(colors: [Color(0xFFF6FFFA), Color(0xFFE7FFF2)], begin: Alignment.topLeft, end: Alignment.bottomRight), // soft green
        LinearGradient(colors: [Color(0xFFFFF7F5), Color(0xFFFFEEE8)], begin: Alignment.topLeft, end: Alignment.bottomRight), // soft coral
      ];

  List<Color> get _softSolids => const [
        Color(0xFFF5F7FF), // indigo tint
        Color(0xFFF6FFFA), // green tint
        Color(0xFFFFF7F5), // coral tint
      ];

  Widget _actionCard(BuildContext context, {required IconData icon, required String label, required int index, required VoidCallback onTap}) {
    final gradient = _softGradients[index % 3];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          final font = (w * 0.12).clamp(12.0, 16.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 6),
              Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.fade, style: TextStyle(color: Colors.black.withValues(alpha: 0.85), fontWeight: FontWeight.w700, fontSize: font)),
            ],
          );
        }),
      ),
    );
  }

  Widget _quickActionsGrid(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final tilesPerRow = (width ~/ 120).clamp(2, 3);
    final items = <({String label, IconData icon, VoidCallback onTap})>[
      (label: 'Categories', icon: Icons.category, onTap: () => context.go('/categories')),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No ongoing exam. Start one from Categories.')));
            }
            return;
          }
          if (context.mounted) context.go('/player/${attempt.examId}?aid=${attempt.id}');
        },
      ),
      (label: 'Saved', icon: Icons.bookmark, onTap: () => context.go('/saved')),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: tilesPerRow),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final a = items[i];
        return _actionCard(context, icon: a.icon, label: a.label, index: i, onTap: a.onTap);
      },
    );
  }
}
