import 'package:flutter/material.dart';

class AppTheme {
  static const Color bcpBlue = Color(0xFF0039A6);
  static const Color bcpOrange = Color(0xFFFF7800);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: bcpOrange,
      primary: bcpOrange,
      secondary: bcpBlue,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bcpOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}