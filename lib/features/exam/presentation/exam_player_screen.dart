<<<<<<< HEAD
import 'package:exampro/common/widgets/tap_scale.dart';
import 'package:exampro/core/analytics/analytics.dart';
import 'package:exampro/features/exam/data/attempt_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamPlayerScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamPlayerScreen({super.key, required this.examId});
=======

import 'dart:async';
import 'package:citizentest/common/widgets/tap_scale.dart';
import 'package:citizentest/core/analytics/analytics.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/features/exam/data/exam_repository.dart';
import 'package:citizentest/features/sync/data/sync_repository.dart';
import 'package:citizentest/features/dashboard/data/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';

class ExamPlayerScreen extends ConsumerStatefulWidget {
  final String examId;
  final int? attemptId;
  final String? mode; // 'practice' (default) or 'assignment'
  final int? categoryId; // when practicing entire category
  const ExamPlayerScreen({super.key, required this.examId, this.attemptId, this.mode, this.categoryId});
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

  @override
  ConsumerState<ExamPlayerScreen> createState() => _ExamPlayerScreenState();
}

class _ExamPlayerScreenState extends ConsumerState<ExamPlayerScreen> {
  int index = 0;
<<<<<<< HEAD
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
=======
  int? attemptId;
  late final int examId;
  List<Question> _questions = const [];
  Map<int, List<Choice>> _options = const {};
  final Map<int, Set<int>> _selections = {}; // questionId -> selected option IDs
  final Set<int> _revealed = {}; // questionIds whose explanation is revealed
  Exam? _exam;
  Attempt? _attempt;
  Timer? _ticker;
  Timer? _syncDebounce;
  int _remainingSec = 0;
  bool _autoSubmitted = false;
  bool _isPro = false;
  String _mode = 'practice';
  final Set<int> _skipped = {}; // skipped question IDs
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    ref.read(analyticsProvider).event('exam_start', params: {'examId': widget.examId});
    _startAttempt();
  }

  Future<void> _startAttempt() async {
    final repo = ref.read(attemptRepositoryProvider);
    attemptId = await repo.startAttempt(examId: int.tryParse(widget.examId) ?? 0, mode: 'practice');
=======
    examId = int.tryParse(widget.examId) ?? 0;
    ref.read(analyticsProvider).event('exam_start', params: {'examId': widget.examId});
    _load();
  }  Future<void> _load() async {
    try {
      _mode = (widget.mode ?? 'practice');
      final repo = ref.read(examRepositoryProvider);
      // start or resume attempt
      if (widget.attemptId != null) {
        attemptId = widget.attemptId;
        // jump to next unanswered index
        final answered = await repo.countAnswers(attemptId!);
        setState(() => index = answered);
      } else if (widget.categoryId == null && _mode != 'practice') {
        // Only create attempt for assignment (or exam-bound practice), never for category practice
        final user = ref.read(currentUserProvider);
        final email = user?.email ?? 'guest@local';
        attemptId = await repo.startAttempt(examId: examId, mode: _mode, userEmail: email);
        _queueSync(email);
      }
      // load questions and options
      final list = (widget.categoryId != null)
          ? await repo.questionsForCategory(widget.categoryId!)
          : await repo.questionsForExam(examId);
      if (list.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('No questions available for this exam yet')));
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (widget.categoryId != null) {
              context.go('/categories/${widget.categoryId}');
            } else if (examId != 0) {
              context.go('/exam/$examId');
            } else {
              context.go('/dashboard');
            }
          });
        }
        return;
      }
      // load exam and attempt
      final db = ref.read(dbProvider);
      final exam = await repo.getExam(examId);
      Attempt? att;
      if (attemptId != null) {
        att = await (db.select(db.attempts)..where((t) => t.id.equals(attemptId!))).getSingleOrNull();
      }
      // determine pro
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final row = await (db.select(db.users)..where((u) => u.email.equals(user.email))).getSingleOrNull();
        _isPro = row?.isPro ?? false;
      } else {
        _isPro = false;
      }
      // load previous selections if resuming
      if (attemptId != null && widget.attemptId != null) {
        final saved = await repo.loadSelections(attemptId!);
        _selections.addAll({for (final e in saved.entries) e.key: e.value.toSet()});
      }
      setState(() {
        _questions = [for (final q in list) q.question];
        _options = {for (final q in list) q.question.id: q.options};
        _exam = exam;
        _attempt = att;
      });
      // Practice-all resume prompt
      if (widget.categoryId != null) {
        final user = ref.read(currentUserProvider);
        final email = user?.email ?? 'guest@local';
        final saved = await repo.practiceProgress(categoryId: widget.categoryId!, userEmail: email);
        if (saved > 0 && saved < _questions.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final cont = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Continue practice?'),
                content: Text('You stopped at question ${saved + 1} of ${_questions.length}. Continue or start over?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Start over')),
                  FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Continue')),
                ],
              ),
            );
            if (cont == true) {
              setState(() => index = saved);
            } else {
              await repo.resetPracticeProgress(categoryId: widget.categoryId!, userEmail: email);
              setState(() => index = 0);
            }
          });
        }
      }
      // If current index points to a locked question and user isn't pro, redirect
      _ensureUnlockedIndex();
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load exam: $e')));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.categoryId != null) {
          context.go('/categories/${widget.categoryId}');
        } else if (examId != 0) {
          context.go('/exam/$examId');
        } else {
          context.go('/dashboard');
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _syncDebounce?.cancel();
    super.dispose();
  }

  void _queueSync(String email) {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 1), () async {
      try {
        await ref.read(syncRepositoryProvider).pushUserProgress(email);
      } catch (_) {}
    });
  }

  void _ensureUnlockedIndex() {
    if (_questions.isEmpty) return;
    if (!_isPro && _questions[index].locked) {
      // find next unlocked forward, or back to previous unlocked; if none, route to upgrade
      int? next;
      for (var i = index; i < _questions.length; i++) {
        if (!_questions[i].locked) { next = i; break; }
      }
      next ??= () {
        for (var i = index - 1; i >= 0; i--) {
          if (!_questions[i].locked) return i;
        }
        return null;
      }();
      if (next == null) {
        if (mounted) context.go('/upgrade');
      } else {
        setState(() => index = next!);
      }
    }
  }

  void _startTimer() {
    if (_mode == 'practice') return; // practice is always untimed
    final ex = _exam;
    final att = _attempt;
    if (ex == null || att == null) return;
    final limitSec = (ex.timeLimitMinutes) * 60;
    if (limitSec <= 0) return; // no timer
    final elapsed = DateTime.now().difference(att.startedAt).inSeconds;
    final remaining = limitSec - elapsed;
    if (remaining <= 0) {
      _autoSubmit();
      return;
    }
    setState(() => _remainingSec = remaining);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      if (_remainingSec <= 1) {
        t.cancel();
        await _autoSubmit();
      } else {
        setState(() => _remainingSec--);
      }
    });
  }

  int? _firstSkippedPendingIndex() {
    if (_skipped.isEmpty) return null;
    for (var i = 0; i < _questions.length; i++) {
      if (_skipped.contains(_questions[i].id)) return i;
    }
    return null;
  }

  Future<void> _autoSubmit() async {
    if (_autoSubmitted) return;
    _autoSubmitted = true;
    if (attemptId != null) {
      await ref.read(examRepositoryProvider).submitAttempt(attemptId!);
      if (mounted) context.go('/result/$attemptId');
    } else if (mounted) {
      if (widget.categoryId != null) {
        context.go('/categories/${widget.categoryId}');
      } else {
        Navigator.of(context).pop();
      }
    }
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    if (_questions.isEmpty) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final q = _questions[index];
    final options = _options[q.id]!;
    final correctIds = options.where((o) => o.isCorrect).map((o) => o.id).toSet();
    final selected = _selections[q.id] ?? <int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text('Q ${index + 1}/${_questions.length}'),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              final email = user?.email ?? 'guest@local';
              final q = _questions[index];
              await ref.read(examRepositoryProvider).toggleSaved(questionId: q.id, userEmail: email);
              _queueSync(email);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated saved questions')));
              }
            },
          ),
          if (widget.categoryId == null)
            IconButton(
              tooltip: 'Report',
              icon: const Icon(Icons.flag_outlined),
              onPressed: () async {
                final comment = await _promptComment(context);
                if (comment == null || comment.trim().isEmpty) return;
                final user = ref.read(currentUserProvider);
                final email = user?.email ?? 'guest@local';
                await ref.read(examRepositoryProvider).submitReport(examId: examId, userEmail: email, comment: comment.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent')));
                }
              },
            ),
          if ((_exam?.timeLimitMinutes ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
              child: Text(_formatTime(_remainingSec)),
            ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: _themeGradient(_exam?.themeKey ?? 0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          q.body,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: () {
                                  final w = MediaQuery.of(context).size.width;
                                  final v = (w * 0.06).clamp(18.0, 22.0);
                                  return (v is double) ? v : (v as num).toDouble();
                                }(),
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...options.map((o) => _option(context, o, correctIds.contains(o.id))),
                        if (_mode == 'practice' && _revealed.contains(q.id))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isSelectionCorrect(q, selected, correctIds)
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(q.explanation.isEmpty ? ' ' : q.explanation),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _skipped.add(q.id);
                        if (index < _questions.length - 1) {
                          final i = index + 1;
                          if (!_isPro && _questions[i].locked) {
                            context.go('/upgrade');
                          } else {
                            setState(() => index = i);
                          }
                        } else {
                          final pending = _firstSkippedPendingIndex();
                          if (pending != null) {
                            setState(() => index = pending);
                          }
                        }
                      },
                      child: const Text('Skip'),
                    ),
                    const Spacer(),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: index > 0
                            ? () {
                                final i = index - 1;
                                if (!_isPro && _questions[i].locked) {
                                  context.go('/upgrade');
                                } else {
                                  setState(() => index = i);
                                }
                              }
                            : null,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () async {
                          // Save answer (if any)
                          if (attemptId != null) {
                            final opts = _options[q.id]!;
                            final correct = opts.where((x) => x.isCorrect).map((x) => x.id).toSet();
                            final sel = _selections[q.id] ?? <int>{};
                            final ok = _isSelectionCorrect(q, sel, correct);
                            if (sel.isNotEmpty) {
                              await ref.read(examRepositoryProvider).saveAnswer(
                                    attemptId: attemptId!,
                                    questionId: q.id,
                                    selectedOptionIds: sel.toList(),
                                    points: ok ? 1 : 0,
                                    isCorrect: ok,
                                  );
                              final u = ref.read(currentUserProvider);
                              _queueSync(u?.email ?? 'guest@local');
                              _skipped.remove(q.id);
                              // Ping dashboard pies
                              ref.read(progressTickProvider.notifier).state++;
                            }
                          } else if (widget.categoryId != null) {
                            // Practice-all: save progress to next index if selected
                            final sel = _selections[q.id] ?? <int>{};
                            if (sel.isNotEmpty) {
                              final opts = _options[q.id]!;
                              final correct = opts.where((x) => x.isCorrect).map((x) => x.id).toSet();
                              final ok = _isSelectionCorrect(q, sel, correct);
                              final u = ref.read(currentUserProvider);
                              final email = u?.email ?? 'guest@local';
                              await ref.read(examRepositoryProvider).savePracticeAnswer(
                                    categoryId: widget.categoryId!,
                                    questionId: q.id,
                                    userEmail: email,
                                    isCorrect: ok,
                                  );
                              // Ping dashboard pies
                              ref.read(progressTickProvider.notifier).state++;
                            }
                          }

                          if (_mode == 'practice') {
                            if (!_revealed.contains(q.id)) {
                              setState(() => _revealed.add(q.id));
                              return;
                            }
                          }

                          // Next / Submit or revisit skipped
                          if (index < _questions.length - 1) {
                            final i = index + 1;
                            if (!_isPro && _questions[i].locked) {
                              if (mounted) context.go('/upgrade');
                            } else {
                              setState(() => index = i);
                              if (widget.categoryId != null) {
                                final u = ref.read(currentUserProvider);
                                final email = u?.email ?? 'guest@local';
                                await ref.read(examRepositoryProvider).savePracticeProgress(categoryId: widget.categoryId!, userEmail: email, index: i);
                              }
                            }
                          } else {
                            final pending = _firstSkippedPendingIndex();
                            if (pending != null) {
                              setState(() => index = pending);
                            } else {
                              ref.read(analyticsProvider).event('exam_submit', params: {'examId': widget.examId});
                              final u = ref.read(currentUserProvider);
                              _queueSync(u?.email ?? 'guest@local');
                              if (widget.categoryId != null) {
                                final email = (u?.email ?? 'guest@local');
                                await ref.read(examRepositoryProvider).savePracticeProgress(categoryId: widget.categoryId!, userEmail: email, index: _questions.length);
                              }
                              await _autoSubmit();
                            }
                          }
                        },
                        child: Text(() {
                          if (_mode == 'practice') {
                            return !_revealed.contains(q.id)
                                ? 'Check'
                                : (index < _questions.length - 1 ? 'Next' : (_skipped.isNotEmpty ? 'Review Skipped' : 'Submit'));
                          }
                          return index < _questions.length - 1 ? 'Next' : (_skipped.isNotEmpty ? 'Review Skipped' : 'Submit');
                        }()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, Choice o, bool isCorrect) {
    final q = _questions[index];
    final selected = _selections[q.id] ?? <int>{};
    final isSelected = selected.contains(o.id);
    final showCorrect = (_mode == 'practice') && _revealed.contains(q.id);
    Color? bg;
    Color? border;
    Color iconColor = Theme.of(context).colorScheme.primary;
    if (showCorrect) {
      if (isCorrect) {
        bg = Colors.green.withValues(alpha: 0.12);
        border = Colors.green.withValues(alpha: 0.6);
        iconColor = Colors.green;
      } else if (isSelected) {
        bg = Colors.red.withValues(alpha: 0.10);
        border = Colors.red.withValues(alpha: 0.5);
        iconColor = Colors.red;
      }
    } else {
      if (isSelected) {
        bg = Theme.of(context).colorScheme.primary.withValues(alpha: 0.10);
        border = Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);
        iconColor = Theme.of(context).colorScheme.primary;
      }
    }
    bg ??= Theme.of(context).cardTheme.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TapScale(
        onTap: () async {
          if (_mode == 'practice' && _revealed.contains(q.id)) return; // lock changes after reveal
          setState(() {
            final sel = _selections.putIfAbsent(q.id, () => <int>{});
            if (q.multiple) {
              if (sel.contains(o.id)) {
                sel.remove(o.id);
              } else {
                sel.add(o.id);
              }
            } else {
              sel
                ..clear()
                ..add(o.id);
            }
          });
          if (attemptId != null) {
            final options = _options[q.id]!;
            final correct = options.where((x) => x.isCorrect).map((x) => x.id).toSet();
            final sel = _selections[q.id] ?? <int>{};
            final ok = _isSelectionCorrect(q, sel, correct);
            await ref.read(examRepositoryProvider).saveAnswer(
                  attemptId: attemptId!,
                  questionId: q.id,
                  selectedOptionIds: sel.toList(),
                  points: ok ? 1 : 0,
                  isCorrect: ok,
                );
            final u = ref.read(currentUserProvider);
            _queueSync(u?.email ?? 'guest@local');
            _skipped.remove(q.id);
            ref.read(progressTickProvider.notifier).state++;
          } else if (widget.categoryId != null) {
            final options = _options[q.id]!;
            final correct = options.where((x) => x.isCorrect).map((x) => x.id).toSet();
            final sel = _selections[q.id] ?? <int>{};
            final ok = _isSelectionCorrect(q, sel, correct);
            final u = ref.read(currentUserProvider);
            final email = u?.email ?? 'guest@local';
            await ref.read(examRepositoryProvider).savePracticeAnswer(
                  categoryId: widget.categoryId!,
                  questionId: q.id,
                  userEmail: email,
                  isCorrect: ok,
                );
            await ref.read(examRepositoryProvider).savePracticeProgress(categoryId: widget.categoryId!, userEmail: email, index: index);
            ref.read(progressTickProvider.notifier).state++;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: bg,
              border: Border.all(color: border ?? Colors.black12)),
          child: Row(
            children: [
              Icon(
                q.multiple
                    ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                    : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off),
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(o.label)),
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  bool _isSelectionCorrect(Question q, Set<int> selected, Set<int> correct) {
    if (q.multiple) {
      return selected.isNotEmpty && selected.length == correct.length && selected.containsAll(correct);
    }
    return selected.length == 1 && correct.contains(selected.first);
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '00:00';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Gradient? _themeGradient(int key) {
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

  Future<String?> _promptComment(BuildContext context) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report exam'),
        content: TextField(controller: c, autofocus: true, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe the issue')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(c.text), child: const Text('Send')),
        ],
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      ),
    );
  }
}






<<<<<<< HEAD
=======

>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
