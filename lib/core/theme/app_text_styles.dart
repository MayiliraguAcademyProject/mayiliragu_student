import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';
  
  static const double sizeHeading = 24.0;
  static const double sizeSubheading = 16.0;
  static const double sizeBody = 14.0;
  static const double sizeButton = 16.0;

  // Legacy style mappings for compatibility
  static TextStyle get heading => GoogleFonts.getFont(
        fontFamily,
        fontSize: sizeHeading,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get subheading => GoogleFonts.getFont(
        fontFamily,
        fontSize: sizeSubheading,
      );

  static TextStyle get body => GoogleFonts.getFont(
        fontFamily,
        fontSize: sizeBody,
      );

  static TextStyle get button => GoogleFonts.getFont(
        fontFamily,
        fontSize: sizeButton,
        fontWeight: FontWeight.w600,
      );

  // Academic Clarity Specification Styles
  static TextStyle get displayLarge => GoogleFonts.getFont(
        fontFamily,
        fontSize: 48.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
      );

  static TextStyle get headlineLarge => GoogleFonts.getFont(
        fontFamily,
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
      );

  static TextStyle get headlineLargeMobile => GoogleFonts.getFont(
        fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => GoogleFonts.getFont(
        fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.getFont(
        fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.getFont(
        fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelMedium => GoogleFonts.getFont(
        fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.01,
      );

  static TextStyle get labelSmall => GoogleFonts.getFont(
        fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
      );
}
