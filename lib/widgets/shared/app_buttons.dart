import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Custom-styled buttons for consistent app-wide styling
class AppButtons {
  const AppButtons._();

  /// Primary elevated button with app styling
  static Widget primary({
    required Widget child,
    required VoidCallback? onPressed,
    bool fullWidth = false,
    bool isLoading = false,
    Widget? loadingChild,
    ButtonStyle? style,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? _primaryStyle,
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  if (loadingChild != null) ...[
                    const SizedBox(width: 8),
                    loadingChild,
                  ],
                ],
              )
            : child,
      ),
    );
  }

  /// Secondary button with outlined style
  static Widget secondary({
    required Widget child,
    required VoidCallback? onPressed,
    bool fullWidth = false,
    bool isLoading = false,
    ButtonStyle? style,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? _secondaryStyle,
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  child,
                ],
              )
            : child,
      ),
    );
  }

  /// Text button for tertiary actions
  static Widget text({
    required Widget child,
    required VoidCallback? onPressed,
    bool fullWidth = false,
    Color? color,
    ButtonStyle? style,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: style ?? _textStyle(color),
        child: child,
      ),
    );
  }

  /// Icon button with tooltip support
  static Widget icon({
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    Color? color,
    double? size,
    ButtonStyle? style,
  }) {
    Widget button = IconButton(
      onPressed: onPressed,
      style: style,
      icon: Icon(
        icon,
        color: color,
        size: size,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// Floating action button with consistent styling
  static Widget floating({
    required VoidCallback? onPressed,
    required IconData icon,
    String? tooltip,
    bool mini = false,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    Widget button = FloatingActionButton(
      onPressed: onPressed,
      mini: mini,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Icon(icon),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// Button with dropdown menu
  static Widget dropdown({
    required Widget child,
    required List<PopupMenuEntry<dynamic>> items,
    VoidCallback? onPressed,
    Widget? icon,
    ButtonStyle? style,
  }) {
    return PopupMenuButton<dynamic>(
      child: ElevatedButton(
        onPressed: items.isEmpty ? onPressed : null,
        style: style ?? _primaryStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            if (icon != null) ...[
              const SizedBox(width: 8),
              icon,
            ] else ...[
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronDown, size: 16),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => items,
    );
  }

  /// Default primary button style
  static const ButtonStyle _primaryStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  /// Default secondary button style
  static ButtonStyle get _secondaryStyle => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );

  /// Text button style with optional color
  static ButtonStyle _textStyle(Color? color) => TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );
}

/// Button sizes for consistent dimensions
class ButtonSizes {
  const ButtonSizes._();

  static const double small = 32;
  static const double medium = 40;
  static const double large = 48;

  static const EdgeInsets smallPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const EdgeInsets mediumPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets largePadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );
}
