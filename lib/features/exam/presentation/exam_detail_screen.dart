import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExamDetailScreen extends StatelessWidget {
  final String examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mock Exam $examId', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('#questions: 50   •   Time: 60 mins   •   Pass: 50%'),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'practice', label: Text('Practice')),
                  ButtonSegment(value: 'mock', label: Text('Mock')),
                  ButtonSegment(value: 'adaptive', label: Text('Adaptive')),
                ],
                selected: const {'practice'},
                onSelectionChanged: (s) {},
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/player/$examId'),
                  child: const Text('Start'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

