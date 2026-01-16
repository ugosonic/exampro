import 'package:exampro/common/widgets/tap_scale.dart';
import 'package:exampro/core/analytics/analytics.dart';
import 'package:exampro/features/exam/data/attempt_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamPlayerScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamPlayerScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamPlayerScreen> createState() => _ExamPlayerScreenState();
}

class _ExamPlayerScreenState extends ConsumerState<ExamPlayerScreen> {
  int index = 0;
  int? selected;
  int? attemptId;
  final questions = const [
    (
      'Which gas is most abundant in the Earth\'s atmosphere?',
      ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Argon'],
      1,
      'Nitrogen makes up ~78% of Earth\'s atmosphere.'
    ),
    (
      'Which organ pumps blood throughout the body?',
      ['Lungs', 'Liver', 'Heart', 'Kidneys'],
      2,
      'The heart pumps blood via rhythmic contractions.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).event('exam_start', params: {'examId': widget.examId});
    _startAttempt();
  }

  Future<void> _startAttempt() async {
    final repo = ref.read(attemptRepositoryProvider);
    attemptId = await repo.startAttempt(examId: int.tryParse(widget.examId) ?? 0, mode: 'practice');
  }

  @override
  Widget build(BuildContext context) {
    final (text, options, correct, explanation) = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Q ${index + 1}/${questions.length}'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.flag_outlined), tooltip: 'Flag for review')],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(text, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...List.generate(options.length, (i) => _option(context, options[i], i, correct)),
              const Spacer(),
              if (selected != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (selected == correct) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(explanation),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: index > 0 ? () => setState(() => index--) : null, child: const Text('Back')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (index < questions.length - 1) {
                          setState(() {
                            index++;
                            selected = null;
                          });
                        } else {
                          ref.read(analyticsProvider).event('exam_submit', params: {'examId': widget.examId});
                          if (attemptId != null) {
                            await ref.read(attemptRepositoryProvider).submitAttempt(attemptId!);
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(index < questions.length - 1 ? 'Next' : 'Submit'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, String label, int i, int correct) {
    final isSelected = selected == i;
    final isCorrect = i == correct;
    final color = isSelected
        ? (isCorrect ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.12))
        : Theme.of(context).cardTheme.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TapScale(
        onTap: () async {
          setState(() => selected = i);
          if (attemptId != null) {
            await ref.read(attemptRepositoryProvider).saveAnswer(
                  attemptId: attemptId!,
                  questionId: index + 1,
                  selected: [i],
                );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color, border: Border.all(color: Colors.black12)),
          child: Row(
            children: [
              Icon(isSelected ? (isCorrect ? Icons.check_circle : Icons.cancel) : Icons.circle_outlined,
                  color: isSelected ? (isCorrect ? Colors.green : Colors.red) : Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}






