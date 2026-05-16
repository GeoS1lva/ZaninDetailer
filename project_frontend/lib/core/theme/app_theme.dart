import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color primaryRed = Color(0xFFA61D33);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF888888);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningYellow = Color(0xFFFFC107);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        surface: surface,
        background: background,
      ),
      textTheme: GoogleFonts.urbanistTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.montserrat(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.montserrat(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }
}
