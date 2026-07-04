import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Branding Colors
  static const Color primary = Color(0xFFEA580C); // Orange
  static const Color accent = Color(0xFFF97316);  // Light Orange
  
  // Light Mode Colors
  static const Color backgroundStart = Color(0xFFFFFDFB);
  static const Color backgroundEnd = Color(0xFFFFF3E5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF26160C);
  static const Color textSecondary = Color(0xFF605247);
  static const Color border = Color(0xFFEADDD0);
  
  // Dark Mode Colors
  static const Color backgroundStartDark = Color(0xFF0C0A09);
  static const Color backgroundEndDark = Color(0xFF1C1917);
  static const Color cardBgDark = Color(0xFF1C1917);
  static const Color textPrimaryDark = Color(0xFFF5F5F4);
  static const Color textSecondaryDark = Color(0xFFA8A29E);
  static const Color borderDark = Color(0xFF292524);

  // Common Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onPrimary = Colors.white;
  
  // Backward compatibility aliases for legacy purple theme references
  static const Color brandPurple = Color(0xFFEA580C);
  static const Color lightLavender = Color(0xFFFFF3E5);
  static const Color indicatorInactive = Color(0xFFEADDD0);
  
  // Legacy specifics
  static const Color surface = Color(0xFFFFFDFB);
  static const Color surfaceContainer = Color(0xFFFFF3E5);
  static const Color surfaceContainerHigh = Color(0xFFFFF3E5);
  static const Color surfaceContainerHighest = Color(0xFFFFF3E5);
  static const Color primaryContainer = Color(0xFFFFF3E5);
  static const Color secondaryContainer = Color(0xFFFDBA74);
  static const Color onSecondaryContainer = Color(0xFFEA580C);
  
  static const Color secondary = Color(0xFFFFF3E5);
  static const Color accentDark = Color(0xFF431407);
}
