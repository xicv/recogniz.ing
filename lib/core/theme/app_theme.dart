import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_config.dart';

// Material 3 tonal palette default dark surfaces
// Reference: https://m3.material.io/styles/color/the-color-system/tokens
const _md3DarkBackground = Color(0xFF1C1B1F);
const _md3DarkSurface = Color(0xFF2B2930);
const _md3DarkSurfaceVariant = Color(0xFF49454F);

class AppColors {
  // Primary palette (kept for theme config compatibility)
  static Color primary = const Color(0xFF6366F1);
  static Color primaryLight = const Color(0xFF818CF8);
  static Color primaryDark = const Color(0xFF4F46E5);

  // Accent colors
  static Color accent = const Color(0xFF22D3EE);
  static Color success = const Color(0xFF10B981);
  static Color warning = const Color(0xFFF59E0B);
  static Color error = const Color(0xFFEF4444);
  static Color info = const Color(0xFF64748B);

  // Neutrals - Light (for reference, Material 3 generates these)
  static Color backgroundLight = const Color(0xFFF8FAFC);
  static Color surfaceLight = const Color(0xFFFFFFFF);
  static Color textPrimaryLight = const Color(0xFF1E293B);
  static Color textSecondaryLight = const Color(0xFF64748B);

  // Neutrals - Dark (updated to Material 3 defaults for better eye comfort)
  static Color backgroundDark = _md3DarkBackground;
  static Color surfaceDark = _md3DarkSurface;
  static Color textPrimaryDark = const Color(0xFFE6E1E5);
  static Color textSecondaryDark = const Color(0xFFCAC4D0);

  static Future<void> loadColors(String themeName) async {
    final themeConfig = await ThemeConfig.fromAsset(themeName);
    final colors = themeConfig.colors;

    primary = Color(int.parse(colors.primary.replaceFirst('#', '0xFF')));
    primaryLight =
        Color(int.parse(colors.primaryLight.replaceFirst('#', '0xFF')));
    primaryDark =
        Color(int.parse(colors.primaryDark.replaceFirst('#', '0xFF')));
    accent = Color(int.parse(colors.accent.replaceFirst('#', '0xFF')));
    success = Color(int.parse(colors.success.replaceFirst('#', '0xFF')));
    warning = Color(int.parse(colors.warning.replaceFirst('#', '0xFF')));
    error = Color(int.parse(colors.error.replaceFirst('#', '0xFF')));
    info = Color(int.parse(colors.info.replaceFirst('#', '0xFF')));
    backgroundLight =
        Color(int.parse(colors.background.replaceFirst('#', '0xFF')));
    surfaceLight = Color(int.parse(colors.surface.replaceFirst('#', '0xFF')));
    textPrimaryLight =
        Color(int.parse(colors.textPrimary.replaceFirst('#', '0xFF')));
    textSecondaryLight =
        Color(int.parse(colors.textSecondary.replaceFirst('#', '0xFF')));
    backgroundDark =
        Color(int.parse(colors.background.replaceFirst('#', '0xFF')));
    surfaceDark = Color(int.parse(colors.surface.replaceFirst('#', '0xFF')));
    textPrimaryDark =
        Color(int.parse(colors.textPrimary.replaceFirst('#', '0xFF')));
    textSecondaryDark =
        Color(int.parse(colors.textSecondary.replaceFirst('#', '0xFF')));
  }
}

/// App theme using Material 3 design system.
///
/// This implementation leverages ColorScheme.fromSeed() to automatically
/// generate tonal palettes that ensure accessibility and visual harmony.
/// The seed color creates a complete color scheme including primary,
/// secondary, tertiary, surface, and error colors with proper contrast ratios.
///
/// Material Design 3 Principles Applied:
/// - Dynamic color generation from seed
/// - Surface tonal variation (surface, surfaceContainer, surfaceVariant)
/// - Proper elevation through surface tint colors
/// - Accessibility-compliant contrast ratios
class AppTheme {
  /// Light theme with Material 3 dynamic color scheme.
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(GoogleFonts.interTextTheme(base.textTheme), colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      inputDecorationTheme: _buildInputTheme(colorScheme, Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, Brightness.light),
      navigationDrawerTheme: _buildNavigationDrawerTheme(colorScheme, Brightness.light),
    );
  }

  /// Dark theme with Material 3 dynamic color scheme.
  ///
  /// Uses softer dark surfaces (#1C1B1F, #2B2930) instead of pure black
  /// for better eye comfort during extended use. These colors follow
  /// Material 3's recommended dark surface tones.
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _md3DarkBackground,
      textTheme: _buildTextTheme(GoogleFonts.interTextTheme(base.textTheme), colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      inputDecorationTheme: _buildInputTheme(colorScheme, Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, Brightness.dark),
      navigationDrawerTheme: _buildNavigationDrawerTheme(colorScheme, Brightness.dark),
    );
  }

  /// Builds text theme with consistent color mapping to ColorScheme.
  static TextTheme _buildTextTheme(TextTheme base, ColorScheme colorScheme) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: colorScheme.onSurface),
      displayMedium: base.displayMedium?.copyWith(color: colorScheme.onSurface),
      displaySmall: base.displaySmall?.copyWith(color: colorScheme.onSurface),
      headlineLarge: base.headlineLarge?.copyWith(color: colorScheme.onSurface),
      headlineMedium: base.headlineMedium?.copyWith(color: colorScheme.onSurface),
      headlineSmall: base.headlineSmall?.copyWith(color: colorScheme.onSurface),
      titleLarge: base.titleLarge?.copyWith(color: colorScheme.onSurface),
      titleMedium: base.titleMedium?.copyWith(color: colorScheme.onSurface),
      titleSmall: base.titleSmall?.copyWith(color: colorScheme.onSurface),
      bodyLarge: base.bodyLarge?.copyWith(color: colorScheme.onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: colorScheme.onSurface),
      bodySmall: base.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(color: colorScheme.onSurface),
      labelMedium: base.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: base.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  /// Builds card theme using surfaceContainerLow for subtle elevation.
  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: colorScheme.surfaceContainerLow,
    );
  }

  /// Builds input decoration theme using color scheme tokens.
  static InputDecorationTheme _buildInputTheme(ColorScheme colorScheme, Brightness brightness) {
    final outlineColor = brightness == Brightness.dark
        ? colorScheme.outlineVariant
        : Colors.grey.shade300;

    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  /// Builds elevated button theme using color scheme tokens.
  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Builds navigation bar theme for bottom navigation (if used).
  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: colorScheme.onSurface);
        }
        return TextStyle(color: colorScheme.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onSecondaryContainer);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  /// Builds navigation drawer theme with proper surface colors.
  static NavigationDrawerThemeData _buildNavigationDrawerTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return NavigationDrawerThemeData(
      backgroundColor: brightness == Brightness.dark
          ? _md3DarkSurface
          : colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
    );
  }
}
