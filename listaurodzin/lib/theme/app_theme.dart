import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Główne kolory aplikacji
  static const Color primary = Color(0xFF27B2A4);
  static const Color primaryDark = Color(0xFF15766E);
  static const Color primaryDarker = Color(0xFF0D7C70);
  static const Color primaryDeep = Color(0xFF15998C);
  static const Color primaryLight = Color(0xFF6EE1D4);
  static const Color primaryCyan = Color(0xFF92F5ED);
  static const Color primarySky = Color(0xFFAAE0EB);
  static const Color primaryActive = Color(0xFF3FD1C2);

  // Tła i powierzchnie
  static const Color background = Color(0xF7F4F6F8);
  static const Color cardColor = Colors.white;
  static const Color borderGrey = Color(0xFFBFC6CC);

  // Akcenty kolorystyczne
  static const Color redAlert = Color(0xFFDC0F0F);
  static const Color deleteRed = Color(0xFFF54558);
  static const Color blueNext = Color(0xFF0F08EB);

  // Gradienty
  static const LinearGradient topGradient = LinearGradient(
    colors: [primary, Color(0xC55BEFDE)],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient languageGradient = LinearGradient(
    colors: [primary, primarySky],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bottomGradient = LinearGradient(
    colors: [Color(0xFF38D8CB), primarySky],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cardColor,
      ),
      textTheme: GoogleFonts.interTightTextTheme(),
    );
  }
}
