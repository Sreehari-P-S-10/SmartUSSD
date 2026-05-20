import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get displayLg => GoogleFonts.robotoFlex(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 64 / 56,
        letterSpacing: -0.02 * 56,
      );

  static TextStyle get headlineLg => GoogleFonts.robotoFlex(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.01 * 32,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.robotoFlex(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
      );

  static TextStyle get headlineMd => GoogleFonts.robotoFlex(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      );

  static TextStyle get bodyLg => GoogleFonts.robotoFlex(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
      );

  static TextStyle get bodyMd => GoogleFonts.robotoFlex(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  static TextStyle get labelMd => GoogleFonts.robotoFlex(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
      );

  static TextStyle get labelSm => GoogleFonts.robotoFlex(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
      );
}
