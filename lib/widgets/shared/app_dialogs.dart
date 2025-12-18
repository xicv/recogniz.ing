import 'package:flutter/material.dart';
import 'app_buttons.dart';

/// Custom dialog widgets for consistent app-wide dialogs
class AppDialogs {
  const AppDialogs._();

  /// Show a basic dialog with title, content, and actions
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          AppButtons.text(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          AppButtons.primary(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  /// Show an alert dialog with information
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          AppButtons.primary(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a dialog with custom widget content
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget content,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: content,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: actions ?? [
          AppButtons.text(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog that can't be dismissed
  static void showLoading({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show a bottom sheet with list of options
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required List<Widget> children,
    String? title,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
          ],
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Show a bottom sheet with action items
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required List<BottomSheetAction<T>> actions,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
          ],
          ...actions.map(
            (action) => ListTile(
              leading: action.icon != null ? Icon(action.icon) : null,
              title: Text(action.label),
              onTap: () {
                Navigator.of(context).pop(action.value);
              },
              textColor: action.isDangerous ? Colors.red : null,
              iconColor: action.isDangerous ? Colors.red : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Show a date picker dialog
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  /// Show a time picker dialog
  static Future<TimeOfDay?> showTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: helpText,
    );
  }

  /// Show a simple snackbar
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.error,
      action: action,
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      action: action,
    );
  }
}

/// Represents an action in a bottom sheet
class BottomSheetAction<T> {
  final String label;
  final T value;
  final IconData? icon;
  final bool isDangerous;

  const BottomSheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.isDangerous = false,
  });
}