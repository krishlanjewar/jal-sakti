import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryBlue = Color(0xFF0077C2);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color alertRed = Color(0xFFF44336);
  static const Color textNavy = Color(0xFF0D1B2A);
  static const Color lightGray = Color(0xFFF5F5F5);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.white,
    // Using default system fonts to remove google_fonts dependency.
    fontFamily: 'Roboto', 

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // NOTE: The global CardTheme has been removed. 
    // We now use the ReusableCard widget for a more robust and pleasing design.

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
     // Define a default text theme without GoogleFonts
    textTheme: const TextTheme(
       headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textNavy,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textNavy,
      ),
       titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textNavy,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textNavy,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textNavy,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  );

  static Color? get textPrimary => null;
}
