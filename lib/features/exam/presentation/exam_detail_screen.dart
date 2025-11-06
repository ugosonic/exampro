import 'package:exampro/core/i18n/tr_text.dart';
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/exam/data/exam_repository.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/exam/presentation/pdf_viewer_screen.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exampro/features/auth/application/auth_session.dart';

class ExamDetailScreen extends ConsumerWidget {
  final String examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final repo = ref.watch(examRepositoryProvider);
    final id = int.tryParse(examId) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const TrText('Exam'),
        actions: [
          IconButton(
            tooltip: 'Report',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () async {
              final comment = await _promptComment(context);
              if (comment == null || comment.trim().isEmpty) return;
              final user = ref.read(currentUserProvider);
              final email = user?.email ?? 'guest@local';
              await ref.read(examRepositoryProvider).submitReport(examId: id, userEmail: email, comment: comment.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent')));
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Exam?>(
          future: (db.select(db.exams)..where((e) => e.id.equals(id))).getSingleOrNull(),
          builder: (context, snap) {
            final ex = snap.data;
            if (ex == null) return const Center(child: CircularProgressIndicator());
            // Gate if locked and user is not pro
            return FutureBuilder(
              future: () async {
                final cat = await (db.select(db.categories)..where((c) => c.id.equals(ex.categoryId))).getSingle();
                Subcategory? sub;
                if (ex.subcategoryId != null) {
                  sub = await (db.select(db.subcategories)..where((s) => s.id.equals(ex.subcategoryId!))).getSingleOrNull();
                }
                final user = ref.read(currentUserProvider);
                bool isPro = false;
                if (user != null) {
                  final row = await (db.select(db.users)..where((u) => u.email.equals(user.email))).getSingleOrNull();
                  isPro = row?.isPro ?? false;
                }
                final locked = (cat.locked) || (sub?.locked ?? false);
                // Read-only flag stored in app_settings as exam_readonly_<id>
                final key = 'exam_readonly_${id}';
                final ro = await (db.select(db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
                final readOnly = (ro?.value == '1');
                return (cat: cat, sub: sub, isPro: isPro, locked: locked, readOnly: readOnly);
              }(),
              builder: (context, gateSnap) {
                final g = gateSnap.data;
                if (g == null) return const Center(child: CircularProgressIndicator());
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _themeGradient(ex.themeKey),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 26, child: Icon(_iconForExam(ex.id))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ex.title, style: Theme.of(context).textTheme.headlineSmall)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('#questions: ${ex.questionCount}   •   Time: ${ex.timeLimitMinutes} mins   •   Pass: ${ex.passPercent}%'),
                  if (ex.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(ex.description),
                  ],
                  if ((ex.pdfUrl).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    FutureBuilder<({bool readOnly, int page, String email})>(
                      future: () async {
                        final user = ref.read(currentUserProvider);
                        final email = user?.email ?? 'guest@local';
                        final key = 'exam_readonly_${id}';
                        final row = await (db.select(db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
                        final ro = (row?.value == '1');
                        final page = await repo.pdfProgress(examId: id, userEmail: email);
                        return (readOnly: ro, page: page, email: email);
                      }(),
                      builder: (context, snap) {
                        final st = snap.data;
                        final page = st?.page ?? 0;
                        final email = st?.email ?? 'guest@local';
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            onPressed: () {
                              final env = ref.read(envLoaderProvider).requireValue;
                              final src = ex.pdfUrl.startsWith('http')
                                  ? ex.pdfUrl
                                  : ex.pdfUrl.startsWith('/')
                                      ? '${env.apiBaseUrl}${ex.pdfUrl}'
                                      : ex.pdfUrl; // local path
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(
                                    source: src,
                                    examId: id,
                                    userEmail: email,
                                    initialPage: page,
                                  ),
                                ),
                              );
                            },
                            label: Text(page > 0 ? 'Continue reading (page ${page + 1})' : 'Read PDF'),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Attempt>>(
                      future: () async {
                        final user = ref.read(currentUserProvider);
                        final email = user?.email ?? 'guest@local';
                        return repo.attemptsForExam(id, email);
                      }(),
                      builder: (context, attemptsSnap) {
                        final attempts = attemptsSnap.data ?? const [];
                        final ongoing = attempts.where((a) => a.endedAt == null).toList();
                        return Column(children: [
                          if (attempts.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('History', style: Theme.of(context).textTheme.titleMedium),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.separated(
                                itemCount: attempts.length,
                                itemBuilder: (_, i) {
                                  final a = attempts[i];
                                  final ended = a.endedAt;
                                  final date = ended ?? a.startedAt;
                                  final subtitle = (ended == null)
                                      ? 'In progress'
                                      : 'Score: ${a.scorePercent}% ${a.gradeLabel.isNotEmpty ? ' • ${a.gradeLabel}' : ''}';
                                  return ListTile(
                                    leading: Icon(ended == null ? Icons.play_circle : Icons.check_circle, color: ended == null ? Colors.orange : Colors.green),
                                    title: Text('${date.toLocal()}'.split('.').first),
                                    subtitle: Text(subtitle),
                                    onTap: () {
                                      if (ended == null) {
                                        context.go('/player/$examId?aid=${a.id}');
                                      } else {
                                        context.go('/result/${a.id}');
                                      }
                                    },
                                  );
                                },
                                separatorBuilder: (_, __) => const Divider(height: 1),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ] else const Spacer(),
                          if (g.locked && !g.isPro)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => context.go('/upgrade'),
                                child: const Text('Upgrade to Pro'),
                              ),
                            )
                          else if (ex.pdfUrl.isNotEmpty && (ex.questionCount == 0 || g.readOnly == true)) ...[
                            // PDF-only exam: show only PDF button above; hide actions
                          ] else
                            Column(children: [
                              Row(children: [
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () => context.go('/player/$examId?mode=practice'),
                                    child: const Text('Practice (untimed)'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () async {
                                      final user = ref.read(currentUserProvider);
                                      final email = user?.email ?? 'guest@local';
                                      final existing = ongoing.isNotEmpty ? ongoing.first : await repo.findOngoingAttemptForExam(id, email);
                                      if (existing != null && context.mounted) {
                                        final choice = await showDialog<String>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Resume assignment?'),
                                            content: const Text('You have an ongoing assignment. Resume or start over?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(ctx).pop('new'), child: const Text('Start Over')),
                                              FilledButton(onPressed: () => Navigator.of(ctx).pop('resume'), child: const Text('Resume')),
                                            ],
                                          ),
                                        );
                                        if (choice == 'resume') {
                                          context.go('/player/$examId?aid=${existing.id}&mode=assignment');
                                        } else if (choice == 'new') {
                                          context.go('/player/$examId?mode=assignment');
                                        }
                                      } else {
                                        context.go('/player/$examId?mode=assignment');
                                      }
                                    },
                                    child: const Text('Start Assignment'),
                                  ),
                                )
                              ]),
                            ]),
                        ]);
                      },
                    ),
                  ),
                ],
              ),
              );
              },
            );
          },
        ),
      ),
    );
  }
}

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

Future<String?> _promptComment(BuildContext context) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Report exam'),
      content: TextField(controller: c, autofocus: true, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe the issue')), 
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(c.text), child: const Text('Send')),
      ],
    ),
  );
}



