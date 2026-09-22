import 'package:flutter/material.dart';

class AdminTheme {
  static const forest = Color(0xff0f382a);
  static const emerald = Color(0xff1b8354);
  static const canvas = Color(0xfff8f9ff);
  static const ink = Color(0xff0b1c30);
  static const muted = Color(0xff64748b);
  static const border = Color(0xffe2e8f0);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: forest,
      primary: forest,
      secondary: emerald,
      surface: Colors.white,
      error: const Color(0xffdc2626),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: border,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: forest,
          fontWeight: FontWeight.w700,
          letterSpacing: -.7,
        ),
        headlineMedium: TextStyle(
          color: forest,
          fontWeight: FontWeight.w700,
          letterSpacing: -.4,
        ),
        headlineSmall: TextStyle(color: forest, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: forest, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: ink),
        bodyMedium: TextStyle(color: ink),
        bodySmall: TextStyle(color: muted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: forest,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: emerald, width: 1.5),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(Color(0xfff8fafc)),
        headingTextStyle: TextStyle(
          color: muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
        ),
        dataTextStyle: TextStyle(color: ink, fontSize: 13),
        dividerThickness: 0.6,
        horizontalMargin: 20,
        columnSpacing: 24,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xff0f382a),
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: TextStyle(
          color: forest,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(color: muted),
      ),
    );
  }
}
