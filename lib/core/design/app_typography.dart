import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    // Headings: Poppins, Body: Inter
    final base = ThemeData(brightness: brightness).textTheme;

    final inter = GoogleFonts.interTextTheme(base);
    final poppins = GoogleFonts.poppinsTextTheme(base);

    return inter.copyWith(
      displayLarge: poppins.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: poppins.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      displaySmall: poppins.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: poppins.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: poppins.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: poppins.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: poppins.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: poppins.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: poppins.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
