import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData get light {
    return _theme(
      primary: Colors.blue,
      errorPrimary: Colors.red,
      errorSecondary: Colors.red[300] ?? Colors.redAccent,
      // Foreground
      frontForeground: Colors.black87,
      middleForeground: Colors.black54,
      rearForeground: Colors.black38,
      // Background
      background: Colors.white,
      frontBackground: Colors.white60,
      middleBackground: Colors.white54,
      rearBackground: Colors.white38,
      // Text
      text: Colors.black87,
      subtext: Colors.black26,
      // AppBar
    );
  }

  static ThemeData get dark {
    return _theme(
      primary: Colors.blue,
      errorPrimary: Colors.red,
      errorSecondary: Colors.red[300] ?? Colors.redAccent,
      // Foreground
      frontForeground: Colors.white,
      middleForeground: Colors.grey[400] ?? Colors.white,
      rearForeground: Colors.grey[600] ?? Colors.white,
      // Background
      background: Colors.black,
      frontBackground: Colors.grey[800] ?? Colors.grey,
      middleBackground: Colors.grey[850] ?? Colors.grey,
      rearBackground: Colors.grey[900] ?? Colors.grey,
      // Text
      text: Colors.white,
      subtext: Colors.grey[400] ?? Colors.white,
    );
  }

  static ThemeData _theme({
    // Base
    required Color primary,
    required Color errorPrimary,
    required Color errorSecondary,
    // Foreground
    required Color frontForeground,
    required Color middleForeground,
    required Color rearForeground,
    // Background
    required Color background,
    required Color frontBackground,
    required Color middleBackground,
    required Color rearBackground,
    // Text
    required Color text,
    required Color subtext,
  }) {
    return ThemeData(
      // Color
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Text
      textTheme: TextTheme(
        // Display
        displayLarge: TextStyle(
          color: text,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        // Title
        titleLarge: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: subtext,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
          //height: 24,
        ),
        // Body
        bodyMedium: TextStyle(
          color: subtext,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: subtext,
          fontSize: 11,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
      ),
      // TextField
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: middleForeground,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: middleForeground,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorPrimary,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primary,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorSecondary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: rearForeground,
            width: 2,
          ),
        ),
      ),
      // Card
      cardTheme: CardTheme(
        color: rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(text),
        ),
      ),
    );
  }

}