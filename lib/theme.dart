import 'package:flutter/material.dart';

class CribColors {
  static const felt = Color(0xFF10291C);
  static const feltLight = Color(0xFF1B3D2A);
  static const gold = Color(0xFFC9A227);
  static const cream = Color(0xFFF3E6C8);
  static const ink = Color(0xFF1A1408);
  static const redSuit = Color(0xFFC62828);
  static const blackSuit = Color(0xFF1A1A1A);
}

ThemeData cribTheme() {
  const cream = CribColors.cream;
  const felt = CribColors.felt;
  const gold = CribColors.gold;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: felt,
    colorScheme: const ColorScheme.dark(
      surface: felt,
      primary: gold,
      onPrimary: CribColors.ink,
      secondary: cream,
      onSurface: cream,
      error: Color(0xFFE57373),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: felt,
      foregroundColor: cream,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: CribColors.feltLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: CribColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cream,
        side: const BorderSide(color: gold),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: CribColors.feltLight,
      contentTextStyle: TextStyle(color: cream),
    ),
  );
}
