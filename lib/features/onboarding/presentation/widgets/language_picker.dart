import 'package:citizentest/core/i18n/locale_controller.dart';
import 'package:citizentest/core/i18n/translation_populator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Locale>(
            value: current,
            dropdownColor: isDark ? const Color(0xFF172030) : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
            iconEnabledColor: isDark ? Colors.white : Colors.black87,
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
