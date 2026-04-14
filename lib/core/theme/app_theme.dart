import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class ThemePreference {
  static const String _themeKey = 'theme_mode';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey) ?? 'system';
    return _fromString(value);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _toString(mode));
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseText = GoogleFonts.interTextTheme();
    final headingText = GoogleFonts.poppinsTextTheme();
    final textTheme = baseText.copyWith(
      displayLarge: headingText.displayLarge,
      displayMedium: headingText.displayMedium,
      displaySmall: headingText.displaySmall,
      headlineLarge: headingText.headlineLarge,
      headlineMedium: headingText.headlineMedium,
      headlineSmall: headingText.headlineSmall,
      titleLarge: headingText.titleLarge,
      titleMedium: headingText.titleMedium,
      titleSmall: headingText.titleSmall,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: Color(0xFF111827),
        background: AppColors.lightBackground,
        onBackground: Color(0xFF111827),
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        foregroundColor: Color(0xFF111827),
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dividerColor: AppColors.border,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedText,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final headingText = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    final textTheme = baseText.copyWith(
      displayLarge: headingText.displayLarge,
      displayMedium: headingText.displayMedium,
      displaySmall: headingText.displaySmall,
      headlineLarge: headingText.headlineLarge,
      headlineMedium: headingText.headlineMedium,
      headlineSmall: headingText.headlineSmall,
      titleLarge: headingText.titleLarge,
      titleMedium: headingText.titleMedium,
      titleSmall: headingText.titleSmall,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: Color(0xFFE5E7EB),
        background: AppColors.darkBackground,
        onBackground: Color(0xFFE5E7EB),
        error: Color(0xFFF87171),
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        foregroundColor: Color(0xFFE5E7EB),
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D2D2D)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dividerColor: const Color(0xFF2D2D2D),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedText,
        showUnselectedLabels: true,
      ),
    );
  }
}
