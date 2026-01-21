import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_key_info.dart';
import '../services/storage_service.dart';

/// Notifier for managing API keys
class ApiKeysNotifier extends Notifier<List<ApiKeyInfo>> {
  @override
  List<ApiKeyInfo> build() {
    // Start with empty list and load asynchronously
    _loadApiKeys();
    return [];
  }

  /// Load API keys from storage
  Future<void> _loadApiKeys() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final settings = StorageService.settings;
      state = settings.apiKeys;

      // Migrate legacy single API key if present
      await _migrateLegacyKey(settings);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiKeysNotifier] Failed to load API keys: $e');
      }
    }
  }

  /// Migrate legacy single API key to new multi-key system
  Future<void> _migrateLegacyKey(dynamic settings) async {
    // Only migrate if we have a legacy key but no keys in the new system
    if (state.isEmpty && settings.geminiApiKey != null && settings.geminiApiKey!.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[ApiKeysNotifier] Migrating legacy API key to new system');
      }
      final newKey = ApiKeyInfo.create(
        name: 'Default Key',
        apiKey: settings.geminiApiKey!,
        isSelected: true,
      );
      await addApiKey(newKey);
    }
  }

  /// Add a new API key
  Future<void> addApiKey(ApiKeyInfo key) async {
    final updatedKeys = [...state, key];
    await _saveApiKeys(updatedKeys);
    state = updatedKeys;
  }

  /// Create and add a new API key from raw values
  Future<void> createApiKey({
    required String name,
    required String apiKey,
    bool isSelected = false,
  }) async {
    final newKey = ApiKeyInfo.create(
      name: name,
      apiKey: apiKey,
      isSelected: isSelected,
    );
    await addApiKey(newKey);
  }

  /// Remove an API key by ID
  Future<void> removeApiKey(String keyId) async {
    final keyToRemove = state.firstWhere((k) => k.id == keyId);
    final wasSelected = keyToRemove.isSelected;

    final updatedKeys = <ApiKeyInfo>[];
    for (final k in state) {
      if (k.id != keyId) {
        updatedKeys.add(k);
      }
    }

    // If we removed the selected key, select another one
    if (wasSelected && updatedKeys.isNotEmpty) {
      // Select the first available key that's not rate limited
      ApiKeyInfo? newSelected;
      for (final k in updatedKeys) {
        if (!k.isRateLimited || k.isRateLimitExpired) {
          newSelected = k;
          break;
        }
      }
      newSelected ??= updatedKeys.first;

      final index = updatedKeys.indexOf(newSelected);
      updatedKeys[index] = newSelected.copyWith(isSelected: true);
    }

    await _saveApiKeys(updatedKeys);
    state = updatedKeys;
  }

  /// Select an API key as the active key
  Future<void> selectApiKey(String keyId) async {
    final updatedKeys = <ApiKeyInfo>[];
    for (final key in state) {
      updatedKeys.add(key.copyWith(isSelected: key.id == keyId));
    }

    await _saveApiKeys(updatedKeys);
    state = updatedKeys;
  }

  /// Mark an API key as rate limited
  Future<void> markRateLimited(String keyId) async {
    ApiKeyInfo? targetKey;
    int targetIndex = -1;

    for (int i = 0; i < state.length; i++) {
      if (state[i].id == keyId) {
        targetKey = state[i];
        targetIndex = i;
        break;
      }
    }

    if (targetIndex == -1) return;

    final updatedKeys = <ApiKeyInfo>[...state];
    updatedKeys[targetIndex] = targetKey!.copyWith(
      rateLimitedAt: DateTime.now(),
      isSelected: false,
    );

    // Try to select another available key
    ApiKeyInfo? alternativeKey;
    for (final k in updatedKeys) {
      if (k.id != keyId && (!k.isRateLimited || k.isRateLimitExpired)) {
        alternativeKey = k;
        break;
      }
    }

    if (alternativeKey != null) {
      final altIndex = updatedKeys.indexOf(alternativeKey);
      updatedKeys[altIndex] = alternativeKey.copyWith(isSelected: true);
    }

    await _saveApiKeys(updatedKeys);
    state = updatedKeys;
  }

  /// Clear rate limit status for an API key
  Future<void> clearRateLimit(String keyId) async {
    final updatedKeys = <ApiKeyInfo>[...state];
    for (int i = 0; i < updatedKeys.length; i++) {
      if (updatedKeys[i].id == keyId) {
        updatedKeys[i] = updatedKeys[i].copyWith(clearRateLimit: true);
        break;
      }
    }

    await _saveApiKeys(updatedKeys);
    state = updatedKeys;
  }

  /// Update an API key's name
  Future<void> updateKeyName(String keyId, String newName) async {
    final updatedKeys = <ApiKeyInfo>[...state];
    for (int i = 0; i < updatedKeys.length; i++) {
      if (updatedKeys[i].id == keyId) {
        updatedKeys[i] = updatedKeys[i].copyWith(name: newName);
        break;
      }
    }

    await _saveApiKeys(updatedKeys);
    state = updatedKeys;
  }

  /// Get the currently selected API key
  ApiKeyInfo? get selectedApiKey {
    for (final k in state) {
      if (k.isSelected) return k;
    }
    return null;
  }

  /// Get all available (non-rate-limited) API keys
  List<ApiKeyInfo> get availableApiKeys {
    final result = <ApiKeyInfo>[];
    for (final k in state) {
      if (!k.isRateLimited || k.isRateLimitExpired) {
        result.add(k);
      }
    }
    return result;
  }

  /// Save API keys to storage
  Future<void> _saveApiKeys(List<ApiKeyInfo> keys) async {
    try {
      final settings = StorageService.settings;
      var updatedSettings = settings.copyWith(apiKeys: keys);

      // Update selectedApiKeyId if needed
      ApiKeyInfo? newSelected;
      for (final k in keys) {
        if (k.isSelected) {
          newSelected = k;
          break;
        }
      }

      if (newSelected != null) {
        updatedSettings = updatedSettings.copyWith(selectedApiKeyId: newSelected.id);
      }

      await StorageService.saveSettings(updatedSettings);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiKeysNotifier] Failed to save API keys: $e');
      }
    }
  }

  /// Validate an API key by making a test call
  /// Returns (isValid, errorMessage)
  Future<(bool isValid, String? error)> validateApiKey(String apiKey) async {
    // This would typically call GeminiService.validateApiKey
    // For now, do basic format validation
    if (apiKey.isEmpty) {
      return (false, 'API key cannot be empty');
    }
    if (!apiKey.startsWith('AIza') && apiKey.length < 30) {
      return (false, 'Invalid API key format');
    }
    return (true, null);
  }
}

/// API keys state management provider
final apiKeysProvider =
    NotifierProvider<ApiKeysNotifier, List<ApiKeyInfo>>(
  ApiKeysNotifier.new,
);

/// Provider for the currently selected API key
final selectedApiKeyProvider = Provider<ApiKeyInfo?>((ref) {
  final keys = ref.watch(apiKeysProvider);
  for (final k in keys) {
    if (k.isSelected) return k;
  }
  return null;
});

/// Provider for available (non-rate-limited) API keys
final availableApiKeysProvider = Provider<List<ApiKeyInfo>>((ref) {
  final keys = ref.watch(apiKeysProvider);
  final result = <ApiKeyInfo>[];
  for (final k in keys) {
    if (!k.isRateLimited || k.isRateLimitExpired) {
      result.add(k);
    }
  }
  return result;
});
