import 'package:flutter/material.dart';

/// Custom-styled cards for consistent app-wide styling
class AppCards {
  const AppCards._();

  /// Standard card with optional header and actions
  static Widget basic({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    VoidCallback? onTap,
  }) {
    Widget card = Card(
      margin: margin ?? const EdgeInsets.all(8),
      color: color,
      elevation: elevation,
      shape: shape,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }

  /// Card with header section
  static Widget withHeader({
    required Widget header,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    List<Widget>? actions,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.all(8),
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: header),
                if (actions != null) ...actions,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Interactive card with hover and tap effects
  static Widget interactive({
    required Widget child,
    required VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    Color? hoverColor,
    double? elevation,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: hoverColor ?? Theme.of(CardGet.context!!).hoverColor,
        child: Card(
          margin: margin ?? const EdgeInsets.all(8),
          color: color,
          elevation: elevation,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Card for displaying status or information
  static Widget info({
    required Widget child,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.all(8),
      color: backgroundColor ?? Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// Card for displaying warnings
  static Widget warning({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return info(
      child: child,
      icon: Icons.warning_outlined,
      iconColor: Colors.orange,
      backgroundColor: Colors.orange.withOpacity(0.1),
      margin: margin,
      padding: padding,
    );
  }

  /// Card for displaying errors
  static Widget error({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return info(
      child: child,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      backgroundColor: Colors.red.withOpacity(0.1),
      margin: margin,
      padding: padding,
    );
  }

  /// Card for displaying success messages
  static Widget success({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return info(
      child: child,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.1),
      margin: margin,
      padding: padding,
    );
  }
}

/// Extension to get context easily
extension CardGet on Widget {
  static BuildContext? _context;

  static BuildContext? get context => _context;

  static void setContext(BuildContext context) => _context = context;
}