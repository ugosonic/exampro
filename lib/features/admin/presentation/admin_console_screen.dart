import 'package:exampro/features/admin/presentation/builder/exam_builder_screen.dart';
import 'package:exampro/features/admin/presentation/questions/admin_question_bank.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminConsoleScreen extends ConsumerStatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  ConsumerState<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends ConsumerState<AdminConsoleScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Subcats'),
            Tab(text: 'Exams'),
            Tab(text: 'Questions'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: Column(children: [
        if (user == null || user.role != 'admin')
          Container(
            width: double.infinity,
            color: Colors.amber.withOpacity(0.2),
            padding: const EdgeInsets.all(8),
            child: const Text('Admins only — limited view'),
          ),
        Expanded(
          child: TabBarView(
        controller: _tabController,
        children: [
          const _Stub('Manage categories with reorder'),
          const _Stub('Subcategory CRUD'),
          Center(child: FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamBuilderScreen())), child: const Text('Open Builder'))),
          const AdminQuestionBank(),
          const _Stub('Attempts, avg score, difficulty'),
        ],
          ),
        ),
      ]),
    );
  }
}

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}
