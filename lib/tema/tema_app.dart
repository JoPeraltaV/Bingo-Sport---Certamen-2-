import 'package:flutter/material.dart';

const _semilla = Color(0xFF4C5FD7);

ThemeData crearTemaBingoSport({Brightness brightness = Brightness.light}) {
  final esDark = brightness == Brightness.dark;

  final esquema = ColorScheme.fromSeed(
    seedColor: _semilla,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor:
        esDark ? const Color(0xFF0E0F1A) : const Color(0xFFF7F8FC),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: esDark ? const Color(0xFF1A1B2E) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: esquema.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: esquema.primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: esDark ? const Color(0xFF1A1B2E) : Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
