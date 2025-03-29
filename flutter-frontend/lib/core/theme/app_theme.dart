import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 239, 98, 10);
  static const Color accentColor = Color(0xFFFFAB40);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFE53935);

  // Default text style to be used throughout the app
  static final TextStyle defaultTextStyle = GoogleFonts.unkempt();

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: accentColor,
      error: errorColor,
    ),
    textTheme: GoogleFonts.unkemptTextTheme(),
    fontFamily: defaultTextStyle.fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    scaffoldBackgroundColor: backgroundColor,
    useMaterial3: true,
  );
}
