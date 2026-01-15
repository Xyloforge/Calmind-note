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
  yellow('SunGlow', Color(0xFFFFD52E));

  const AppAccentColor(this.label, this.color);
  final String label;
  final Color color;
}

class AppTheme {
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

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
        textTheme: const CupertinoTextThemeData(
          navTitleTextStyle: TextStyle(
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
    // Standard iOS Gray for secondary text/icons
    const Color iosSecondaryGray = Color(0xFF8E8E93);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black, // Pure Black
      primaryColor: accent.color,

      // Manual ColorScheme to prevent "auto-mixing" tints
      colorScheme: ColorScheme.dark(
        primary: accent.color,
        surface: Colors.black,
        onSurface: Colors.white,
        secondary: iosSecondaryGray,
      ),

      // Global Icon Theme (Sets all icons to your accent color)
      iconTheme: IconThemeData(color: accent.color),

      // Text Theme: White for primary, Gray for secondary
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white), // Primary text
        bodyMedium: TextStyle(color: Colors.white), // Secondary text
        bodySmall: TextStyle(
          color: Color.fromARGB(255, 210, 208, 208),
        ), // Tertiary text
        titleLarge: TextStyle(color: Colors.white),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: accent.color, // AppBar is full accent color
        elevation: 0,
        centerTitle: true,
        // Icons inside AppBar are usually white for contrast against the accent background
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),

      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: accent.color,
        barBackgroundColor: accent.color,
        scaffoldBackgroundColor: Colors.black,
        textTheme: CupertinoTextThemeData(
          primaryColor: accent.color,
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'SF Pro Display',
          ),
          navTitleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      dividerColor: const Color(0xFF38383A), // Apple style divider
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
          ? const Color.fromARGB(255, 0, 0, 0)
          : const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
