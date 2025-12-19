import 'package:flutter/material.dart';
import '../interfaces/audio_service_interface.dart';

class NotificationService implements NotificationServiceInterface {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  @override
  void showError(String message) {
    _showSnackBar(message, isError: true);
  }

  @override
  void showSuccess(String message) {
    _showSnackBar(message, isError: false);
  }

  @override
  void clearError() {
    // Clear any existing snackbars
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
