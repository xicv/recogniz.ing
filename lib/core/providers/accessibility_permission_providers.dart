import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/accessibility_permission_service.dart';

/// Notifier for managing Accessibility permission state
///
/// On macOS, polls AXIsProcessTrusted() every 3 seconds until permission
/// is granted, then stops polling. On other platforms, always returns true.
class AccessibilityPermissionNotifier extends Notifier<bool> {
  Timer? _pollTimer;

  @override
  bool build() {
    if (!Platform.isMacOS) return true;

    // Check immediately, then poll if not granted
    _checkAndPoll();

    ref.onDispose(() {
      _pollTimer?.cancel();
    });

    // Start with false; async check will update state
    return false;
  }

  Future<void> _checkAndPoll() async {
    final granted = await AccessibilityPermissionService.checkPermission();
    state = granted;

    if (!granted) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final granted = await AccessibilityPermissionService.checkPermission();
      if (granted) {
        state = true;
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    });
  }

  /// Manually re-check the permission state
  Future<void> refresh() async {
    final granted = await AccessibilityPermissionService.checkPermission();
    state = granted;

    if (granted) {
      _pollTimer?.cancel();
      _pollTimer = null;
    } else if (_pollTimer == null || !_pollTimer!.isActive) {
      _startPolling();
    }
  }

  /// Open System Settings to Accessibility section
  Future<void> openSettings() async {
    await AccessibilityPermissionService.openSettings();
  }
}

/// Provider for Accessibility permission state
/// true = permission granted (or not needed on non-macOS), false = permission not granted
final accessibilityPermissionProvider =
    NotifierProvider<AccessibilityPermissionNotifier, bool>(
        AccessibilityPermissionNotifier.new);
