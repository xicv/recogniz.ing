import 'package:flutter/services.dart';

/// Service for providing haptic feedback throughout the app.
///
/// Haptic feedback enhances user experience by providing tactile
/// confirmation of user interactions and system state changes.
///
/// Usage:
/// ```dart
/// await HapticService.lightImpact();
/// await HapticService.success();
/// ```
///
/// Platform Availability:
/// - Android: Full support
/// - iOS: Full support (with system Haptics enabled)
/// - macOS: Limited support (via trackpad)
/// - Windows/Linux: No support (gracefully ignored)
class HapticService {
  /// Platform availability of haptic feedback
  static bool _isAvailable = true;

  /// Initialize the haptic service and check platform availability.
  static Future<void> initialize() async {
    // Test haptic availability
    try {
      await HapticFeedback.mediumImpact();
      // If successful, haptics are available
      _isAvailable = true;
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Check if haptic feedback is available on the current platform.
  static bool get isAvailable => _isAvailable;

  /// Light haptic impact for subtle feedback.
  ///
  /// Use for: light button presses, UI toggles
  static Future<void> lightImpact() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Medium haptic impact for standard feedback.
  ///
  /// Use for: button presses, confirmations
  static Future<void> mediumImpact() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Heavy haptic impact for significant feedback.
  ///
  /// Use for: destructive actions, major state changes
  static Future<void> heavyImpact() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Success haptic feedback pattern.
  ///
  /// Use for: completed actions, successful operations
  static Future<void> success() async {
    if (!_isAvailable) return;
    try {
      // Notification feedback with success type
      await HapticFeedback.notificationFeedback(
        NotificationFeedbackType.success,
      );
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Warning haptic feedback pattern.
  ///
  /// Use for: warnings, caution scenarios
  static Future<void> warning() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.notificationFeedback(
        NotificationFeedbackType.warning,
      );
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Error haptic feedback pattern.
  ///
  /// Use for: errors, failed operations
  static Future<void> error() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.notificationFeedback(
        NotificationFeedbackType.error,
      );
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Selection tick feedback.
  ///
  /// Use for: scrolling, selection changes
  static Future<void> selectionTick() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Virtual keyboard key press feedback.
  ///
  /// Use for: key presses in custom keyboards
  static Future<void> keyPress() async {
    if (!_isAvailable) return;
    try {
      await HapticFeedback.keyboardPress();
    } catch (_) {
      _isAvailable = false;
    }
  }

  /// Start recording feedback pattern.
  ///
  /// Medium impact followed by selection tick
  static Future<void> startRecording() async {
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await selectionTick();
  }

  /// Stop recording feedback pattern.
  ///
  /// Success feedback pattern
  static Future<void> stopRecording() async {
    await success();
  }

  /// Speech detected feedback.
  ///
  /// Light impact for real-time feedback during recording
  static Future<void> speechDetected() async {
    await lightImpact();
  }
}
