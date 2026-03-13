import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart wrapper for the native auto-inject service.
///
/// Detects whether the user's cursor is in a text input field and can
/// inject text directly via simulated Cmd+V paste. Falls back gracefully
/// on non-macOS platforms.
class AutoInjectService {
  static const _channel = MethodChannel('com.recognizing.app/autoinject');

  /// Check if the currently focused UI element in any app is a text input.
  ///
  /// Returns true if the focused element is a text field, text area,
  /// combo box, search field, or web area. Returns false if no text input
  /// is focused or if accessibility permission is missing.
  Future<bool> isTextInputFocused() async {
    try {
      final result = await _channel.invokeMethod<bool>('isTextInputFocused');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoInjectService] Failed to check text input focus: $e');
      }
      return false;
    }
  }

  /// Inject text into the currently focused text input.
  ///
  /// Sets the clipboard to [text], simulates Cmd+V, then restores the
  /// previous clipboard contents after a short delay (~150ms).
  Future<void> injectText(String text) async {
    try {
      await _channel.invokeMethod('injectText', text);
      if (kDebugMode) {
        debugPrint('[AutoInjectService] Text injected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoInjectService] Failed to inject text: $e');
      }
    }
  }
}
