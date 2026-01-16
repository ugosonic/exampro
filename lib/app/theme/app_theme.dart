import 'package:flutter/material.dart';

class AppTheme {
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
    );
  }

  static ThemeData get dark {
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
    );
  }
}
