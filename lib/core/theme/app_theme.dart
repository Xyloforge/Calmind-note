import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppAccentColor {
  blue('Blue', Colors.blue),
  purple('Purple', Colors.purple),
  green('Green', Colors.green),
  orange('Orange', Colors.orange),
  pink('Pink', Colors.pink),
  red('Red', Colors.red),
  teal('Teal', Colors.teal),
  yellow('Yellow', Colors.yellow);

  const AppAccentColor(this.label, this.color);
  final String label;
  final Color color;
}

class AppTheme {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightTheme(AppAccentColor accent) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent.color,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(
        0xFFF2F2F7,
      ), // iOS grouped background
      primaryColor: accent.color,
      focusColor: _lightFocusColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: accent.color,
        barBackgroundColor: Colors.white,
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          textStyle: TextStyle(
            color: Colors.black,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
      dividerColor: Colors.grey[300],
    );
  }

  static ThemeData darkTheme(AppAccentColor accent) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent.color,
        brightness: Brightness.dark,
        background: Colors.black, // True dark
      ),
      scaffoldBackgroundColor: const Color(0xFF000000), // True dark
      primaryColor: accent.color,
      focusColor: _darkFocusColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(
          0xFF1C1C1E,
        ), // iOS Dark grouped background variant or just black
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: accent.color,
        barBackgroundColor: const Color(0xFF1C1C1E),
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
      dividerColor: const Color(0xFF38383A),
    );
  }
}

class AppColors {
  final Color toolbarBackground;

  const AppColors({required this.toolbarBackground});
}

extension AppThemeExtension on ThemeData {
  AppColors get appColors {
    final isDark = brightness == Brightness.dark;
    return AppColors(
      toolbarBackground: isDark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFF9F9F9),
    );
  }
}
