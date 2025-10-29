import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF6750A4); // vibrant purple
  static const _secondary = Color(0xFF00BFA6); // mint/teal
  static const _tertiary = Color(0xFFFF8A65); // coral accent

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _primary, primary: _primary, secondary: _secondary, tertiary: _tertiary);
    return ThemeData(useMaterial3: true, colorScheme: scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF9FAFE),
      appBarTheme: const AppBarTheme(elevation: 0, foregroundColor: Color(0xFF101213)),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: const NavigationBarThemeData(indicatorColor: Color(0xFFEDE7F6)),
      chipTheme: ChipThemeData(backgroundColor: const Color(0xFFE0F2F1), selectedColor: const Color(0xFFFFE0B2)),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: _primary, primary: _primary, secondary: _secondary, tertiary: _tertiary);
    return ThemeData(useMaterial3: true, colorScheme: scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      cardTheme: CardThemeData(
        color: const Color(0xFF151921),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: const NavigationBarThemeData(indicatorColor: Color(0xFF1E2230)),
      chipTheme: ChipThemeData(backgroundColor: const Color(0xFF263238), selectedColor: const Color(0xFF3E2723)),
    );
  }
}
