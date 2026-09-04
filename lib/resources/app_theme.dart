import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/strings.dart';

class AppTheme {
  static const Color _darkScaffold = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);
  static const Color _darkInputFill = Color(0xFF2C2C2C);
  static const Color _darkTile = Color(0xFF2C2C2C);

  static ThemeData get light {
    const onSurface = Colors.black;
    const onSurfaceVariant = Colors.black54;

    return ThemeData(
      fontFamily: kInter,
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: kAppPrimaryColor,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: kAppPrimaryColor,
        circularTrackColor: Color(0xFFE0E0E0),
        linearTrackColor: Color(0xFFE0E0E0),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kAppPrimaryColor,
        selectionColor: Color(0x40191A48),
        selectionHandleColor: kAppPrimaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: kAppPrimaryColor,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: kAppPrimaryColor),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        selectedLabelStyle: TextStyle(color: kAppPrimaryColor),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      dividerColor: Colors.black12,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAppPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kAppPrimaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: onSurface),
        bodyLarge: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: onSurfaceVariant),
      ),
      colorScheme: const ColorScheme.light(
        primary: kAppPrimaryColor,
        secondary: kAppPrimaryColor,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: Colors.grey,
        surfaceContainerHighest: kBoxColor,
      ),
    );
  }

  static ThemeData get dark {
    const onSurface = Colors.white;
    const onSurfaceVariant = Colors.white70;

    return ThemeData(
      fontFamily: kInter,
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: kAppPrimaryColor,
      scaffoldBackgroundColor: _darkScaffold,
      cardColor: _darkCard,
      dialogTheme: const DialogThemeData(
        backgroundColor: _darkCard,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
        circularTrackColor: Colors.white24,
        linearTrackColor: Colors.white24,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x40FFFFFF),
        selectionHandleColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkScaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkScaffold,
        selectedItemColor: kAppPrimaryColor,
        unselectedItemColor: Colors.white70,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white70),
        selectedLabelStyle: TextStyle(color: kAppPrimaryColor),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerColor: Colors.white24,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAppPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kAppPrimaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: onSurface),
        bodyLarge: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: onSurfaceVariant),
      ),
      colorScheme: const ColorScheme.dark(
        primary: kAppPrimaryColor,
        secondary: kAppPrimaryColor,
        surface: _darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: Colors.white54,
        surfaceContainerHighest: _darkTile,
      ),
    );
  }
}
