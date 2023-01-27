import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData get dark {
    return _theme(
      primary: Colors.blue,
      // Foreground
      frontForeground: Colors.white,
      middleForeground: Colors.white54,
      rearForeground: Colors.white30,
      // Background
      background: Colors.black,
      frontBackground: Colors.black12,
      middleBackground: Colors.black38,
      rearBackground: Colors.black54,
      // Text
      text: Colors.white,
      subtext: Colors.white30,
    );
  }

  static ThemeData _theme({
    required Color primary,
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
        titleMedium: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 24,
        ),
        bodyMedium: TextStyle(
          color: subtext,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 20,
        ),
      ),
    );
  }

}