import 'package:exampro/app/theme/theme_controller.dart';
import 'package:exampro/common/widgets/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ExamPro'), actions: [
        IconButton(
          tooltip: 'Theme',
          onPressed: () {
            final next = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            ref.read(themeModeProvider.notifier).state = next;
          },
          icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
        )
      ]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _dailyGoal(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _card(context, 'Categories', Icons.category, onTap: () => context.go('/categories'))),
                const SizedBox(width: 12),
                Expanded(child: _card(context, 'Continue', Icons.play_arrow, onTap: () {})),
              ],
            ),
            const SizedBox(height: 12),
            Text('Recent exams', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _examTile(context, 'Biology Mock A', 45),
            _examTile(context, 'Physics Practice', 12),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/delete-account'),
              child: const Text('Delete account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyGoal(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Daily Goal', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('15 mins • Streak: 3 days')
            ]),
          ),
          FilledButton(onPressed: () {}, child: const Text('Start'))
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String label, IconData icon, {VoidCallback? onTap}) => TapScale(
        onTap: onTap,
        child: Card(
          child: SizedBox(
            height: 100,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(height: 8), Text(label)]),
            ),
          ),
        ),
      );

  Widget _examTile(BuildContext context, String title, int mins) => Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text('$mins mins'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );
}
