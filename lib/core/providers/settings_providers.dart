import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';

/// Settings state management
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Get initial settings with fallback
AppSettings _getInitialSettings() {
  try {
    return StorageService.settings;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[SettingsNotifier] Failed to load settings: $e');
    }
    return AppSettings();
  }
}

/// Notifier for managing app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(_getInitialSettings());

  Future<void> updateApiKey(String apiKey) async {
    final newState = state.copyWith(geminiApiKey: apiKey);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> updateSelectedPrompt(String promptId) async {
    final newState = state.copyWith(selectedPromptId: promptId);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> updateSelectedVocabulary(String vocabularyId) async {
    final newState = state.copyWith(selectedVocabularyId: vocabularyId);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> updateHotkey(String hotkey) async {
    final newState = state.copyWith(globalHotkey: hotkey);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> toggleAutoCopy() async {
    final newState =
        state.copyWith(autoCopyToClipboard: !state.autoCopyToClipboard);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> toggleNotifications() async {
    final newState =
        state.copyWith(showNotifications: !state.showNotifications);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> toggleDarkMode() async {
    final newState = state.copyWith(darkMode: !state.darkMode);
    await StorageService.saveSettings(newState);
    state = newState;
  }

  Future<void> updateCriticalInstructions(String instructions) async {
    final newState = state.copyWith(criticalInstructions: instructions);
    await StorageService.saveSettings(newState);
    state = newState;
  }
}
