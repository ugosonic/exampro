import 'package:exampro/features/exam/data/exam_repository.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedQuestionsScreen extends ConsumerWidget {
  const SavedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'guest@local';
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Questions')),
      body: FutureBuilder(
        future: ref.read(examRepositoryProvider).savedQuestions(email),
        builder: (context, snap) {
          final list = snap.data ?? const [];
          if (list.isEmpty) return const Center(child: Text('No saved questions'));
          return LayoutBuilder(builder: (context, c) {
            final width = c.maxWidth;
            final cross = width < 600 ? 2 : 3;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final q = list[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(q.body, maxLines: 4, overflow: TextOverflow.ellipsis)),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.bookmark_remove),
                          onPressed: () async {
                            await ref.read(examRepositoryProvider).toggleSaved(questionId: q.id, userEmail: email);
                            if (context.mounted) {
                              (context as Element).markNeedsBuild();
                            }
                          },
                        ),
                      )
                    ]),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}

