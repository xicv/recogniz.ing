import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for managing Accessibility permission state
class AccessibilityPermissionNotifier extends Notifier<bool> {
  @override
  bool build() {
    // On macOS, we assume permission is not granted initially
    // This will show the prompt to users
    // Once users grant permission and restart the app, hotkeys should work
    return !Platform.isMacOS;
  }

  /// Refresh the permission state
  Future<void> refresh() async {
    // After user grants permission and restarts, this should return true
    state = !Platform.isMacOS;
  }

  /// Request Accessibility permissions
  /// Returns false since we cannot programmatically grant on macOS
  Future<bool> requestPermission() async {
    // Cannot programmatically grant - user must do it manually
    return false;
  }

  /// Open System Settings to Accessibility section
  /// Returns false since we cannot programmatically open settings
  Future<void> openSettings() async {
    // User must manually navigate to System Settings
    debugPrint('[AccessibilityPermissionNotifier] Please open: System Settings > Privacy & Security > Accessibility');
  }
}

/// Provider for Accessibility permission state
/// true = permission granted (or not needed on non-macOS), false = permission not granted
final accessibilityPermissionProvider =
    NotifierProvider<AccessibilityPermissionNotifier, bool>(
        AccessibilityPermissionNotifier.new);
