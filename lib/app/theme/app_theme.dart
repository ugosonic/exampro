import 'package:flutter/material.dart';

class AppTheme {
<<<<<<< HEAD
  static const _primary = Color(0xFF6C63FF); // indigo/purple
  static const _secondary = Color(0xFF00C2A8); // teal
  static const _accent = Color(0xFFFFB020); // warm

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: _primary,
        secondary: _secondary,
        surface: Colors.white,
        onSurface: const Color(0xFF0E0E10),
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(elevation: 0, foregroundColor: Color(0xFF0E0E10)),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      visualDensity: VisualDensity.adaptivePlatformDensity,
=======
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
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    );
  }

  static ThemeData get dark {
<<<<<<< HEAD
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: _primary,
        secondary: _secondary,
        surface: const Color(0xFF0E0E10),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0E0E10),
      cardTheme: CardThemeData(
        color: const Color(0xFF141416),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      visualDensity: VisualDensity.adaptivePlatformDensity,
=======
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
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    );
  }
}
