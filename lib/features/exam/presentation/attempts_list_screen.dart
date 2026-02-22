import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/core/text/text_sanitizer.dart';

class AttemptsListScreen extends ConsumerStatefulWidget {
  const AttemptsListScreen({super.key});
  @override
  ConsumerState<AttemptsListScreen> createState() => _AttemptsListScreenState();
}

class _AttemptsListScreenState extends ConsumerState<AttemptsListScreen> {
  final _controller = ScrollController();
  final _items = <Attempt>[];
  bool _loading = false;
  int _page = 0;
  final int _size = 20;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _controller.addListener(() {
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 200 &&
          !_loading) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    final db = ref.read(dbProvider);
    final user = ref.read(currentUserProvider);
    final email = user?.email ?? 'guest@local';
    final more =
        await (db.select(db.attempts)
              ..where((t) => t.userEmail.equals(email))
              ..orderBy([(t) => drift.OrderingTerm.desc(t.startedAt)])
              ..limit(_size, offset: _page * _size))
            .get();
    setState(() {
      _page++;
      _items.addAll(more);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attempts')),
      body: ListView.builder(
        controller: _controller,
        itemCount: _items.length + 1,
        itemBuilder: (context, i) {
          if (i == _items.length) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink(),
            );
          }
          final a = _items[i];
          return Card(
            child: ListTile(
              leading: Icon(
                a.endedAt == null ? Icons.play_arrow : Icons.check,
                color: a.endedAt == null ? Colors.orange : Colors.green,
              ),
              title: Text(
                sanitizeDisplayText(
                  'Exam #${a.examId} - ${a.endedAt == null ? 'In progress' : 'Score ${a.scorePercent}%'}',
                ),
              ),
              subtitle: Text('${a.startedAt.toLocal()}'.split('.').first),
              onTap: () {
                if (a.endedAt == null) {
                  context.go('/player/${a.examId}?aid=${a.id}');
                } else {
                  context.go('/result/${a.id}');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
