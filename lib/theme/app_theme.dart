import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF006E1C);
  static const darkGreen = Color(0xFF06322B);
  static const background = Color(0xFFF8FAF8);
  static const outline = Color(0xFFBECAB9);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, surface: background),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, height: 1.25, fontWeight: FontWeight.w700, color: Color(0xFF191C1B)),
      headlineSmall: TextStyle(fontSize: 24, height: 1.33, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.43, color: Color(0xFF3F4A3C)),
      labelMedium: TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w600, letterSpacing: .5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
    ),
    cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: outline))),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
  );
}
