import 'package:exampro/features/admin/data/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamEditorScreen extends ConsumerStatefulWidget {
  final int examId;
  const ExamEditorScreen({super.key, required this.examId});
  @override
  ConsumerState<ExamEditorScreen> createState() => _ExamEditorScreenState();
}

class _ExamEditorScreenState extends ConsumerState<ExamEditorScreen> {
  List<({int id, String body})> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(adminRepositoryProvider);
    final rows = await repo.examQuestions(widget.examId);
    setState(() {
      _items = [for (final r in rows) (id: r.question.id, body: r.question.body)];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exam')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Align(alignment: Alignment.centerLeft, child: Text('Reorder or remove questions')),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Dismissible(
                      key: ValueKey(item.id),
                      background: Container(color: Colors.redAccent),
                      onDismissed: (_) async {
                        await ref.read(adminRepositoryProvider).removeQuestionFromExam(widget.examId, item.id);
                        setState(() => _items.removeAt(i));
                      },
                      child: ListTile(
                        key: ValueKey('tile-${item.id}'),
                        title: Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.drag_handle),
                        onTap: () async {
                          // For brevity: navigate to builder to add new questions; editing existing in-place would reuse dialog
                        },
                      ),
                    );
                  },
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) async {
                    final idx = newIndex > oldIndex ? newIndex - 1 : newIndex;
                    setState(() {
                      final it = _items.removeAt(oldIndex);
                      _items.insert(idx, it);
                    });
                    await ref.read(adminRepositoryProvider).reorderExamQuestions(widget.examId, _items.map((e) => e.id).toList());
                  },
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addQuestion() async {
    final body = TextEditingController();
    final opts = List.generate(4, (i) => {'label': '', 'correct': false});
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        return AlertDialog(
          title: const Text('Add Question'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(controller: body, decoration: const InputDecoration(labelText: 'Question text')),
                const SizedBox(height: 8),
                for (var i = 0; i < opts.length; i++)
                  Row(children: [
                    Expanded(child: TextField(onChanged: (v) => opts[i]['label'] = v, decoration: InputDecoration(labelText: 'Option ${i + 1}'))),
                    const SizedBox(width: 8),
                    Checkbox(value: (opts[i]['correct'] as bool?) ?? false, onChanged: (v) => set(() => opts[i]['correct'] = v ?? false)),
                  ]),
                TextButton.icon(onPressed: () => set(() => opts.add({'label': '', 'correct': false})), icon: const Icon(Icons.add), label: const Text('Add option')),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
          ],
        );
      }),
    );
    if (ok == true) {
      final repo = ref.read(adminRepositoryProvider);
      final options = [for (final o in opts) (text: (o['label'] as String?) ?? '', correct: (o['correct'] as bool?) ?? false)];
      final qId = await repo.addQuestionWithOptions(examId: widget.examId, text: body.text.trim().isEmpty ? 'Question' : body.text.trim(), options: options, order: _items.length);
      setState(() => _items.add((id: qId, body: body.text.trim())));
    }
  }
}
