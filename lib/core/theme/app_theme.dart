import 'package:flutter/material.dart';

/// High-contrast light mode som standard.
/// Svart tekst på hvit bakgrunn for best lesbarhet i direkte sollys.
class AppTheme {
  static const double minTapTarget = 60.0;
  static const double studentNameFontSize = 18.0;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1565C0),
          secondary: Color(0xFF43A047),
          error: Color(0xFFD32F2F),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF000000),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF000000)),
          bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF000000)),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(minTapTarget, minTapTarget),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF42A5F5),
          secondary: Color(0xFF66BB6A),
          error: Color(0xFFEF5350),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );

  /// Statusfarger for fraværsregistrering
  static const Color statusUkjent = Color(0xFF9E9E9E);      // Grå
  static const Color statusTilStede = Color(0xFF43A047);     // Grønn
  static const Color statusFravaer = Color(0xFFD32F2F);      // Rød
  static const Color statusForseinka = Color(0xFFFFA000);    // Gul
  static const Color statusPlanlagtBorte = Color(0xFF1565C0); // Blå
}
