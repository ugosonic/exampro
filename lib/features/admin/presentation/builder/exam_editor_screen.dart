import 'dart:convert';
import 'dart:io' show File;

import 'package:citizentest/core/config/env_loader.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:citizentest/features/admin/data/admin_repository.dart';
import 'package:citizentest/features/admin/utils/import_parser.dart';
import 'package:citizentest/features/exam/data/exam_repository.dart';
import 'package:citizentest/features/exam/presentation/pdf_viewer_screen.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pdfCtrl = TextEditingController();
  bool _published = false;
  bool _readonly = false;

  String _questionFingerprint(String body) =>
      body.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  List<
    ({
      String body,
      String explanation,
      List<({String text, bool correct})> options,
    })
  >
  _normalizeImportedQuestions(List<Map<String, dynamic>> imported) {
    final normalized =
        <
          ({
            String body,
            String explanation,
            List<({String text, bool correct})> options,
          })
        >[];
    for (final m in imported) {
      final body = ((m['body'] as String?) ?? (m['text'] as String? ?? ''))
          .trim();
      final explanation = ((m['explanation'] as String?) ?? '').trim();
      final optionsRaw = (m['options'] as List?) ?? const <dynamic>[];
      final answersRaw = (m['answers'] as List?) ?? const <dynamic>[];
      final answers = answersRaw
          .map((e) => (e is num) ? e.toInt() : int.tryParse('$e'))
          .whereType<int>()
          .toSet();
      final options = <({String text, bool correct})>[];
      for (var i = 0; i < optionsRaw.length; i++) {
        final label = '${optionsRaw[i]}'.trim();
        if (label.isEmpty) continue;
        options.add((text: label, correct: answers.contains(i + 1)));
      }
      if (body.isEmpty ||
          options.length < 2 ||
          !options.any((o) => o.correct)) {
        continue;
      }
      normalized.add((body: body, explanation: explanation, options: options));
    }
    return normalized;
  }

  Future<
    List<
      ({
        String body,
        String explanation,
        List<({String text, bool correct})> options,
      })
    >?
  >
  _resolveImportedDuplicates(
    List<
      ({
        String body,
        String explanation,
        List<({String text, bool correct})> options,
      })
    >
    imported,
  ) async {
    final existing = {
      for (final item in _items) _questionFingerprint(item.body),
    }..remove('');
    final seenImport = <String>{};
    final duplicates = <String>[];
    final unique =
        <
          ({
            String body,
            String explanation,
            List<({String text, bool correct})> options,
          })
        >[];

    for (final q in imported) {
      final fp = _questionFingerprint(q.body);
      final isDuplicate =
          fp.isNotEmpty && (existing.contains(fp) || seenImport.contains(fp));
      if (isDuplicate) {
        if (!duplicates.contains(q.body)) duplicates.add(q.body);
        continue;
      }
      if (fp.isNotEmpty) seenImport.add(fp);
      unique.add(q);
    }

    if (duplicates.isEmpty || !mounted) return imported;

    final decision = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicate Questions Found'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'These questions are duplicates in this exam or in the uploaded file:',
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final text in duplicates)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('- $text'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Skip duplicates and import the rest, or import all as-is?',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('skip'),
            child: const Text('Skip Duplicates'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('all'),
            child: const Text('Import All'),
          ),
        ],
      ),
    );

    if (decision == null) return null;
    if (decision == 'skip') return unique;
    return imported;
  }

  Future<void> _importQuestionsFromFile() async {
    try {
      final pick = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (pick == null || pick.files.isEmpty) return;
      final file = pick.files.single;

      String raw;
      if (file.bytes != null) {
        raw = utf8.decode(file.bytes!);
      } else if (file.path != null && file.path!.isNotEmpty) {
        raw = await File(file.path!).readAsString();
      } else {
        throw Exception('Unable to read selected file');
      }

      final lowerName = file.name.toLowerCase();
      List<Map<String, dynamic>> imported;
      if (lowerName.endsWith('.json')) {
        imported = parseJsonQuestions(jsonDecode(raw));
      } else if (lowerName.endsWith('.csv')) {
        imported = parseCsvQuestions(raw);
      } else {
        try {
          imported = parseJsonQuestions(jsonDecode(raw));
          if (imported.isEmpty) {
            imported = parseCsvQuestions(raw);
          }
        } catch (_) {
          imported = parseCsvQuestions(raw);
        }
      }

      final normalized = _normalizeImportedQuestions(imported);
      if (normalized.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid questions found in selected file.'),
          ),
        );
        return;
      }

      final toImport = await _resolveImportedDuplicates(normalized);
      if (toImport == null || !mounted) return;

      final repo = ref.read(adminRepositoryProvider);
      final added = <({int id, String body})>[];
      final baseOrder = _items.length;
      for (var i = 0; i < toImport.length; i++) {
        final q = toImport[i];
        final qId = await repo.addQuestionWithOptions(
          examId: widget.examId,
          text: q.body.isEmpty ? 'Question' : q.body,
          explanation: q.explanation,
          options: q.options,
          multiple: q.options.where((o) => o.correct).length > 1,
          order: baseOrder + i,
        );
        added.add((id: qId, body: q.body));
      }

      if (!mounted) return;
      setState(() => _items.addAll(added));
      final skipped = normalized.length - toImport.length;
      final msg = skipped > 0
          ? 'Imported ${added.length} questions. Skipped $skipped duplicates.'
          : 'Imported ${added.length} questions.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final examRepo = ref.read(examRepositoryProvider);
      final ex = await examRepo.getExam(widget.examId);
      final results = await Future.wait([
        adminRepo.getExamReadOnly(widget.examId),
        examRepo.questionsForExam(widget.examId),
      ]);
      final ro = results[0] as bool;
      final list = results[1] as List<QuestionWithOptions>;
      if (!mounted) return;
      setState(() {
        _titleCtrl.text = ex?.title ?? '';
        _descCtrl.text = ex?.description ?? '';
        _timeCtrl.text = (ex?.timeLimitMinutes ?? 0).toString();
        _passCtrl.text = (ex?.passPercent ?? 60).toString();
        _pdfCtrl.text = ex?.pdfUrl ?? '';
        _published = ex?.published ?? false;
        _readonly = ro;
        _items = [
          for (final r in list) (id: r.question.id, body: r.question.body),
        ];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load exam: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exam')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 96, top: 8),
              header: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _timeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Time limit (minutes)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _passCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Pass %',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pdfCtrl,
                            decoration: const InputDecoration(
                              labelText: 'PDF URL (https:// or /path)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Upload PDF',
                          icon: const Icon(Icons.cloud_upload),
                          onPressed: () async {
                            try {
                              final pick = await FilePicker.platform.pickFiles(
                                type: FileType.any,
                                withData: true,
                              );
                              if (pick == null || pick.files.isEmpty) return;
                              final f = pick.files.single;
                              if (!f.name.toLowerCase().endsWith('.pdf')) {
                                throw Exception('Please choose a PDF file');
                              }
                              final dio = ref.read(dioProvider);
                              final multipart = f.bytes != null
                                  ? MultipartFile.fromBytes(
                                      f.bytes!,
                                      filename: f.name,
                                    )
                                  : (f.path != null && f.path!.isNotEmpty
                                        ? await MultipartFile.fromFile(
                                            f.path!,
                                            filename: f.name,
                                          )
                                        : throw Exception(
                                            'Unable to read selected PDF file',
                                          ));
                              final form = FormData.fromMap({
                                'file': multipart,
                              });
                              final res = await dio.post(
                                '/admin/upload/pdf',
                                data: form,
                              );
                              final newUrl = (res.data['url'] as String?) ?? '';
                              if (newUrl.isEmpty) {
                                throw Exception('Invalid response');
                              }
                              setState(() => _pdfCtrl.text = newUrl);
                            } catch (err) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Upload failed: $err')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'View PDF',
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () {
                            final env = ref
                                .read(envLoaderProvider)
                                .requireValue;
                            final url = _pdfCtrl.text.trim();
                            if (url.isEmpty) return;
                            final src = url.startsWith('http')
                                ? url
                                : (url.startsWith('/')
                                      ? '${env.apiBaseUrl}$url'
                                      : url);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PdfViewerScreen(source: src),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Switch(
                          value: _published,
                          onChanged: (v) => setState(() => _published = v),
                        ),
                        const SizedBox(width: 6),
                        const Text('Published'),
                        const SizedBox(width: 18),
                        Switch(
                          value: _readonly,
                          onChanged: (v) => setState(() => _readonly = v),
                        ),
                        const SizedBox(width: 6),
                        const Text('Read-only (PDF mode)'),
                      ],
                    ),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Reorder, edit, or remove questions'),
                          ),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('Import CSV/JSON'),
                          onPressed: _importQuestionsFromFile,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              itemBuilder: (_, i) {
                final item = _items[i];
                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(color: Colors.redAccent),
                  onDismissed: (_) async {
                    await ref
                        .read(adminRepositoryProvider)
                        .removeQuestionFromExam(widget.examId, item.id);
                    setState(() => _items.removeAt(i));
                  },
                  child: ListTile(
                    key: ValueKey('tile-${item.id}'),
                    title: Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.drag_handle),
                    onTap: () => _editQuestion(item.id),
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
                await ref
                    .read(adminRepositoryProvider)
                    .reorderExamQuestions(
                      widget.examId,
                      _items.map((e) => e.id).toList(),
                    );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addQuestion() async {
    final data = await _showQuestionDialog(title: 'Add Question');
    if (data == null) return;
    final repo = ref.read(adminRepositoryProvider);
    final qId = await repo.addQuestionWithOptions(
      examId: widget.examId,
      text: data.body.trim().isEmpty ? 'Question' : data.body.trim(),
      explanation: data.explanation.trim(),
      options: data.options,
      multiple: data.options.where((o) => o.correct).length > 1,
      order: _items.length,
    );
    setState(() => _items.add((id: qId, body: data.body.trim())));
  }

  Future<void> _editQuestion(int questionId) async {
    final repo = ref.read(adminRepositoryProvider);
    final current = await repo.questionWithOptions(questionId);
    if (current == null) return;
    final data = await _showQuestionDialog(
      title: 'Edit Question',
      initialBody: current.question.body,
      initialExplanation: current.question.explanation,
      initialOptions: [
        for (final o in current.options) (text: o.label, correct: o.isCorrect),
      ],
    );
    if (data == null) return;
    await repo.updateQuestionAndOptions(
      questionId: questionId,
      body: data.body.trim().isEmpty ? current.question.body : data.body.trim(),
      explanation: data.explanation.trim(),
      options: data.options,
    );
    if (!mounted) return;
    setState(() {
      final idx = _items.indexWhere((e) => e.id == questionId);
      if (idx >= 0) _items[idx] = (id: questionId, body: data.body.trim());
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Question updated')));
  }

  Future<
    ({
      String body,
      String explanation,
      List<({String text, bool correct})> options,
    })?
  >
  _showQuestionDialog({
    required String title,
    String initialBody = '',
    String initialExplanation = '',
    List<({String text, bool correct})>? initialOptions,
  }) async {
    final body = TextEditingController(text: initialBody);
    final explanation = TextEditingController(text: initialExplanation);
    final opts = (initialOptions == null || initialOptions.isEmpty)
        ? List.generate(4, (i) => {'label': '', 'correct': false})
        : [
            for (final o in initialOptions)
              {'label': o.text, 'correct': o.correct},
          ];

    return showDialog<
      ({
        String body,
        String explanation,
        List<({String text, bool correct})> options,
      })
    >(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: body,
                      decoration: const InputDecoration(
                        labelText: 'Question text',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: explanation,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Explanation',
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < opts.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: (opts[i]['label'] as String?) ?? '',
                              onChanged: (v) => opts[i]['label'] = v,
                              decoration: InputDecoration(
                                labelText: 'Option ${i + 1}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: (opts[i]['correct'] as bool?) ?? false,
                            onChanged: (v) =>
                                set(() => opts[i]['correct'] = v ?? false),
                          ),
                          if (opts.length > 2)
                            IconButton(
                              tooltip: 'Remove option',
                              onPressed: () => set(() => opts.removeAt(i)),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                        ],
                      ),
                    TextButton.icon(
                      onPressed: () =>
                          set(() => opts.add({'label': '', 'correct': false})),
                      icon: const Icon(Icons.add),
                      label: const Text('Add option'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final normalized = [
                    for (final o in opts)
                      (
                        text: ((o['label'] as String?) ?? '').trim(),
                        correct: (o['correct'] as bool?) ?? false,
                      ),
                  ].where((o) => o.text.isNotEmpty).toList();

                  if (normalized.length < 2) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Add at least 2 answer options.'),
                      ),
                    );
                    return;
                  }
                  if (!normalized.any((o) => o.correct)) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Mark at least 1 correct answer.'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop((
                    body: body.text,
                    explanation: explanation.text,
                    options: normalized,
                  ));
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    final repo = ref.read(adminRepositoryProvider);
    final title = _titleCtrl.text.trim().isEmpty
        ? 'Exam'
        : _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final time = int.tryParse(_timeCtrl.text.trim()) ?? 0;
    final pass = (int.tryParse(_passCtrl.text.trim()) ?? 60).clamp(0, 100);
    await repo.updateExam(
      widget.examId,
      title: title,
      description: desc,
      timeLimitMinutes: time,
      passPercent: pass,
      published: _published,
      pdfUrl: _pdfCtrl.text.trim(),
    );
    await repo.setExamReadOnly(widget.examId, _readonly);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exam saved')));
  }
}
