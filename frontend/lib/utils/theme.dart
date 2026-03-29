import 'package:flutter/material.dart';

class ETTheme {
  // ── Platinum & Gold Brand Palette ──
  static const Color primary = Color(0xFF0F172A); // Deep Indigo
  static const Color secondary = Color(0xFFEAB308); // Premium Gold
  static const Color accent = Color(0xFF475569); // Steel Grey
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);

  // ── Dark Theme (Platinum & Gold) ──
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: secondary,
    scaffoldBackgroundColor: darkBg,
    fontFamily: 'Inter',
    
    cardTheme: CardThemeData(
      color: darkCard.withOpacity(0.5),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white, height: 1.5),
      bodyMedium: TextStyle(color: Colors.white70, height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 10),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: secondary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white70),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    ),
  );

  // ── Light Theme ──
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: primary,
    fontFamily: 'Inter',
  );
}
