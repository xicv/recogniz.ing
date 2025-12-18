import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_config.dart';

class AppColors {
  // Primary palette
  static Color primary = const Color(0xFF6366F1);
  static Color primaryLight = const Color(0xFF818CF8);
  static Color primaryDark = const Color(0xFF4F46E5);

  // Accent
  static Color accent = const Color(0xFF22D3EE);
  static Color success = const Color(0xFF10B981);
  static Color warning = const Color(0xFFF59E0B);
  static Color error = const Color(0xFFEF4444);
  static Color info = const Color(0xFF64748B);

  // Neutrals - Light
  static Color backgroundLight = const Color(0xFFF8FAFC);
  static Color surfaceLight = const Color(0xFFFFFFFF);
  static Color textPrimaryLight = const Color(0xFF1E293B);
  static Color textSecondaryLight = const Color(0xFF64748B);

  // Neutrals - Dark
  static Color backgroundDark = const Color(0xFF0F172A);
  static Color surfaceDark = const Color(0xFF1E293B);
  static Color textPrimaryDark = const Color(0xFFF1F5F9);
  static Color textSecondaryDark = const Color(0xFF94A3B8);

  static Future<void> loadColors(String themeName) async {
    final themeConfig = await ThemeConfig.fromAsset(themeName);
    final colors = themeConfig.colors;

    primary = Color(int.parse(colors.primary.replaceFirst('#', '0xFF')));
    primaryLight = Color(int.parse(colors.primaryLight.replaceFirst('#', '0xFF')));
    primaryDark = Color(int.parse(colors.primaryDark.replaceFirst('#', '0xFF')));
    accent = Color(int.parse(colors.accent.replaceFirst('#', '0xFF')));
    success = Color(int.parse(colors.success.replaceFirst('#', '0xFF')));
    warning = Color(int.parse(colors.warning.replaceFirst('#', '0xFF')));
    error = Color(int.parse(colors.error.replaceFirst('#', '0xFF')));
    info = Color(int.parse(colors.info.replaceFirst('#', '0xFF')));
    backgroundLight = Color(int.parse(colors.background.replaceFirst('#', '0xFF')));
    surfaceLight = Color(int.parse(colors.surface.replaceFirst('#', '0xFF')));
    textPrimaryLight = Color(int.parse(colors.textPrimary.replaceFirst('#', '0xFF')));
    textSecondaryLight = Color(int.parse(colors.textSecondary.replaceFirst('#', '0xFF')));
    backgroundDark = Color(int.parse(colors.background.replaceFirst('#', '0xFF')));
    surfaceDark = Color(int.parse(colors.surface.replaceFirst('#', '0xFF')));
    textPrimaryDark = Color(int.parse(colors.textPrimary.replaceFirst('#', '0xFF')));
    textSecondaryDark = Color(int.parse(colors.textSecondary.replaceFirst('#', '0xFF')));
  }
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
