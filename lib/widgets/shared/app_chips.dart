import 'package:flutter/material.dart';

/// Custom chip widgets for consistent app-wide styling
class AppChips {
  const AppChips._();

  /// Standard action chip
  static Widget action({
    required Widget label,
    VoidCallback? onPressed,
    Widget? avatar,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ActionChip(
      label: label,
      onPressed: onPressed,
      avatar: avatar,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: foregroundColor,
      ),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Choice chip for selection from a set
  static Widget choice({
    required BuildContext context,
    required Widget label,
    required bool selected,
    required ValueChanged<bool>? onSelected,
    Widget? avatar,
    Color? selectedColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
      selectedColor: selectedColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Filter chip for filtering content
  static Widget filter({
    required BuildContext context,
    required Widget label,
    required bool selected,
    required ValueChanged<bool>? onSelected,
    Widget? avatar,
    Color? selectedColor,
    EdgeInsetsGeometry? padding,
  }) {
    return FilterChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
      selectedColor: selectedColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Input chip for representing a piece of information
  static Widget input({
    required Widget label,
    VoidCallback? onPressed,
    VoidCallback? onDeleted,
    Widget? avatar,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return InputChip(
      label: label,
      onPressed: onPressed,
      onDeleted: onDeleted,
      avatar: avatar,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: foregroundColor,
      ),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 18) : null,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Status chip for displaying status information
  static Widget status({
    required BuildContext context,
    required String label,
    required ChipStatus status,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final config = _StatusConfig.fromStatus(status, theme);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: 14,
            color: config.color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge chip for showing counts
  static Widget badge({
    required BuildContext context,
    required String count,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// Quick action chip with icon
  static Widget quickAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: foregroundColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 13,
        ),
      ),
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// Enum for chip status types
enum ChipStatus {
  active,
  inactive,
  pending,
  success,
  error,
  warning,
}

/// Configuration for status chips
class _StatusConfig {
  final Color color;
  final IconData icon;

  const _StatusConfig({
    required this.color,
    required this.icon,
  });

  static _StatusConfig fromStatus(ChipStatus status, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    switch (status) {
      case ChipStatus.active:
        return _StatusConfig(
          color: colorScheme.primary,
          icon: Icons.check_circle,
        );
      case ChipStatus.inactive:
        return _StatusConfig(
          color: colorScheme.outline,
          icon: Icons.cancel,
        );
      case ChipStatus.pending:
        return _StatusConfig(
          color: colorScheme.secondary,
          icon: Icons.access_time,
        );
      case ChipStatus.success:
        return _StatusConfig(
          color: colorScheme.tertiary,
          icon: Icons.check_circle,
        );
      case ChipStatus.error:
        return _StatusConfig(
          color: colorScheme.error,
          icon: Icons.error,
        );
      case ChipStatus.warning:
        return _StatusConfig(
          color: colorScheme.error,
          icon: Icons.warning,
        );
    }
  }
}
