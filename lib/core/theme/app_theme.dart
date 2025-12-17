import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);

  // Accent
  static const accent = Color(0xFF22D3EE);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Neutrals - Light
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF1E293B);
  static const textSecondaryLight = Color(0xFF64748B);

  // Neutrals - Dark
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);
}

class AppTheme {
  static final _baseTextTheme = GoogleFonts.interTextTheme();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.surfaceLight,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: _baseTextTheme.apply(
          bodyColor: AppColors.textPrimaryLight,
          displayColor: AppColors.textPrimaryLight,
        ),
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimaryDark,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: _baseTextTheme
            .apply(
              bodyColor: AppColors.textPrimaryDark,
              displayColor: AppColors.textPrimaryDark,
            )
            .copyWith(
              headlineLarge: _baseTextTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w700,
              ),
              headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: _baseTextTheme.titleLarge?.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              titleMedium: _baseTextTheme.titleMedium?.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              titleSmall: _baseTextTheme.titleSmall?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              bodySmall: _baseTextTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              labelLarge: _baseTextTheme.labelLarge?.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.surfaceDark,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: AppColors.textPrimaryDark,
          subtitleTextStyle: TextStyle(color: AppColors.textSecondaryDark),
          iconColor: AppColors.textSecondaryDark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
          hintStyle:
              TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.7)),
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
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondaryDark,
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
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          indicatorColor: AppColors.primary.withOpacity(0.2),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppColors.primaryLight);
            }
            return const IconThemeData(color: AppColors.textSecondaryDark);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                  color: AppColors.primaryLight, fontSize: 12);
            }
            return const TextStyle(
                color: AppColors.textSecondaryDark, fontSize: 12);
          }),
        ),
      );
}
