import 'package:flutter/material.dart';

class AppTheme {
  // Colores Oficiales BCP
  static const Color bcpBlue = Color(0xFF002F6C); // Azul BCP
  static const Color bcpOrange = Color(0xFFFF7900); // Naranja BCP
  static const Color bcpCyan = Color(0xFF00A9E0); // Celeste BCP
  
  // Fondos Premium (Obsidian Blue)
  static const Color darkBackground = Color(0xFF060B1A); // Más oscuro y premium
  static const Color cardDark = Color(0xFF0E172E); // Obsidian profundo para tarjetas
  static const Color inputFieldColor = Color(0xFF142247); // Inputs mejor integrados

  // Colores de Acento y Neón
  static const Color neonOrange = Color(0xFFFF9E40);
  static const Color neonCyan = Color(0xFF33CFFF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonRed = Color(0xFFFF3838);

  // Gradientes oficiales y premium
  static const Gradient bcpGradient = LinearGradient(
    colors: [
      Color(0xFF001E4D), // Azul BCP profundo
      Color(0xFF060B1A), // Obsidian Background
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient bcpOrangeGradient = LinearGradient(
    colors: [
      Color(0xFFFF7900), // Naranja BCP
      Color(0xFFFF9E40), // Naranja neón brillante
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient bcpCyanGradient = LinearGradient(
    colors: [
      Color(0xFF00A9E0), // Celeste BCP
      Color(0xFF33CFFF), // Celeste neón
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient glassBorderGradient = LinearGradient(
    colors: [
      Colors.white38,
      Colors.white10,
      Colors.transparent,
      Colors.white10,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Decoración de Vidrio (Glassmorphism) Reutilizable
  static BoxDecoration glassDecoration({
    Color color = cardDark,
    double opacity = 0.75,
    double borderRadius = 24.0,
    Color borderColor = Colors.white,
    double borderOpacity = 0.06,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor.withOpacity(borderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Sombra con Brillo (Neon Glow)
  static List<BoxShadow> neonGlowShadow({
    required Color color,
    double opacity = 0.3,
    double blurRadius = 12.0,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: 1,
        offset: offset,
      ),
    ];
  }

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
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFieldColor,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: neonOrange, fontWeight: FontWeight.bold),
      helperStyle: const TextStyle(color: Colors.white30, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: bcpOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: neonRed, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bcpOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 3,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: bcpOrange,
        side: const BorderSide(color: bcpOrange, width: 1.8),
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}