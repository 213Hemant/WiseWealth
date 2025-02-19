import 'package:flutter/material.dart';

class AppTheme {
  // Define color palette
  static const Color primaryBlue = Color(0xFF42A5F5); // Primary Blue for buttons, highlights
  static const Color headingBlue = Color(0xFF1565C0); // Blue for headings, active states, icons
  static const Color secondaryGrey = Color(0xFF757575); // Grey for secondary text, icon labels
  static const Color bodyTextDarkGrey = Color(0xFF333333); // Dark grey for body text
  static const Color whiteTextOnBlue = Color(0xFFFFFFFF); // White text for blue background

  // Define TextTheme
  static TextTheme textTheme = const TextTheme(
  displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: headingBlue), // For main headings
  headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: bodyTextDarkGrey), // For smaller headings
  bodyLarge: TextStyle(fontSize: 16.0, color: bodyTextDarkGrey), // For general body text
  bodyMedium: TextStyle(fontSize: 14.0, color: secondaryGrey), // For secondary text
  labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: whiteTextOnBlue), // For buttons
);


  // Define ThemeData
  static ThemeData themeData = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white, // Text color in AppBar
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
    ).copyWith(
      secondary: headingBlue, // For FABs, toggles, etc.
    ),
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white, // Button text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryBlue),
        foregroundColor: primaryBlue,
      ),
    ),
    iconTheme: const IconThemeData(
      color: headingBlue, // Icon color
      size: 24.0,
    ),
  );
}
