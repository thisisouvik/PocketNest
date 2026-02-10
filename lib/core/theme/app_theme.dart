import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color backgroundColor = Color(
    0xFFF5F1ED,
  ); // Soft beige/warm off-white
  static const Color primaryColor = Color(0xFF5B7C7E); // Muted teal
  static const Color accentColor = Color(0xFFE8B4A8); // Soft peach
  static const Color buttonDarkColor = Color(
    0xFF32575A,
  ); // Dark teal for buttons

  // Secondary colors
  static const Color cardBackground = Color(0xFFFFFBF7);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE0DDD9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _playfair(
        size: 24,
        weight: FontWeight.w700,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      surface: cardBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _inter(
          size: 16,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _inter(
          size: 16,
          weight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: _inter(
          size: 14,
          weight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: _playfair(
        size: 48,
        weight: FontWeight.w700,
        color: textPrimary,
      ),
      displayMedium: _playfair(
        size: 40,
        weight: FontWeight.w700,
        color: textPrimary,
      ),
      displaySmall: _playfair(
        size: 32,
        weight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: _playfair(
        size: 28,
        weight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: _playfair(
        size: 24,
        weight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: _inter(size: 20, weight: FontWeight.w600, color: textPrimary),
      titleMedium: _inter(
        size: 16,
        weight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: _inter(size: 14, weight: FontWeight.w600, color: textPrimary),
      bodyLarge: _inter(size: 16, weight: FontWeight.w400, color: textPrimary),
      bodyMedium: _inter(
        size: 14,
        weight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: _inter(
        size: 12,
        weight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: _inter(
        size: 14,
        weight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: _inter(
        size: 14,
        weight: FontWeight.w400,
        color: textSecondary,
      ),
      hintStyle: _inter(
        size: 14,
        weight: FontWeight.w400,
        color: textSecondary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 16,
    ),
  );

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle _playfair({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
