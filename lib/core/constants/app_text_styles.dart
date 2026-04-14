import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static TextStyle get titleLarge =>
      GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get labelLarge =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600);
}
