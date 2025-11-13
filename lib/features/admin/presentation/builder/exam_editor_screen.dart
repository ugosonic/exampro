import 'package:citizentest/features/admin/data/admin_repository.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:citizentest/features/exam/presentation/pdf_viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamEditorScreen extends ConsumerStatefulWidget {
  final int examId;
  const ExamEditorScreen({super.key, required this.examId});
  @override
  ConsumerState<ExamEditorScreen> createState() => _ExamEditorScreenState();
}

class _ExamEditorScreenState extends ConsumerState<ExamEditorScreen> {
  Exam? _exam;
  List<({int id, String body})> _items = [];
  bool _loading = true;
  // controls
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pdfCtrl = TextEditingController();
  bool _published = false;
  bool _readonly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(adminRepositoryProvider);
    final db = ref.read(dbProvider);
    final ex = await (db.select(db.exams)..where((e) => e.id.equals(widget.examId))).getSingle();
    final ro = await repo.getExamReadOnly(widget.examId);
    final rows = await repo.examQuestions(widget.examId);
    setState(() {
      _exam = ex;
      _titleCtrl.text = ex.title;
      _descCtrl.text = ex.description;
      _timeCtrl.text = ex.timeLimitMinutes.toString();
      _passCtrl.text = ex.passPercent.toString();
      _pdfCtrl.text = ex.pdfUrl;
      _published = ex.published;
      _readonly = ro;
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Exam settings', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 8),
                  TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: _timeCtrl, decoration: const InputDecoration(labelText: 'Time limit (minutes)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Pass %'), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: _pdfCtrl, decoration: const InputDecoration(labelText: 'PDF URL (https:// or /path)'))),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Upload PDF',
                      icon: const Icon(Icons.cloud_upload),
                      onPressed: () async {
                        try {
                          final pick = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                          if (pick == null || pick.files.isEmpty) return;
                          final f = pick.files.single;
                          final dio = ref.read(dioProvider);
                          final form = FormData.fromMap({'file': await MultipartFile.fromFile(f.path!, filename: f.name)});
                          final res = await dio.post('/admin/upload/pdf', data: form);
                          final newUrl = (res.data['url'] as String?) ?? '';
                          if (newUrl.isEmpty) throw Exception('Invalid response');
                          setState(() => _pdfCtrl.text = newUrl);
                        } catch (err) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $err')));
                          }
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'View PDF',
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () {
                        final env = ref.read(envLoaderProvider).requireValue;
                        final url = _pdfCtrl.text.trim();
                        if (url.isEmpty) return;
                        final src = url.startsWith('http') ? url : (url.startsWith('/') ? '${env.apiBaseUrl}$url' : url);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerScreen(source: src)));
                      },
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Switch(value: _published, onChanged: (v) => setState(() => _published = v)),
                    const SizedBox(width: 6), const Text('Published'),
                    const SizedBox(width: 18),
                    Switch(value: _readonly, onChanged: (v) => setState(() => _readonly = v)),
                    const SizedBox(width: 6), const Text('Read-only (PDF mode)'),
                  ]),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      onPressed: _saveSettings,
                    ),
                  ),
                  const Divider(height: 24),
                  const Align(alignment: Alignment.centerLeft, child: Text('Reorder or remove questions')),
                ]),
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

  Future<void> _saveSettings() async {
    final repo = ref.read(adminRepositoryProvider);
    final title = _titleCtrl.text.trim().isEmpty ? 'Exam' : _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final time = int.tryParse(_timeCtrl.text.trim()) ?? 0;
    final pass = (int.tryParse(_passCtrl.text.trim()) ?? 60).clamp(0, 100);
    await repo.updateExam(widget.examId,
        title: title,
        description: desc,
        timeLimitMinutes: time,
        passPercent: pass,
        published: _published,
        pdfUrl: _pdfCtrl.text.trim());
    await repo.setExamReadOnly(widget.examId, _readonly);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam saved')));
    }
  }
}
