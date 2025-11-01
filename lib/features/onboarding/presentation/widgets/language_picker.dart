import 'package:exampro/core/i18n/locale_controller.dart';
import 'package:exampro/core/i18n/translation_populator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final langs = const [
      ('EN', Locale('en')),
      ('ES', Locale('es')),
      ('FR', Locale('fr')),
      ('DE', Locale('de')),
      ('IT', Locale('it')),
      ('PT', Locale('pt')),
      ('TR', Locale('tr')),
      ('AR', Locale('ar')),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Locale>(
            value: current,
            items: [
              for (final p in langs)
                DropdownMenuItem(value: p.$2, child: Text(p.$1)),
            ],
            onChanged: (loc) async {
              if (loc == null) return;
              // feedback while translating
              final messenger = ScaffoldMessenger.maybeOf(context);
              final snack = SnackBar(content: Text('Translating to ${loc.languageCode.toUpperCase()}...'), duration: const Duration(seconds: 1));
              if (messenger != null) messenger.showSnackBar(snack);
              await applyLanguageAndTranslate(ref, loc);
              if (messenger != null) messenger.showSnackBar(const SnackBar(content: Text('Language applied')));
            },
          ),
        ),
      ),
    );
  }
}
