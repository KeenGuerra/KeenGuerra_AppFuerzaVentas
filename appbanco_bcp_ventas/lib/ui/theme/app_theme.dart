import 'package:flutter/material.dart';

class AppTheme {
  // Colores Oficiales BCP
  static const Color bcpBlue = Color(0xFF002F6C); // Azul BCP
  static const Color bcpOrange = Color(0xFFFF7900); // Naranja BCP
  static const Color bcpCyan = Color(0xFF00A9E0); // Celeste BCP
  
  // Fondos Premium (Obsidian Blue)
  static const Color darkBackground = Color(0xFF080F26); 
  static const Color cardDark = Color(0xFF111E3F); 
  static const Color inputFieldColor = Color(0xFF182852);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: bcpOrange,
      primary: bcpOrange,
      secondary: bcpBlue,
      tertiary: bcpCyan,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFieldColor,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: bcpOrange, fontWeight: FontWeight.bold),
      helperStyle: const TextStyle(color: Colors.white38, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: bcpOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bcpOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: bcpOrange,
        side: const BorderSide(color: bcpOrange, width: 1.8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  );

  // Gradiente oficial para pantallas y contenedores
  static const Gradient bcpGradient = LinearGradient(
    colors: [
      Color(0xFF002F6C), // Azul BCP
      Color(0xFF080F26), // Fondo oscuro
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}