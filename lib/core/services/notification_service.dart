import 'package:flutter/material.dart';
import '../interfaces/audio_service_interface.dart';

class NotificationService implements NotificationServiceInterface {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;
  GlobalKey<NavigatorState>? _contentNavigatorKey;
  GlobalKey<ScaffoldState>? _scaffoldKey;

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  @override
  void setContentNavigatorKey(GlobalKey<NavigatorState> contentNavigatorKey) {
    _contentNavigatorKey = contentNavigatorKey;
  }

  @override
  void setScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey) {
    _scaffoldKey = scaffoldKey;
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
    // Prefer the scaffold key for main content area, then fall back to navigator keys
    if (_scaffoldKey?.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey!.currentContext!).clearSnackBars();
    } else {
      final context = _contentNavigatorKey?.currentContext ?? _navigatorKey?.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    // Prefer the scaffold key for main content area, then fall back to navigator keys
    BuildContext? context;
    if (_scaffoldKey?.currentContext != null) {
      context = _scaffoldKey!.currentContext;
    } else {
      context = _contentNavigatorKey?.currentContext ?? _navigatorKey?.currentContext;
    }

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
            ScaffoldMessenger.of(context!).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
