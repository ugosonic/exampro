import 'package:flutter/material.dart';

class AdminQuestion {
  final String id;
  final String category;
  final String exam;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const AdminQuestion({
    required this.id,
    required this.category,
    required this.exam,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  AdminQuestion copyWith({
    String? text,
    List<String>? options,
    int? correctIndex,
    String? explanation,
  }) =>
      AdminQuestion(
        id: id,
        category: category,
        exam: exam,
        text: text ?? this.text,
        options: options ?? this.options,
        correctIndex: correctIndex ?? this.correctIndex,
        explanation: explanation ?? this.explanation,
      );
}

class AdminQuestionBank extends StatefulWidget {
  const AdminQuestionBank({super.key});

  @override
  State<AdminQuestionBank> createState() => _AdminQuestionBankState();
}

class _AdminQuestionBankState extends State<AdminQuestionBank> {
  final List<AdminQuestion> _questions = [
    const AdminQuestion(
      id: 'bio-1',
      category: 'Biology',
      exam: 'Mock A',
      text: 'What does DNA stand for?',
      options: ['Deoxyribonucleic acid', 'Deoxyribose acid', 'Dinucleic acid', 'Deoxyribosome acid'],
      correctIndex: 0,
      explanation: 'DNA stands for deoxyribonucleic acid.',
    ),
    const AdminQuestion(
      id: 'bio-2',
      category: 'Biology',
      exam: 'Mock A',
      text: 'Which cell organelle produces energy?',
      options: ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi apparatus'],
      correctIndex: 1,
      explanation: 'Mitochondria are the powerhouse of the cell.',
    ),
    const AdminQuestion(
      id: 'phys-1',
      category: 'Physics',
      exam: 'Practice 1',
      text: 'What is the unit of force?',
      options: ['Joule', 'Newton', 'Watt', 'Pascal'],
      correctIndex: 1,
      explanation: 'Force is measured in newtons.',
    ),
    const AdminQuestion(
      id: 'phys-2',
      category: 'Physics',
      exam: 'Practice 1',
      text: 'Light travels fastest in which medium?',
      options: ['Water', 'Glass', 'Vacuum', 'Air'],
      correctIndex: 2,
      explanation: 'Light travels fastest in a vacuum.',
    ),
    const AdminQuestion(
      id: 'chem-1',
      category: 'Chemistry',
      exam: 'Mock A',
      text: 'What is the chemical symbol for sodium?',
      options: ['Na', 'So', 'S', 'Sn'],
      correctIndex: 0,
      explanation: 'Na is the symbol for sodium.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions yet.'));
    }

    final grouped = _groupByCategoryExam(_questions);
    final categories = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Question bank', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final category in categories)
          _categorySection(
            context,
            category,
            grouped[category]!,
          ),
      ],
    );
  }

  Map<String, Map<String, List<AdminQuestion>>> _groupByCategoryExam(List<AdminQuestion> questions) {
    final grouped = <String, Map<String, List<AdminQuestion>>>{};
    for (final question in questions) {
      final categoryMap = grouped.putIfAbsent(question.category, () => <String, List<AdminQuestion>>{});
      final examList = categoryMap.putIfAbsent(question.exam, () => <AdminQuestion>[]);
      examList.add(question);
    }
    return grouped;
  }

  Widget _categorySection(
    BuildContext context,
    String category,
    Map<String, List<AdminQuestion>> exams,
  ) {
    final examKeys = exams.keys.toList()..sort();
    return ExpansionTile(
      title: Text(category),
      children: [
        for (final exam in examKeys)
          ExpansionTile(
            title: Text(exam),
            subtitle: Text('${exams[exam]!.length} questions'),
            children: [
              for (final question in exams[exam]!)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(question.text),
                    subtitle: Text('Answer: ${question.options[question.correctIndex]}'),
                    trailing: IconButton(
                      tooltip: 'Edit question',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editQuestion(question),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _editQuestion(AdminQuestion question) async {
    final updated = await _showEditDialog(question);
    if (updated == null) return;
    final index = _questions.indexWhere((q) => q.id == updated.id);
    if (index == -1) return;
    setState(() => _questions[index] = updated);
  }

  Future<AdminQuestion?> _showEditDialog(AdminQuestion question) async {
    final theme = Theme.of(context);
    final textController = TextEditingController(text: question.text);
    final optionsController = TextEditingController(text: question.options.join('\n'));
    final correctController = TextEditingController(text: '${question.correctIndex + 1}');
    final explanationController = TextEditingController(text: question.explanation);
    String? error;

    return showDialog<AdminQuestion>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit question'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Question text'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Options (one per line)',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: correctController,
                  decoration: const InputDecoration(labelText: 'Correct option number'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: explanationController,
                  decoration: const InputDecoration(labelText: 'Explanation'),
                  maxLines: 3,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final text = textController.text.trim();
                final options = optionsController.text
                    .split('\n')
                    .map((line) => line.trim())
                    .where((line) => line.isNotEmpty)
                    .toList();
                final correct = int.tryParse(correctController.text.trim());
                if (text.isEmpty) {
                  setState(() => error = 'Question text is required.');
                  return;
                }
                if (options.length < 2) {
                  setState(() => error = 'Add at least two options.');
                  return;
                }
                if (correct == null || correct < 1 || correct > options.length) {
                  setState(() => error = 'Correct option must be between 1 and ${options.length}.');
                  return;
                }
                Navigator.pop(
                  context,
                  question.copyWith(
                    text: text,
                    options: options,
                    correctIndex: correct - 1,
                    explanation: explanationController.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
