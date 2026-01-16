import 'package:exampro/common/widgets/tap_scale.dart';
import 'package:exampro/features/catalog/data/catalog_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
          child: catsAsync.when(
        data: (cats) => RefreshIndicator(
          onRefresh: () async => ref.refresh(categoriesProvider.future),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final c = cats[i];
              final icon = [Icons.biotech, Icons.science, Icons.bubble_chart, Icons.functions][i % 4];
              return TapScale(
                onTap: () {},
                child: Card(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(icon, size: 28),
                    const SizedBox(height: 8),
                    Text(c.name),
                  ]),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      )),
    );
  }
}
