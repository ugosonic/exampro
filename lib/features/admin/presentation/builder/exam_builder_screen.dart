import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;

import 'package:exampro/features/admin/data/admin_repository.dart';
import 'package:exampro/features/admin/utils/import_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamBuilderScreen extends ConsumerStatefulWidget {
  const ExamBuilderScreen({super.key});

  @override
  ConsumerState<ExamBuilderScreen> createState() => _ExamBuilderScreenState();
}

class _ExamBuilderScreenState extends ConsumerState<ExamBuilderScreen> {
  int _step = 0;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool shuffle = true;
  bool negativeMarking = false;
  int timeLimit = 60;
  int passPercent = 60;
  int themeKey = 0; // 0 = None, 1..5 = gradients
  final List<Map<String, dynamic>> questions = [];
  int? categoryId;
  int? subcategoryId;

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
              const SizedBox(height: 12),
              _CategoryPickers(
                onSelected: (cat, sub) async {
                  setState(() {
                    categoryId = cat;
                    subcategoryId = sub;
                  });
                  if (cat != null && mounted) {
                    final repo = ref.read(adminRepositoryProvider);
                    final c = await repo.getCategory(cat);
                    if (c != null && mounted) setState(() => passPercent = c.passPercent);
                  }
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Theme', style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final t in [0, 1, 2, 3, 4, 5])
                  _ThemeChip(
                    label: _themeName(t),
                    gradient: _themeGradient(context, t),
                    selected: themeKey == t,
                    onTap: () => setState(() => themeKey = t),
                  ),
              ])
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
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Pass mark (%):'),
                const SizedBox(width: 12),
                SizedBox(
                  width: 96,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '60'),
                    controller: TextEditingController(text: passPercent.toString()),
                    onChanged: (v) => passPercent = int.tryParse(v) ?? 60,
                  ),
                ),
              ])
            ]),
          ),
          Step(
            title: const Text('Questions'),
            content: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: _addQuestionDialog,
                    label: const Text('Add Question'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_upload),
                    onPressed: _importQuestions,
                    label: const Text('Import CSV/JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    onPressed: _pickCsvFile,
                    label: const Text('Upload CSV File'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              _CsvFormatInfo(),
              const SizedBox(height: 8),
              Text('Items: ${questions.length}'),
              const SizedBox(height: 8),
              ...List.generate(questions.length, (i) => _questionTile(i)),
            ]),
          ),
          Step(
            title: const Text('Preview & Publish'),
            content: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Title: ${_title.text}'),
              Text('Questions: ${questions.length}'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _saveExam(published: false),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _saveExam(published: true),
                    child: const Text('Publish'),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

Widget _questionTileBuilder(int index, Map<String, dynamic> q, VoidCallback onEdit, VoidCallback onDelete) {
  final opts = (q['options'] as List).cast<Map>();
  final correctCount = opts.where((o) => (o['correct'] as bool?) ?? false).length;
  return Card(
    child: ListTile(
      title: Text(((q['body'] as String?) ?? '').isNotEmpty ? q['body'] : 'Untitled question'),
      subtitle: Text('${opts.length} options • $correctCount correct'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      ]),
    ),
  );
}

  Widget _questionTile(int i) {
    return _questionTileBuilder(i, questions[i], () => _editQuestionDialog(i), () => setState(() => questions.removeAt(i)));
  }

  Future<void> _addQuestionDialog() async {
    await _openQuestionDialog();
  }

  Future<void> _editQuestionDialog(int index) async {
    await _openQuestionDialog(existing: questions[index], onSave: (map) => setState(() => questions[index] = map));
  }

  Future<void> _openQuestionDialog({Map<String, dynamic>? existing, void Function(Map<String, dynamic>)? onSave}) async {
    final body = TextEditingController(text: existing?['body'] as String? ?? '');
    final explanation = TextEditingController(text: existing?['explanation'] as String? ?? '');
    bool multiple = existing?['multiple'] as bool? ?? false;
    final opts = <Map<String, dynamic>>[...((existing?['options'] as List?)?.cast<Map<String, dynamic>>() ?? [
      {'label': '', 'correct': false},
      {'label': '', 'correct': false},
      {'label': '', 'correct': false},
      {'label': '', 'correct': false},
    ])];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Question' : 'Edit Question'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextField(controller: body, maxLines: 3, decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                SwitchListTile(value: multiple, onChanged: (v) => set(() => multiple = v), title: const Text('Multiple correct answers')),
                const SizedBox(height: 4),
                const Text('Options'),
                const SizedBox(height: 8),
                for (var i = 0; i < opts.length; i++) ...[
                  Row(children: [
                    Expanded(child: TextField(
                      controller: TextEditingController(text: (opts[i]['label'] as String?) ?? ''),
                      onChanged: (v) => opts[i]['label'] = v,
                      decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                    )),
                    const SizedBox(width: 8),
                    Checkbox(value: (opts[i]['correct'] as bool?) ?? false, onChanged: (v) => set(() => opts[i]['correct'] = v ?? false)),
                    IconButton(onPressed: () => set(() => opts.removeAt(i)), icon: const Icon(Icons.close)),
                  ]),
                ],
                TextButton.icon(onPressed: () => set(() => opts.add({'label': '', 'correct': false})), icon: const Icon(Icons.add), label: const Text('Add option')),
                const SizedBox(height: 12),
                TextField(controller: explanation, maxLines: 3, decoration: const InputDecoration(labelText: 'Explanation', border: OutlineInputBorder())),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(onPressed: () {
              final map = {
                'body': body.text.trim(),
                'explanation': explanation.text.trim(),
                'multiple': multiple,
                'options': opts,
              };
              if (onSave != null) {
                onSave(map);
              } else {
                setState(() => questions.add(map));
              }
              Navigator.of(ctx).pop();
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }

// _CsvFormatInfo moved to top-level at the bottom of this file
  Future<void> _importQuestions() async {
    // Let user paste CSV or JSON in a dialog
    final controller = TextEditingController();
    final format = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Questions'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Paste CSV or JSON array:')),
              const SizedBox(height: 8),
              TextField(controller: controller, minLines: 6, maxLines: 14, decoration: const InputDecoration(border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop('csv'), child: const Text('Import CSV')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop('json'), child: const Text('Import JSON')),
        ],
      ),
    );
    if (!mounted || format == null) return;
    final raw = controller.text;
    List<Map<String, dynamic>> imported;
    try {
      if (format == 'csv') {
        imported = parseCsvQuestions(raw);
      } else {
        imported = parseJsonQuestions(jsonDecode(raw));
      }
      // Normalize into local builder shape
      final normalized = imported.map((m) {
        final options = (m['options'] as List).cast<String>();
        final answers = (m['answers'] as List).cast<int>();
        final multiple = (m['multiple'] as bool?) ?? (answers.length > 1);
        return <String, dynamic>{
          'body': (m['body'] as String?) ?? (m['text'] as String? ?? ''),
          'explanation': (m['explanation'] as String?) ?? '',
          'multiple': multiple,
          'options': [
            for (var i = 0; i < options.length; i++) {'label': options[i], 'correct': answers.contains(i + 1)}
          ],
        };
      }).toList();
      setState(() => questions.addAll(normalized));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import: $e')));
    }
  }

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      String contents;
      if (file.bytes != null) {
        contents = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        contents = await File(file.path!).readAsString();
      } else {
        throw Exception('Unable to read selected file');
      }
      final imported = parseCsvQuestions(contents);
      final normalized = imported.map((m) {
        final options = (m['options'] as List).cast<String>();
        final answers = (m['answers'] as List).cast<int>();
        final multiple = (m['multiple'] as bool?) ?? (answers.length > 1);
        return <String, dynamic>{
          'body': (m['body'] as String?) ?? (m['text'] as String? ?? ''),
          'explanation': (m['explanation'] as String?) ?? '',
          'multiple': multiple,
          'options': [
            for (var i = 0; i < options.length; i++) {'label': options[i], 'correct': answers.contains(i + 1)}
          ],
        };
      }).toList();
      if (mounted) setState(() => questions.addAll(normalized));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV imported successfully')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import CSV: $e')));
    }
  }

  Future<void> _saveExam({required bool published}) async {
    final repo = ref.read(adminRepositoryProvider);
    if ((_title.text).isEmpty || categoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please enter title and pick category')));
      }
      return;
    }
    final examId = await repo.createExam(
      title: _title.text,
      description: _desc.text,
      categoryId: categoryId!,
      subcategoryId: subcategoryId,
      timeLimitMinutes: timeLimit,
      passPercent: passPercent,
      shuffleOptions: shuffle,
      negativeMarking: negativeMarking,
      published: published,
      themeKey: themeKey,
    );
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final opts = (q['options'] as List).cast<Map>();
      await repo.addQuestionWithOptions(
        examId: examId,
        text: (q['body'] as String?)?.trim().isNotEmpty == true ? q['body'] : 'Question ${i + 1}',
        explanation: (q['explanation'] as String?) ?? '',
        options: [
          for (final o in opts) (text: (o['label'] as String?) ?? '', correct: (o['correct'] as bool?) ?? false)
        ],
        points: 1,
        order: i,
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(published ? 'Exam published' : 'Draft saved')));
      Navigator.of(context).pop();
    }
  }
}

class _CategoryPickers extends ConsumerStatefulWidget {
  final void Function(int? categoryId, int? subId) onSelected;
  const _CategoryPickers({required this.onSelected});
  @override
  ConsumerState<_CategoryPickers> createState() => _CategoryPickersState();
}

class _CategoryPickersState extends ConsumerState<_CategoryPickers> {
  int? categoryId;
  int? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(adminRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
          stream: repo.watchCategories(),
          builder: (context, snap) {
            final cats = snap.data ?? const [];
            return DropdownButton<int>(
              hint: const Text('Category'),
              value: categoryId,
              items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name))],
              onChanged: (v) {
                setState(() {
                  categoryId = v;
                  subcategoryId = null;
                });
                widget.onSelected(categoryId, subcategoryId);
              },
            );
          },
        ),
        if (categoryId != null)
          StreamBuilder(
            stream: repo.watchSubcategories(categoryId!),
            builder: (context, snap) {
              final subs = snap.data ?? const [];
              return DropdownButton<int>(
                hint: const Text('Subcategory (optional)'),
                value: subcategoryId,
                items: [for (final s in subs) DropdownMenuItem(value: s.id, child: Text(s.name))],
                onChanged: (v) {
                  setState(() => subcategoryId = v);
                  widget.onSelected(categoryId, subcategoryId);
                },
              );
            },
          )
      ],
    );
  }
}


class _CsvFormatInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sample = 'body,option1,option2,option3,option4,answers,explanation,multiple\n'
        'What is 2+2?,2,3,4,5,3,The sum of 2 and 2 is 4,false\n'
        'Select even numbers,1,2,3,4,2|4,Even numbers are divisible by 2,true\n';
    return ExpansionTile(
      title: const Text('CSV format'),
      subtitle: const Text('Tap to see columns and examples'),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Columns: body, option1..N, answers, explanation, multiple (optional)'),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.surface,
          child: Text(sample),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final Gradient? gradient;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeChip({required this.label, required this.gradient, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 110,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: gradient,
        color: gradient == null ? Theme.of(context).colorScheme.surfaceVariant : null,
        border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.black12),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: child);
  }
}

String _themeName(int key) => switch (key) { 0 => 'None', 1 => 'Sunrise', 2 => 'Ocean', 3 => 'Forest', 4 => 'Lavender', 5 => 'Sunset', _ => 'None' };

Gradient? _themeGradient(BuildContext context, int key) {
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

