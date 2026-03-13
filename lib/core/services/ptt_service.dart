import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart wrapper for the native Push-to-Talk event tap service.
///
/// Listens to modifier key press/release events via EventChannel and invokes
/// callbacks when the monitored key is pressed or released. Includes debounce
/// logic to prevent rapid-fire start/stop from quick key tapping.
class PttService {
  static const _eventChannel = EventChannel('com.recognizing.app/ptt');
  static const _methodChannel = MethodChannel('com.recognizing.app/ptt_config');

  StreamSubscription<dynamic>? _subscription;
  VoidCallback? onPttStart;
  VoidCallback? onPttEnd;

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);
  bool _isRecording = false;

  /// Start monitoring the specified PTT key.
  ///
  /// [key] should be one of: 'rightCommand', 'rightOption', 'fn'
  Future<void> startMonitoring(String key) async {
    try {
      await _methodChannel.invokeMethod('setKey', key);
      await _methodChannel.invokeMethod('startMonitoring');

      _subscription = _eventChannel.receiveBroadcastStream().listen(
        _handleEvent,
        onError: (error) {
          if (kDebugMode) {
            debugPrint('[PttService] Stream error: $error');
          }
        },
      );

      if (kDebugMode) {
        debugPrint('[PttService] Started monitoring key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PttService] Failed to start monitoring: $e');
      }
    }
  }

  /// Stop monitoring PTT key events.
  Future<void> stopMonitoring() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    try {
      await _methodChannel.invokeMethod('stopMonitoring');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PttService] Failed to stop monitoring: $e');
      }
    }

    _isRecording = false;

    if (kDebugMode) {
      debugPrint('[PttService] Stopped monitoring');
    }
  }

  /// Update the monitored key without restarting the full monitoring pipeline.
  Future<void> updateKey(String key) async {
    try {
      await _methodChannel.invokeMethod('setKey', key);
      if (kDebugMode) {
        debugPrint('[PttService] Updated monitored key to: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PttService] Failed to update key: $e');
      }
    }
  }

  void _handleEvent(dynamic event) {
    if (event is! String) return;

    switch (event) {
      case 'keyDown':
        if (!_isRecording) {
          // Debounce: ignore rapid key taps
          _debounceTimer?.cancel();
          _debounceTimer = null;
          _isRecording = true;
          if (kDebugMode) {
            debugPrint('[PttService] PTT key down — starting recording');
          }
          onPttStart?.call();
        }
      case 'keyUp':
        if (_isRecording) {
          // Debounce the release to avoid ultra-short recordings
          _debounceTimer?.cancel();
          _debounceTimer = Timer(_debounceDuration, () {
            _isRecording = false;
            if (kDebugMode) {
              debugPrint('[PttService] PTT key up — stopping recording');
            }
            onPttEnd?.call();
          });
        }
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
