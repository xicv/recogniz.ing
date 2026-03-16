import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/accessibility_permission_service.dart';

/// Notifier for managing Accessibility permission state
///
/// On macOS, polls AXIsProcessTrusted() every 3 seconds until permission
/// is granted, then stops polling. On other platforms, always returns true.
///
/// Supports manual dismissal for cases where AXIsProcessTrusted() returns
/// false despite the permission being granted (e.g., ad-hoc signed builds
/// where TCC code signing requirement matching is unreliable).
class AccessibilityPermissionNotifier extends Notifier<bool> {
  Timer? _pollTimer;
  bool _manuallyDismissed = false;

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
    if (_manuallyDismissed) {
      state = true;
      return;
    }

    final granted = await AccessibilityPermissionService.checkPermission();
    state = granted;

    if (!granted) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_manuallyDismissed) {
        state = true;
        _pollTimer?.cancel();
        _pollTimer = null;
        return;
      }

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
    state = granted || _manuallyDismissed;

    if (state) {
      _pollTimer?.cancel();
      _pollTimer = null;
    } else if (_pollTimer == null || !_pollTimer!.isActive) {
      _startPolling();
    }
  }

  /// Manually dismiss the permission prompt
  ///
  /// Used when the user has verified they granted the permission but
  /// AXIsProcessTrusted() still returns false (common with ad-hoc signed
  /// builds where the TCC code signing check is unreliable).
  void dismiss() {
    _manuallyDismissed = true;
    state = true;
    _pollTimer?.cancel();
    _pollTimer = null;
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
