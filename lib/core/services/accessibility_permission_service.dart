import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for managing macOS Accessibility permissions
///
/// Global hotkeys on macOS require Accessibility permissions.
/// Uses a native MethodChannel to check AXIsProcessTrusted() and
/// open System Settings to the Accessibility pane.
class AccessibilityPermissionService {
  static const _channel = MethodChannel('com.recognizing.app/accessibility');

  /// Check if the app has Accessibility permissions
  ///
  /// Calls AXIsProcessTrusted() on macOS via MethodChannel.
  /// Returns true on non-macOS platforms.
  static Future<bool> checkPermission() async {
    if (!Platform.isMacOS) return true;

    try {
      final result = await _channel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('[AccessibilityPermissionService] Permission check failed: $e');
      return false;
    }
  }

  /// Open System Settings to the Accessibility section
  ///
  /// Opens the macOS Privacy & Security > Accessibility pane directly.
  static Future<void> openSettings() async {
    if (!Platform.isMacOS) return;

    try {
      await _channel.invokeMethod<void>('openSettings');
    } catch (e) {
      debugPrint('[AccessibilityPermissionService] Failed to open settings: $e');
    }
  }
}
