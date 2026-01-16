import 'dart:convert';

import 'package:exampro/features/admin/utils/import_parser.dart';
import 'package:flutter/material.dart';

class ExamBuilderScreen extends StatefulWidget {
  const ExamBuilderScreen({super.key});

  @override
  State<ExamBuilderScreen> createState() => _ExamBuilderScreenState();
}

class _ExamBuilderScreenState extends State<ExamBuilderScreen> {
  int _step = 0;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool shuffle = true;
  bool negativeMarking = false;
  int timeLimit = 60;
  final List<Map<String, dynamic>> questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Builder')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () => setState(() => _step = (_step + 1).clamp(0, 3)),
        onStepCancel: () => setState(() => _step = (_step - 1).clamp(0, 3)),
        steps: [
          Step(
            title: const Text('Basics'),
            content: Column(children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
            ]),
          ),
          Step(
            title: const Text('Rules'),
            content: Column(children: [
              SwitchListTile(value: shuffle, onChanged: (v) => setState(() => shuffle = v), title: const Text('Shuffle options')),
              SwitchListTile(value: negativeMarking, onChanged: (v) => setState(() => negativeMarking = v), title: const Text('Negative marking')),
              Row(children: [
                const Text('Time limit (mins):'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: timeLimit,
                  items: const [30, 45, 60, 90, 120].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                  onChanged: (v) => setState(() => timeLimit = v ?? 60),
                )
              ])
            ]),
          ),
          Step(
            title: const Text('Questions'),
            content: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FilledButton(onPressed: _importQuestions, child: const Text('Import CSV/JSON')),
              const SizedBox(height: 8),
              Text('Items: ${questions.length}'),
            ]),
          ),
          Step(
            title: const Text('Preview & Publish'),
            content: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Title: ${_title.text}'),
              Text('Questions: ${questions.length}'),
              const SizedBox(height: 8),
              FilledButton(onPressed: () {}, child: const Text('Publish')),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _importQuestions() async {
    // For now, parse a sample JSON payload.
    const sample = '[{"text":"Q1?","options":["A","B"],"answers":[1],"explanation":"Because"}]';
    final list = parseJsonQuestions(jsonDecode(sample));
    setState(() => questions.addAll(list));
  }
}

