import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// APP COLORS - Static color palette for compatibility
// ============================================================

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
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static Color textPrimaryDark = const Color(0xFFE6E1E5);
  static Color textSecondaryDark = const Color(0xFFCAC4D0);
}

/// Enhanced theme system for Recogniz.ing 1.1.0
///
/// Design principles:
/// - Müller-Brockmann: Mathematical grid, objective color, hierarchy through scale
/// - Dieter Rams: Less but better, functional clarity, honest feedback
///
/// Material Design 3 compliance:
/// - Dynamic color generation from seed
/// - Surface tonal variation (surface, surfaceContainer, surfaceVariant)
/// - Accessibility-compliant contrast ratios (WCAG AAA: 7:1 minimum)
/// - Elevation through surface tint colors

class AppTheme {
  // ============================================================
  // COLOR PALETTE - Refined for visual comfort and accessibility
  // ============================================================

  /// Seed color for dynamic theme generation
  /// Using a refined indigo with better color harmony
  static const Color _seedColor = Color(0xFF6366F1);

  /// Foundation colors - Light mode
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _backgroundLight = Color(0xFFF8FAFC);

  /// Foundation colors - Dark mode
  /// Using MD3 recommended dark surfaces for eye comfort
  static const Color _surfaceDark = Color(0xFF1C1B1F);
  static const Color _backgroundDark = Color(0xFF121212); // OLED-friendly

  // ============================================================
  // BORDER RADIUS - Consistent rounded corners
  // ============================================================

  /// Consistent border radius values following Material 3 guidelines
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusFull = 9999.0; // Pill shape

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF22D3EE),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundLight,

      // Typography with Inter font
      textTheme: _buildTextTheme(base.textTheme, colorScheme, Brightness.light),

      // Card theme with elevation through surface tint
      cardTheme: _buildCardTheme(colorScheme, Brightness.light),

      // Input theme with clear focus states
      inputDecorationTheme: _buildInputTheme(colorScheme, Brightness.light),

      // Button themes
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      iconButtonTheme: _buildIconButtonTheme(colorScheme),

      // Navigation themes
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, Brightness.light),
      navigationDrawerTheme: _buildNavigationDrawerTheme(colorScheme, Brightness.light),

      // Other components
      dividerTheme: _buildDividerTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme, Brightness.light),
      snackBarTheme: _buildSnackBarTheme(colorScheme, Brightness.light),
      dialogTheme: _buildDialogTheme(colorScheme, Brightness.light),

      // Accessibility
      visualDensity: VisualDensity.standard,
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8), // Lighter for dark mode
      secondary: const Color(0xFF67E8F9), // Lighter for dark mode
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundDark,

      // Typography with Inter font
      textTheme: _buildTextTheme(base.textTheme, colorScheme, Brightness.dark),

      // Card theme with elevation through surface tint
      cardTheme: _buildCardTheme(colorScheme, Brightness.dark),

      // Input theme with clear focus states
      inputDecorationTheme: _buildInputTheme(colorScheme, Brightness.dark),

      // Button themes
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      iconButtonTheme: _buildIconButtonTheme(colorScheme),

      // Navigation themes
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, Brightness.dark),
      navigationDrawerTheme: _buildNavigationDrawerTheme(colorScheme, Brightness.dark),

      // Other components
      dividerTheme: _buildDividerTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme, Brightness.dark),
      snackBarTheme: _buildSnackBarTheme(colorScheme, Brightness.dark),
      dialogTheme: _buildDialogTheme(colorScheme, Brightness.dark),

      // Accessibility
      visualDensity: VisualDensity.standard,
    );
  }

  // ============================================================
  // TYPOGRAPHY - Inter font with MD3 type scale
  // ============================================================

  static TextTheme _buildTextTheme(
    TextTheme base,
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final interTextTheme = GoogleFonts.interTextTheme(base);

    // Text colors for WCAG AAA compliance (7:1 minimum)
    final onSurface = brightness == Brightness.dark
        ? const Color(0xFFE4E1E5) // 95% of white
        : const Color(0xFF1C1B1F);
    final onSurfaceVariant = brightness == Brightness.dark
        ? const Color(0xFFCAC4D0)
        : const Color(0xFF49454F);

    return interTextTheme.copyWith(
      // Display styles - reserved for shortest, highest-emphasis text
      displayLarge: interTextTheme.displayLarge?.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: onSurface,
        height: 1.12,
      ),
      displayMedium: interTextTheme.displayMedium?.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.16,
        letterSpacing: -0.2,
      ),
      displaySmall: interTextTheme.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.22,
        letterSpacing: -0.15,
      ),

      // Headline styles - high-emphasis, shorter than body
      headlineLarge: interTextTheme.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.25,
        letterSpacing: -0.1,
      ),
      headlineMedium: interTextTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.29,
        letterSpacing: -0.05,
      ),
      headlineSmall: interTextTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.33,
      ),

      // Title styles - medium-emphasis, shorter than body
      titleLarge: interTextTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: onSurface,
        height: 1.27,
        letterSpacing: 0,
      ),
      titleMedium: interTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: onSurface,
        height: 1.5,
      ),
      titleSmall: interTextTheme.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
        height: 1.43,
      ),

      // Body styles - main content text
      bodyLarge: interTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.6,
        color: onSurface,
      ),
      bodyMedium: interTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
        color: onSurface,
      ),
      bodySmall: interTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
        color: onSurfaceVariant,
      ),

      // Label styles - smaller, utilitarian text
      labelLarge: interTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.29,
        color: onSurface,
      ),
      labelMedium: interTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: onSurfaceVariant,
      ),
      labelSmall: interTextTheme.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
        color: onSurfaceVariant,
      ),
    );
  }

  // ============================================================
  // COMPONENT THEMES
  // ============================================================

  static CardThemeData _buildCardTheme(ColorScheme colorScheme, Brightness brightness) {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      color: colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
    );
  }

  static InputDecorationTheme _buildInputTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final outlineColor = brightness == Brightness.dark
        ? colorScheme.outlineVariant
        : const Color(0xFFE0E0E0);

    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: outlineColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.onPrimary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.onPrimary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.onPrimary.withOpacity(0.12);
          }
          return null;
        }),
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.onPrimary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.onPrimary.withOpacity(0.08);
          }
          return null;
        }),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  static IconButtonThemeData _buildIconButtonTheme(ColorScheme colorScheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant;
        return TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurfaceVariant;
        return IconThemeData(color: color, size: 24);
      }),
    );
  }

  static NavigationDrawerThemeData _buildNavigationDrawerTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return NavigationDrawerThemeData(
      backgroundColor: brightness == Brightness.dark ? _surfaceDark : _surfaceLight,
      surfaceTintColor: colorScheme.surfaceTint,
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant.withOpacity(0.3),
      thickness: 1,
      space: 1,
    );
  }

  static ChipThemeData _buildChipTheme(ColorScheme colorScheme, Brightness brightness) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      side: BorderSide.none,
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF2B2930)
          : const Color(0xFF323232),
      contentTextStyle: TextStyle(
        color: brightness == Brightness.dark ? Colors.white : const Color(0xFFE4E1E5),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    );
  }

  static DialogThemeData _buildDialogTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return DialogThemeData(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      contentTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}

// ============================================================
// STATE COLORS - Multi-channel indication
// ============================================================

/// Recording state colors for accessibility
/// No information conveyed by color alone
class RecordingStateColors {
  const RecordingStateColors._();

  /// Idle state - ready but not listening
  static const Color idle = Color(0xFF6366F1);

  /// Listening state - actively detecting voice
  static const Color listening = Color(0xFF818CF8);

  /// Voice detected state - speech confirmed
  static const Color voiceDetected = Color(0xFF10B981);

  /// Recording state - actively capturing audio
  static const Color recording = Color(0xFF22D3EE);

  /// Processing state - transcribing audio
  static const Color processing = Color(0xFF6366F1);

  /// Error state - something went wrong
  static const Color error = Color(0xFFEF4444);

  /// Get opacity for state indicator (used with primary color)
  static double opacityForState(RecordingStateValue state) {
    switch (state) {
      case RecordingStateValue.idle:
        return 0.4;
      case RecordingStateValue.listening:
        return 0.6;
      case RecordingStateValue.voiceDetected:
        return 1.0;
      case RecordingStateValue.recording:
        return 1.0;
      case RecordingStateValue.processing:
        return 0.6;
    }
  }
}

/// Recording state enum for multi-channel indication
enum RecordingStateValue {
  idle,
  listening,
  voiceDetected,
  recording,
  processing,
}

/// Get human-readable state text
String getStateText(RecordingStateValue state) {
  switch (state) {
    case RecordingStateValue.idle:
      return 'Ready to record';
    case RecordingStateValue.listening:
      return 'Listening for voice...';
    case RecordingStateValue.voiceDetected:
      return 'Voice detected';
    case RecordingStateValue.recording:
      return 'Recording';
    case RecordingStateValue.processing:
      return 'Processing';
  }
}

/// Get icon for state
 IconData getStateIcon(RecordingStateValue state) {
  switch (state) {
    case RecordingStateValue.idle:
      return Icons.mic;
    case RecordingStateValue.listening:
      return Icons.graphic_eq;
    case RecordingStateValue.voiceDetected:
      return Icons.check_circle;
    case RecordingStateValue.recording:
      return Icons.fiber_manual_record;
    case RecordingStateValue.processing:
      return Icons.hourglass_empty;
  }
}
