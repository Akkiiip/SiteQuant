import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0969F8);
  static const Color navy = Color(0xFF071D49);
  static const Color pageBackground = Color(0xFFF4F8FD);
  static const Color border = Color(0xFFD8E4F2);
  static const Color ink = Color(0xFF0A1D45);
  static const Color mutedInk = Color(0xFF667085);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: pageBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: pageBackground,
      foregroundColor: ink,
      titleTextStyle: TextStyle(
        color: ink,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: primaryBlue.withValues(alpha: 0.12),
      surfaceTintColor: Colors.white,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelStyle: const TextStyle(color: primaryBlue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD7DFEA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD7DFEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primaryBlue,
      side: const BorderSide(color: primaryBlue),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      showCheckmark: false,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: ink),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFDCE4EE),
      space: 1,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: primaryBlue),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
      bodyLarge: TextStyle(color: ink),
      bodyMedium: TextStyle(color: mutedInk),
      labelLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}
