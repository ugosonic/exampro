import 'package:exampro/features/admin/presentation/builder/exam_builder_screen.dart';
import 'package:exampro/features/admin/presentation/builder/exam_editor_screen.dart';
import 'package:exampro/features/admin/data/admin_repository.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/core/db/app_database.dart';
import 'package:exampro/features/admin/data/email_api.dart';
import 'package:exampro/core/config/env_loader.dart';
import 'package:exampro/features/payments/presentation/checkout_webview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:exampro/core/network/dio_client.dart';
import 'package:exampro/features/exam/presentation/pdf_viewer_screen.dart';
import 'package:exampro/features/sync/data/sync_repository.dart';
import 'package:exampro/features/sync/data/pg_content_service.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart' show Image; // for Image.network fallback

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
    _tabController = TabController(length: 7, vsync: this);
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
      appBar: AppBar(title: const Text('Admin Console')),
      body: Column(children: [
        if (user == null || user.role != 'admin')
          Container(
            width: double.infinity,
            color: Colors.amber.withOpacity(0.2),
            padding: const EdgeInsets.all(8),
            child: const Text('Admins only â€” limited view'),
          ),
        _AdminCardsBar(controller: _tabController),
        Expanded(
          child: TabBarView(
        controller: _tabController,
        children: [
          _CategoriesTab(),
          _SubcategoriesTab(),
          _ExamsTab(),
          _QuestionsTab(),
          _UsersTab(),
          _ReportsTab(),
          _PaymentsTab(),
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

class _CategoriesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(adminRepositoryProvider);
    return StreamBuilder(
      stream: repo.watchCategories(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final c = items[i];
                  return ListTile(
                    leading: c.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: _SquareThumb(src: c.imageUrl),
                          )
                        : const Icon(Icons.category),
                    title: Text(c.name),
                    subtitle: Text('Pass: ${c.passPercent}%'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Switch(
                        value: c.locked,
                        onChanged: (v) => repo.setCategoryLocked(c.id, v),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final updated = await _editCategoryDialog(context, ref, c);
                          if (updated) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category updated')));
                          }
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete category?'),
                              content: const Text('This will remove the category.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await repo.deleteCategory(c.id);
                          }
                        },
                      ),
                    ]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    onPressed: () async {
                      final data = await _promptCategory(context);
                      if (data != null) {
                        await repo.createCategory(data.name, imageUrl: data.imageUrl);
                      }
                    },
                  ),
                ),
              ]),
            )
          ],
        );
      },
    );
  }
}

class _SubcategoriesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SubcategoriesTab> createState() => _SubcategoriesTabState();
}

class _SubcategoriesTabState extends ConsumerState<_SubcategoriesTab> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(adminRepositoryProvider);
    return StreamBuilder(
      stream: repo.watchCategories(),
      builder: (context, catsSnap) {
        final cats = catsSnap.data ?? const [];
        selected ??= cats.isNotEmpty ? cats.first.id : null;
        return Column(children: [
          if (cats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButton<int>(
                value: selected,
                items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name))],
                onChanged: (v) => setState(() => selected = v),
              ),
            ),
          if (selected == null)
            const Expanded(child: Center(child: Text('Create a category first')))
          else
            Expanded(
              child: StreamBuilder(
                stream: repo.watchSubcategories(selected!),
                builder: (context, snap) {
                  final subs = snap.data ?? const [];
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: subs.length,
                        itemBuilder: (_, i) {
                          final s = subs[i];
                          return ListTile(
                            title: Text(s.name),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              Switch(
                                value: s.locked,
                                onChanged: (v) => repo.updateSubcategory(s.id, locked: v),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final data = await _promptSubcategory(context);
                                  if (data != null) {
                                    await repo.updateSubcategory(s.id, name: data.name, imageUrl: data.imageUrl);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete subcategory?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await repo.deleteSubcategory(s.id);
                                  }
                                },
                              ),
                            ]),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add Subcategory'),
                            onPressed: () async {
                              final data = await _promptSubcategory(context);
                              if (data != null && (data.name).isNotEmpty) {
                                await repo.createSubcategory(selected!, data.name, imageUrl: data.imageUrl);
                              }
                            },
                          ),
                        ),
                      ]),
                    )
                  ]);
                },
              ),
            )
        ]);
      },
    );
  }
}

Future<String?> _promptText(BuildContext context, String label) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(label),
      content: TextField(controller: c, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(c.text), child: const Text('Save')),
      ],
    ),
  );
}

Future<bool> _editCategoryDialog(BuildContext context, WidgetRef ref, Category c) async {
  final nameCtrl = TextEditingController(text: c.name);
  final passCtrl = TextEditingController(text: c.passPercent.toString());
  final imageCtrl = TextEditingController(text: c.imageUrl);
  String imageUrl = c.imageUrl;
  final repo = ref.read(adminRepositoryProvider);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Category'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Pass %'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image URL (https://...)')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(imageUrl.isEmpty ? 'Or pick a local image' : imageUrl, maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(
                icon: const Icon(Icons.image),
                tooltip: 'Pick image',
                onPressed: () async {
                  final picked = await _pickImage();
                  if (picked != null) {
                    imageUrl = picked;
                    // ignore: use_build_context_synchronously
                    (ctx as Element).markNeedsBuild();
                  }
                },
              )
            ])
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
      ],
    ),
  );
  if (ok == true) {
    final parsed = int.tryParse(passCtrl.text.trim());
    final pass = parsed == null ? c.passPercent : parsed.clamp(0, 100);
    final finalUrl = imageCtrl.text.trim().isNotEmpty ? imageCtrl.text.trim() : imageUrl;
    await repo.updateCategory(c.id, name: nameCtrl.text.trim(), passPercent: pass, imageUrl: finalUrl);
    return true;
  }
  return false;
}

Future<({String name, String imageUrl})?> _promptCategory(BuildContext context) async {
  final nameCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  String imageUrl = '';
  final result = await showDialog<({String name, String imageUrl})?>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Category'),
      content: SizedBox(
        width: 380,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image URL (https://...)')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text(imageUrl.isEmpty ? 'Or pick a local image' : imageUrl, maxLines: 1, overflow: TextOverflow.ellipsis)),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () async {
                final picked = await _pickImage();
                if (picked != null) {
                  imageUrl = picked;
                  // ignore: use_build_context_synchronously
                  (ctx as Element).markNeedsBuild();
                }
              },
            )
          ])
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final url = imageCtrl.text.trim().isNotEmpty ? imageCtrl.text.trim() : imageUrl;
            if (nameCtrl.text.trim().isEmpty || url.isEmpty) return;
            Navigator.of(ctx).pop((name: nameCtrl.text.trim(), imageUrl: url));
          },
          child: const Text('Create'),
        )
      ],
    ),
  );
  return result;
}

Future<({String name, String imageUrl})?> _promptSubcategory(BuildContext context) async {
  final nameCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  String imageUrl = '';
  final result = await showDialog<({String name, String imageUrl})?>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Subcategory'),
      content: SizedBox(
        width: 380,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image URL (https://...) - optional')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text(imageUrl.isEmpty ? 'Or pick a local image' : imageUrl, maxLines: 1, overflow: TextOverflow.ellipsis)),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () async {
                final picked = await _pickImage();
                if (picked != null) {
                  imageUrl = picked;
                  // ignore: use_build_context_synchronously
                  (ctx as Element).markNeedsBuild();
                }
              },
            )
          ])
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final url = imageCtrl.text.trim().isNotEmpty ? imageCtrl.text.trim() : imageUrl;
            Navigator.of(ctx).pop((name: nameCtrl.text.trim(), imageUrl: url));
          },
          child: const Text('Create'),
        )
      ],
    ),
  );
  return result;
}

Future<String?> _pickImage() async {
  try {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    return f.path ?? '';
  } catch (_) {
    return null;
  }
}

class _AdminCardsBar extends StatelessWidget {
  final TabController controller;
  const _AdminCardsBar({required this.controller});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Categories', Icons.category),
      ('Subcategories', Icons.layers),
      ('Exams', Icons.fact_check),
      ('Questions', Icons.question_answer),
      ('Users', Icons.people_alt),
      ('Reports', Icons.report_problem),
      ('Payments', Icons.payment),
    ];
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final selected = controller.index == i;
          return InkWell(
            onTap: () => controller.index = i,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Theme.of(context).cardColor,
                border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.black12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(items[i].$2),
                const SizedBox(height: 8),
                Text(items[i].$1, textAlign: TextAlign.center),
              ]),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _SquareThumb extends StatelessWidget {
  final String src;
  const _SquareThumb({required this.src});
  @override
  Widget build(BuildContext context) {
    final isHttp = src.startsWith('http://') || src.startsWith('https://');
    final w = 40.0, h = 40.0;
    if (isHttp) {
      return Image.network(src, width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(w, h));
    }
    final f = File(src);
    if (!f.existsSync()) return _fallback(w, h);
    return Image.file(f, width: w, height: h, fit: BoxFit.cover);
  }

  Widget _fallback(double w, double h) => Container(width: w, height: h, color: Colors.black26, child: const Icon(Icons.image_not_supported, size: 16));
}


class _ExamsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(adminRepositoryProvider);
    return Column(children: [
      Expanded(
        child: StreamBuilder(
          stream: repo.watchExamsLocalized(),
          builder: (context, snap) {
            final list = snap.data ?? const [];
            if (list.isEmpty) return const Center(child: Text('No exams yet'));
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = list[i];
                return ListTile(
                  title: Text(e.title.isEmpty ? 'Untitled' : e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${e.questionCount} questions · ${e.published ? 'Published' : 'Draft'}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Wrap(spacing: 8, children: [
                    
                    
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExamEditorScreen(examId: e.id))),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete exam?'),
                            content: const Text('This will delete attempts and related data.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (ok == true) await repo.deleteExam(e.id);
                      },
                    ),
                    
                  ]),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExamEditorScreen(examId: e.id))),
                );
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Exam'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamBuilderScreen())),
          ),
        ),
      )
    ]);
  }
}

class _UsersTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  final Set<int> _selected = {};
  int _template = 1;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(adminRepositoryProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          DropdownButton<int>(
            value: _template,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Template 1: Welcome')),
              DropdownMenuItem(value: 2, child: Text('Template 2: Update')),
            ],
            onChanged: (v) => setState(() => _template = v ?? 1),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Send Email'),
            onPressed: _selected.isEmpty ? null : () => _sendEmails(context),
          ),
          OutlinedButton(
            onPressed: () => setState(() => _selected.clear()),
            child: const Text('Clear Selection'),
          )
        ]),
      ),
      Expanded(
        child: StreamBuilder(
          stream: repo.watchUsers(),
          builder: (context, snap) {
            final users = snap.data ?? const [];
            if (users.isEmpty) return const Center(child: Text('No users')); 
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final u = users[i];
                final sel = _selected.contains(u.id);
                return CheckboxListTile(
                  value: sel,
                  onChanged: (v) => setState(() {
                    if (v == true) _selected.add(u.id); else _selected.remove(u.id);
                  }),
                  title: Text(u.email),
                  subtitle: Text('Role: ${u.role} â€¢ ${u.isPro ? 'Pro' : 'Free'}'),
                  secondary: IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Manage user',
                    onPressed: () => _manageUser(context, u),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  Future<void> _manageUser(BuildContext context, DbUser u) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(controller: scrollController, child: _ManageUserSheet(user: u));
          },
        );
      },
    );
  }

  Future<void> _sendEmails(BuildContext context) async {
    final repo = ref.read(adminRepositoryProvider);
    final users = await repo.allUsers();
    final emails = users.where((u) => _selected.contains(u.id)).map((u) => u.email).toList();
    if (emails.isEmpty) return;
    final subject = _template == 1 ? 'Welcome to Citizenship Test' : 'Citizenship Test Update';
    final text = _template == 1 ? _tplWelcome() : _tplUpdate();
    final html = _template == 1 ? _tplWelcomeHtml() : _tplUpdateHtml();
    try {
      await ref.read(emailApiProvider).sendEmail(to: emails, subject: subject, text: text, html: html);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    }
  }

  String _tplWelcome() =>
      'Hello,\n\nWelcome to Citizenship Test!\n\nStart practicing by exploring categories and selecting an exam.\n\nBest regards,\nCitizenship Test Team';
  String _tplUpdate() =>
      'Hello,\n\nWe have added new practice exams and performance analytics.\nLog in to check them out!\n\nBest regards,\nCitizenship Test Team';
  String _tplWelcomeHtml() =>
      '<html><body style="font-family: Arial, sans-serif"><h2>Welcome to Citizenship Test</h2><p>Start practicing by exploring categories and selecting an exam.</p><p>Best regards,<br/>Citizenship Test Team</p></body></html>';
  String _tplUpdateHtml() =>
      '<html><body style="font-family: Arial, sans-serif"><h2>Latest Updates</h2><p>We added new practice exams and performance analytics. Log in to check them out!</p><p>Best regards,<br/>Citizenship Test Team</p></body></html>';
}

class _ManageUserSheet extends ConsumerStatefulWidget {
  final DbUser user;
  const _ManageUserSheet({required this.user});
  @override
  ConsumerState<_ManageUserSheet> createState() => _ManageUserSheetState();
}

class _ManageUserSheetState extends ConsumerState<_ManageUserSheet> {
  String _currency = 'GBP';
  bool _busy = false;
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  Future<int?> _priceMinor(String cur) async {
    final repo = ref.read(adminRepositoryProvider);
    final key = cur == 'GBP' ? 'price_gbp_minor' : 'price_usd_minor';
    final v = await repo.getSetting(key);
    return int.tryParse(v ?? '');
  }

  Future<void> _upgrade() async {
    setState(() => _busy = true);
    final env = await ref.read(envLoaderProvider.future);
    final url = _currency == 'GBP' ? env.stripeCheckoutUrlGbp : env.stripeCheckoutUrlUsd;
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout not configured')));
      }
      setState(() => _busy = false);
      return;
    }
    final res = await Navigator.of(context).push<CheckoutWebViewResult>(
      MaterialPageRoute(builder: (_) => CheckoutWebView(checkoutUrl: url)),
    );
    if (res?.success != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment not completed')));
      }
      setState(() => _busy = false);
      return;
    }
    final repo = ref.read(adminRepositoryProvider);
    final amount = await _priceMinor(_currency) ?? (_currency == 'GBP' ? 1999 : 1999);
    await repo.addPayment(email: widget.user.email, amountMinor: amount, currency: _currency);
    await repo.setUserPro(widget.user.email, true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upgraded ${widget.user.email} to Pro')));
      Navigator.of(context).pop();
    }
    setState(() => _busy = false);
  }

  Future<void> _downgrade() async {
    setState(() => _busy = true);
    await ref.read(adminRepositoryProvider).setUserPro(widget.user.email, false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set ${widget.user.email} to Basic')));
      Navigator.of(context).pop();
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW > 600 ? 600 : maxW),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(widget.user.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Current: ${widget.user.isPro ? 'Pro' : 'Free'}'),
            const SizedBox(height: 12),
            const Text('Currency'),
            RadioListTile<String>(value: 'GBP', groupValue: _currency, title: const Text('GBP'), onChanged: _busy ? null : (v) => setState(() => _currency = v ?? 'GBP')),
            RadioListTile<String>(value: 'USD', groupValue: _currency, title: const Text('USD'), onChanged: _busy ? null : (v) => setState(() => _currency = v ?? 'USD')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton(onPressed: _busy ? null : _upgrade, child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Upgrade via Stripe'))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _busy ? null : _downgrade, child: const Text('Downgrade to Basic'))),
            ]),
            const Divider(height: 24),
            Text('Send custom message', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 8),
            TextField(controller: _messageCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 4),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                onPressed: _busy
                    ? null
                    : () async {
                        final subject = _subjectCtrl.text.trim();
                        final msg = _messageCtrl.text.trim();
                        if (subject.isEmpty || msg.isEmpty) return;
                        setState(() => _busy = true);
                        try {
                          await ref.read(emailApiProvider).sendEmail(to: [widget.user.email], subject: subject, text: msg, html: null);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
                          }
                        }
                        if (mounted) setState(() => _busy = false);
                      },
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ReportsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<_ReportsTab> {
  final _controller = ScrollController();
  List<({Report report, Exam exam})> _items = [];
  bool _loading = false;
  int _page = 0;
  final int _size = 25;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200 && !_loading) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    final next = await repo.listReports(limit: _size, offset: _page * _size);
    setState(() {
      _page++;
      _loading = false;
      _items.addAll(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No reports yet'));
    }
    return ListView.builder(
      controller: _controller,
      itemCount: _items.length + 1,
      itemBuilder: (_, i) {
        if (i == _items.length) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: _loading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink(),
          );
        }
        final item = _items[i];
        final r = item.report;
        final e = item.exam;
        return Card(
          child: ListTile(
            leading: Icon(r.resolved ? Icons.check_circle : Icons.report, color: r.resolved ? Colors.green : Colors.orange),
            title: Text(e.title.isEmpty ? 'Untitled' : e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('From: ${r.userEmail}'),
              const SizedBox(height: 4),
              Text(r.comment),
            ]),
            trailing: Wrap(spacing: 8, children: [
              Switch(
                value: r.resolved,
                onChanged: (v) async {
                  await ref.read(adminRepositoryProvider).markReportResolved(r.id, v);
                  setState(() => _items[i] = (report: r.copyWith(resolved: v), exam: e));
                },
              ),
              IconButton(
                tooltip: 'Delete report',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete report?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref.read(adminRepositoryProvider).deleteReport(r.id);
                    setState(() => _items.removeAt(i));
                  }
                },
              )
            ]),
          ),
        );
      },
    );
  }
}

typedef PageLoader<T> = Future<List<T>> Function(int page, int size);

class _PagedList<T> extends StatefulWidget {
  final PageLoader<T> pageLoader;
  final Widget Function(BuildContext, T) itemBuilder;
  final int pageSize;
  const _PagedList({required this.pageLoader, required this.itemBuilder, this.pageSize = 25});
  @override
  State<_PagedList<T>> createState() => _PagedListState<T>();
}

class _PaymentsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  final gbpCtrl = TextEditingController();
  final usdCtrl = TextEditingController();
  final dbCtrl = TextEditingController();
  final _controller = ScrollController();
  final List<Payment> _items = [];
  bool _loading = false;
  int _page = 0;
  final int _size = 25;

  @override
  void initState() {
    super.initState();
    _initPrices();
    _loadMore();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200 && !_loading) _loadMore();
    });
  }

  Future<void> _initPrices() async {
    final repo = ref.read(adminRepositoryProvider);
    gbpCtrl.text = (await repo.getSetting('price_gbp_minor')) ?? '1999';
    usdCtrl.text = (await repo.getSetting('price_usd_minor')) ?? '1999';
    dbCtrl.text = (await repo.getSetting('database_url')) ?? '';
    setState(() {});
  }

  Future<void> _savePrices() async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.setSetting('price_gbp_minor', gbpCtrl.text.trim());
    await repo.setSetting('price_usd_minor', usdCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prices saved')));
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    final more = await repo.listPayments(limit: _size, offset: _page * _size);
    setState(() {
      _page++;
      _items.addAll(more);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          Expanded(child: TextField(controller: gbpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GBP (minor)'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: usdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'USD (minor)'))),
          const SizedBox(width: 8),
          FilledButton(onPressed: _savePrices, child: const Text('Save')),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Export content'),
            onPressed: () async {
              try {
                final data = await ref.read(syncRepositoryProvider).dumpLocalSnapshot();
                final dio = ref.read(dioProvider);
                await dio.post('/admin/import-snapshot', data: data);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported to server')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
              }
            },
          )
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(children: [
          Expanded(child: TextField(controller: dbCtrl, decoration: const InputDecoration(labelText: 'DATABASE_URL (postgres://...)'))),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              await ref.read(adminRepositoryProvider).setSetting('database_url', dbCtrl.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database URL saved')));
              }
            },
            child: const Text('Save URL'),
          )
        ]),
      ),
      Expanded(
        child: ListView.builder(
          controller: _controller,
          itemCount: _items.length + 1,
          itemBuilder: (_, i) {
            if (i == _items.length) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: _loading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink(),
              );
            }
            final p = _items[i];
            return Card(
              child: ListTile(
                title: Text('${p.userEmail} â€¢ ${p.currency} ${(p.amountMinor / 100).toStringAsFixed(2)}'),
                subtitle: Text('${p.status} â€¢ ${p.createdAt.toLocal()}'.split('.').first),
                trailing: p.refunded ? const Text('Refunded') : TextButton(onPressed: () async {
                  await ref.read(adminRepositoryProvider).markRefunded(p.id);
                  setState(() => _items[i] = p.copyWith(refunded: true, status: 'refunded'));
                }, child: const Text('Refund')),
              ),
            );
          },
        ),
      )
    ]);
  }
}

class _PagedListState<T> extends State<_PagedList<T>> {
  final _controller = ScrollController();
  final List<T> _items = [];
  bool _loading = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200 && !_loading) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    final next = await widget.pageLoader(_page, widget.pageSize);
    setState(() {
      _page++;
      _items.addAll(next);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('No items'));
    return ListView.builder(
      controller: _controller,
      itemCount: _items.length + 1,
      itemBuilder: (_, i) {
        if (i == _items.length) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: _loading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink(),
          );
        }
        final item = _items[i];
        return widget.itemBuilder(context, item);
      },
    );
  }
}

class _QuestionsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends ConsumerState<_QuestionsTab> {
  final Set<int> _selected = {};
  String _filter = 'All'; // All, Unassigned, Category, Subcategory
  int? _categoryId;
  int? _subcategoryId;
  String _sort = 'Newest';
  String _query = '';
  List<Question> _items = [];
  List<Category> _cats = [];
  List<Subcategory> _subs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    final cats = await repo.categories();
    List<Subcategory> subs = [];
    if (_categoryId != null) subs = await repo.watchSubcategories(_categoryId!).first;
    List<Question> qs;
    if (_filter == 'Unassigned') {
      qs = await repo.unassignedQuestions(limit: 500);
    } else if (_filter == 'Category' && _categoryId != null) {
      qs = await repo.questionsInCategory(_categoryId!, limit: 500);
    } else if (_filter == 'Subcategory' && _subcategoryId != null) {
      qs = await repo.questionsInSubcategory(_subcategoryId!, limit: 500);
    } else {
      qs = await repo.pagedQuestions(limit: 500, offset: 0);
    }
    if (_sort == 'Oldest') {
      qs = qs.reversed.toList();
    }
    setState(() {
      _cats = cats;
      _subs = subs;
      _items = _applyQuery(qs);
      _loading = false;
    });
  }

  List<Question> _applyQuery(List<Question> input) {
    if (_query.trim().isEmpty) return input;
    final q = _query.trim().toLowerCase();
    return input.where((e) => e.body.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(adminRepositoryProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          DropdownButton<String>(
            value: _filter,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Unassigned', child: Text('No category')),
              DropdownMenuItem(value: 'Category', child: Text('In category')),
              DropdownMenuItem(value: 'Subcategory', child: Text('In subcategory')),
            ],
            onChanged: (v) async {
              setState(() {
                _filter = v ?? 'All';
                _categoryId = null;
                _subcategoryId = null;
                _selected.clear();
              });
              await _load();
            },
          ),
          SizedBox(
            width: 220,
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search questions'),
              onChanged: (v) => setState(() {
                _query = v;
                _items = _applyQuery(_items);
              }),
            ),
          ),
          if (_filter == 'Category')
            DropdownButton<int>(
              hint: const Text('Category'),
              value: _categoryId,
              items: [for (final c in _cats) DropdownMenuItem(value: c.id, child: Text(c.name))],
              onChanged: (v) async {
                setState(() {
                  _categoryId = v;
                  _subcategoryId = null;
                });
                await _load();
              },
            ),
          if (_filter == 'Subcategory')
            DropdownButton<int>(
              hint: const Text('Subcategory'),
              value: _subcategoryId,
              items: [for (final s in _subs) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) async {
                setState(() => _subcategoryId = v);
                await _load();
              },
            ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _sort,
            items: const [DropdownMenuItem(value: 'Newest', child: Text('Newest')), DropdownMenuItem(value: 'Oldest', child: Text('Oldest'))],
            onChanged: (v) async {
              setState(() => _sort = v ?? 'Newest');
              await _load();
            },
          ),
          const SizedBox(width: 12),
          CheckboxListTile(
            value: _items.isNotEmpty && _selected.length == _items.length,
            onChanged: (v) => setState(() {
              _selected
                ..clear()
                ..addAll(v == true ? _items.map((e) => e.id) : <int>{});
            }),
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Select all visible'),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          const Text('Move selected to:'),
          DropdownButton<int>(
            hint: const Text('Category'),
            value: _categoryId,
            items: [for (final c in _cats) DropdownMenuItem(value: c.id, child: Text(c.name))],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          FutureBuilder(
            future: _categoryId != null ? repo.watchSubcategories(_categoryId!).first : Future.value(<Subcategory>[]),
            builder: (context, snap) {
              final subs = snap.data ?? const <Subcategory>[];
              return DropdownButton<int>(
                hint: const Text('Subcategory'),
                value: _subcategoryId,
                items: [for (final s in subs) DropdownMenuItem(value: s.id, child: Text(s.name))],
                onChanged: (v) => setState(() => _subcategoryId = v),
              );
            },
          ),
          FilledButton(
            onPressed: _selected.isEmpty ? null : () async {
              await repo.moveQuestionsTo(questionIds: _selected.toList(), categoryId: _categoryId, subcategoryId: _subcategoryId);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moved')));
              await _load();
            },
            child: const Text('Move Selected'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.shuffle),
            label: const Text('Random Assign'),
            onPressed: () => _randomAssign(context),
          ),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final q = _items[i];
                  final sel = _selected.contains(q.id);
                  return ListTile(
                    leading: Checkbox(value: sel, onChanged: (v) => setState(() { if (v == true) _selected.add(q.id); else _selected.remove(q.id);})),
                    title: Text(q.body.isEmpty ? 'Untitled' : q.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: FutureBuilder(
                      future: repo.categoriesForQuestion(q.id),
                      builder: (context, catsSnap) {
                        final cats = catsSnap.data ?? const [];
                        final catText = cats.isEmpty ? 'No categories' : 'Categories: ${cats.map((e) => e.name).join(', ')}';
                        return Text(catText);
                      },
                    ),
                    trailing: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Lock'),
                        Switch(
                          value: q.locked,
                          onChanged: (v) async {
                            await repo.setQuestionLocked(q.id, v);
                            await _load();
                          },
                        ),
                      ]),
                      IconButton(
                        tooltip: 'Assign categories',
                        icon: const Icon(Icons.category),
                        onPressed: () async {
                          final cats = await repo.categories();
                          final current = await repo.categoriesForQuestion(q.id);
                          final currentIds = current.map((e) => e.id).toSet();
                          final selected = await showDialog<Set<int>>(
                            context: context,
                            builder: (ctx) {
                              final temp = {...currentIds};
                              return StatefulBuilder(builder: (context, set) {
                                return AlertDialog(
                                  title: const Text('Assign Categories'),
                                  content: SizedBox(
                                    width: 420,
                                    child: ListView(shrinkWrap: true, children: [
                                      for (final c in cats)
                                        CheckboxListTile(
                                          value: temp.contains(c.id),
                                          onChanged: (v) => set(() { if (v == true) temp.add(c.id); else temp.remove(c.id); }),
                                          title: Text(c.name),
                                        ),
                                    ]),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                                    FilledButton(onPressed: () => Navigator.of(ctx).pop(temp), child: const Text('Save')),
                                  ],
                                );
                              });
                            },
                          );
                          if (selected != null) {
                            await repo.setCategoriesForQuestion(q.id, selected.toList());
                            await _load();
                          }
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete question',
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete question?'),
                              content: const Text('This will remove the question from all exams.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await repo.deleteQuestion(q.id);
                            await _load();
                          }
                        },
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  Future<void> _randomAssign(BuildContext context) async {
    final repo = ref.read(adminRepositoryProvider);
    final cats = await repo.categories();
    final subs = await repo.allSubcategories();
    final catSel = <int>{};
    final subSel = <int>{};
    final catCtrl = TextEditingController(text: '10');
    final subCtrl = TextEditingController(text: '10');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, set) {
        return AlertDialog(
          title: const Text('Random Assign'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Select categories'),
                const SizedBox(height: 6),
                ...cats.map((c) => CheckboxListTile(value: catSel.contains(c.id), onChanged: (v) => set(() { if (v == true) catSel.add(c.id); else catSel.remove(c.id);} ), title: Text(c.name))),
                const Divider(),
                const Text('Select subcategories'),
                const SizedBox(height: 6),
                ...subs.map((s) => CheckboxListTile(value: subSel.contains(s.id), onChanged: (v) => set(() { if (v == true) subSel.add(s.id); else subSel.remove(s.id);} ), title: Text(s.name))),
                const SizedBox(height: 8),
                TextField(controller: catCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Per-category count')),
                TextField(controller: subCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Per-subcategory count')),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Run')),
          ],
        );
      }),
    );
    if (ok == true) {
      final perC = int.tryParse(catCtrl.text.trim()) ?? 0;
      final perS = int.tryParse(subCtrl.text.trim()) ?? 0;
      await repo.randomAssign(categoryIds: catSel.toList(), subcategoryIds: subSel.toList(), perCategory: perC, perSubcategory: perS);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Random assignment complete')));
      await _load();
    }
  }
}







