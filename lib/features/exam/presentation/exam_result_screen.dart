import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExamResultScreen extends ConsumerWidget {
  final String attemptId;
  const ExamResultScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final aid = int.tryParse(attemptId) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: FutureBuilder<({Attempt attempt, Exam exam})?>(
        future: _load(db, aid),
        builder: (context, snap) {
          final data = snap.data;
          if (data == null) return const Center(child: CircularProgressIndicator());
          final attempt = data.attempt;
          final exam = data.exam;
          final percent = attempt.scorePercent;
          final pass = percent >= exam.passPercent;
          final color = pass ? Colors.green : Colors.red;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(exam.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: color.withValues(alpha: 0.1),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Column(children: [
                    Text('$percent%', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(pass ? 'Passed' : 'Failed', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Pass mark: ${exam.passPercent}%'),
                  ]),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/review/${attempt.id}'),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Review answers'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.go('/player/${exam.id}'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.go('/exam/${exam.id}'),
                  child: const Text('Back to exam'),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<({Attempt attempt, Exam exam})?> _load(AppDatabase db, int aid) async {
    final a = await (db.select(db.attempts)..where((t) => t.id.equals(aid))).getSingleOrNull();
    if (a == null) return null;
    final e = await (db.select(db.exams)..where((t) => t.id.equals(a.examId))).getSingle();
    return (attempt: a, exam: e);
  }
}
