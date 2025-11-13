import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/features/exam/data/exam_repository.dart';
import 'package:flutter/material.dart';
import 'package:citizentest/core/i18n/tr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttemptReviewScreen extends ConsumerWidget {
  final String attemptId;
  const AttemptReviewScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(examRepositoryProvider);
    final aid = int.tryParse(attemptId) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const TrText('Review Answers')),
      body: FutureBuilder<List<({Question question, List<Choice> options, List<int> selected, bool isCorrect})>>(
        future: repo.attemptReview(aid),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (items.isEmpty) return const Center(child: Text('No answers recorded'));
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (var i = 0; i < items.length; i++)
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: items[i].isCorrect ? Colors.green : Colors.red,
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ]),
              const SizedBox(height: 12),
              for (var i = 0; i < items.length; i++) _tile(context, i + 1, items[i]),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, int index, ({Question question, List<Choice> options, List<int> selected, bool isCorrect}) item) {
    final correctIds = item.options.where((o) => o.isCorrect).map((o) => o.id).toSet();
    final sel = item.selected.toSet();
    return Card(
      child: ExpansionTile(
        title: Row(children: [
          Icon(item.isCorrect ? Icons.check_circle : Icons.cancel, color: item.isCorrect ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text('Q$index', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 6),
            Text(item.question.body, softWrap: true),
            const SizedBox(height: 6),
            const SizedBox(height: 8),
            const TrText('Options'),
            const SizedBox(height: 4),
            ...item.options.map((o) {
              final chosen = sel.contains(o.id);
              final correct = correctIds.contains(o.id);
              Color? color;
              if (correct) {
                color = Colors.green;
              } else if (chosen) {
                color = Colors.red;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• ${o.label}', style: TextStyle(color: color)),
              );
            }),
            if (item.question.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              const TrText('Explanation:'),
              const SizedBox(height: 4),
              Text(item.question.explanation),
            ]
          ])
        ],
      ),
    );
  }
}
