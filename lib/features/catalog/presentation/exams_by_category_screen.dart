import 'package:exampro/features/catalog/data/catalog_repository.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:exampro/common/widgets/neon_glass.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/features/catalog/data/content_api.dart';

class ExamsByCategoryScreen extends ConsumerWidget {
  final String categoryId;
  const ExamsByCategoryScreen({super.key, required this.categoryId});

  IconData _iconForExam(int examId) {
    const icons = [
      Icons.menu_book,
      Icons.school,
      Icons.assignment,
      Icons.fact_check,
      Icons.quiz,
      Icons.psychology,
      Icons.lightbulb,
      Icons.science,
    ];
    return icons[examId % icons.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(catalogRepositoryProvider);
    final db = ref.watch(dbProvider);
    final id = int.tryParse(categoryId) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Exams'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.canPop() ? context.pop() : context.go('/categories')) ),
      body: NeonBackground(
        child: FutureBuilder(
        future: () async {
          final list = await repo.exams(categoryId: id);
          final user = ref.read(currentUserProvider);
          final email = user?.email ?? 'guest@local';
          bool isPro = false;
          if (user != null) {
            final row = await (db.select(db.users)..where((u) => u.email.equals(user.email))).getSingleOrNull();
            isPro = row?.isPro ?? false;
          }
          final catLocked = await repo.isCategoryLocked(id);
          // Build subcategory info (name/locked) using remote when available
          final env = ref.read(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
          final hasApi = env != null && (env!.apiBaseUrl.isNotEmpty);
          final subIds = list.map((e) => e.subcategoryId).where((x) => x != null && x != 0).cast<int>().toSet().toList();
          final List<Map<String, dynamic>> subs = subIds.isEmpty
              ? const <Map<String, dynamic>>[]
              : hasApi
                  ? await ref
                      .read(contentApiProvider)
                      .subcategories(categoryId: id)
                      .then((rows) => [
                            for (final m in rows)
                              if (subIds.contains((m['id'] as num).toInt())) m,
                          ])
                  : [
                      for (final s in await (db.select(db.subcategories)..where((s) => s.id.isIn(subIds))).get())
                        {
                          'id': s.id,
                          'name': s.name,
                          'locked': s.locked,
                        }
                    ];
          final subLocked = {
            for (final m in subs) (m['id'] as int): ((m['locked'] as bool?) ?? false)
          };
          // Completed exams set
          final completedRows = await (db.select(db.attempts)
                ..where((a) => a.endedAt.isNotNull() & a.userEmail.equals(email)))
              .get();
          final completed = completedRows.map((a) => a.examId).toSet();
          return (exams: list, catLocked: catLocked, subLocked: subLocked, isPro: isPro, subs: subs, completed: completed);
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load exams: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }
          final data = snapshot.data!;
          final exams = data.exams as List;
          final catLocked = data.catLocked as bool;
          final subLocked = (data.subLocked as Map);
          final isPro = data.isPro as bool;
          final List<Map<String, dynamic>> subs = (data.subs as List).cast<Map<String, dynamic>>();
          final completed = (data.completed as Set);
          if (exams.isEmpty) {
            return const Center(child: Text('No exams yet in this category'));
          }
          // Build grouped list: Practice All, spacing, heading, then subcategory sections
          final bySub = <int?, List<dynamic>>{};
          for (final e in exams) {
            final k = e.subcategoryId as int?;
            (bySub[k] ??= []).add(e);
          }
          String labelFor(int? sid) {
            if (sid == null || sid == 0) return 'General';
            final m = subs.firstWhere(
              (e) => ((e['id'] as num).toInt() == sid),
              orElse: () => const <String, dynamic>{},
            );
            return (m['name'] as String?) ?? 'General';
          }

          final children = <Widget>[
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.play_circle_outline)),
                title: const Text('Practice all questions in this category (untimed)'),
                subtitle: const Text('Immediate feedback • No timer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/player/0?mode=practice&cat=$id'),
              ),
            ),
            const SizedBox(height: 12),
            Text('Take a test', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
          ];
          final keys = bySub.keys.toList()
            ..sort((a, b) => labelFor(a).compareTo(labelFor(b)));
          for (final k in keys) {
            children.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(labelFor(k), style: Theme.of(context).textTheme.labelLarge),
            ));
            for (final e in bySub[k]!) {
              final locked = !isPro && (catLocked || (e.subcategoryId != null && (subLocked[e.subcategoryId] == true)));
              final grad = _themeGradient(e.themeKey ?? 0);
              children.add(Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: grad ?? LinearGradient(colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.2), child: Icon(_iconForExam(e.id), color: Colors.white)),
                  title: Text(e.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text('${e.questionCount} questions', style: TextStyle(color: Colors.white.withOpacity(0.85))),
                  trailing: locked
                      ? const Icon(Icons.lock, color: Colors.white)
                      : (completed.contains(e.id)
                          ? const Icon(Icons.check_circle, color: Colors.white)
                          : const Icon(Icons.chevron_right, color: Colors.white)),
                  onTap: () => locked ? context.go('/upgrade') : context.go('/exam/${e.id}'),
                ),
              ));
            }
          }
          return ListView(padding: const EdgeInsets.all(16), children: children);
        },
      ),
      ),
    );
  }
}

Gradient? _themeGradient(int key) {
  switch (key) {
    case 1:
      return const LinearGradient(colors: [Color(0xFFFFD194), Color(0xFFD1913C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 2:
      return const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 3:
      return const LinearGradient(colors: [Color(0xFF56ab2f), Color(0xFFa8e063)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 4:
      return const LinearGradient(colors: [Color(0xFFDAE2F8), Color(0xFFD6A4A4)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 5:
      return const LinearGradient(colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    default:
      return null;
  }
}
