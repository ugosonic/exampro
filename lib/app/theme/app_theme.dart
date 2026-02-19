import 'package:flutter/material.dart';

class AppTheme {
  // Sky blue palette for light mode
  static const _primary = Color(0xFF2C69C9); // sky blue
  static const _secondary = Color(0xFF7AC3FF); // light aqua
  static const _tertiary = Color(0xFFFFB74D); // warm accent

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _primary, primary: _primary, secondary: _secondary, tertiary: _tertiary);
    return ThemeData(useMaterial3: true, colorScheme: scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6FAFF),
      appBarTheme: const AppBarTheme(elevation: 0, foregroundColor: Color(0xFF0B2540)),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: const NavigationBarThemeData(indicatorColor: Color(0xFFDDEEFF)),
      chipTheme: ChipThemeData(backgroundColor: const Color(0xFFE1F2FF), selectedColor: const Color(0xFFFFF0DA)),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(Color(0xFF0B2540)),
          backgroundColor: WidgetStatePropertyAll(_primary.withValues(alpha: 0.92)),
          overlayColor: WidgetStatePropertyAll(_primary.withValues(alpha: 0.12)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      ),
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
