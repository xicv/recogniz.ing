import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

/// Service for managing "Start at Login" functionality on desktop platforms.
/// Uses the launch_at_startup package which supports macOS, Windows, and Linux.
class StartAtLoginService {
  static final StartAtLoginService _instance = StartAtLoginService._internal();
  factory StartAtLoginService() => _instance;
  StartAtLoginService._internal();

  bool _isInitialized = false;

  /// Check if the platform supports start at login
  bool get isSupported =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// Initialize the service with app information
  Future<void> initialize() async {
    if (!isSupported || _isInitialized) return;

    try {
      launchAtStartup.setup(
        appName: 'RecognizIng',
        appPath: Platform.resolvedExecutable,
      );
      _isInitialized = true;
      debugPrint('[StartAtLoginService] Initialized');
    } catch (e) {
      debugPrint('[StartAtLoginService] Initialization error: $e');
    }
  }

  /// Enable start at login
  Future<bool> enable() async {
    if (!isSupported) {
      debugPrint('[StartAtLoginService] Platform not supported');
      return false;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await launchAtStartup.enable();
      debugPrint('[StartAtLoginService] Start at login enabled');
      return true;
    } catch (e) {
      debugPrint('[StartAtLoginService] Error enabling: $e');
      return false;
    }
  }

  /// Disable start at login
  Future<bool> disable() async {
    if (!isSupported) {
      debugPrint('[StartAtLoginService] Platform not supported');
      return false;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await launchAtStartup.disable();
      debugPrint('[StartAtLoginService] Start at login disabled');
      return true;
    } catch (e) {
      debugPrint('[StartAtLoginService] Error disabling: $e');
      return false;
    }
  }

  /// Check if start at login is currently enabled
  Future<bool> isEnabled() async {
    if (!isSupported) {
      debugPrint('[StartAtLoginService] Platform not supported');
      return false;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      final enabled = await launchAtStartup.isEnabled();
      debugPrint('[StartAtLoginService] Is enabled: $enabled');
      return enabled;
    } catch (e) {
      debugPrint('[StartAtLoginService] Error checking status: $e');
      return false;
    }
  }

  /// Set start at login state (enable or disable based on the flag)
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      return await enable();
    } else {
      return await disable();
    }
  }
}
