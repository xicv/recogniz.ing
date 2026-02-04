import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import 'api_key_info.dart';

part 'app_settings.g.dart';

/// Audio compression preference for recordings
///
/// - **auto**: Smart format selection based on recording duration
///   - < 2 minutes: AAC (compressed, faster)
///   - 2-5 minutes: AAC with warning about potential truncation
///   - 5+ minutes: PCM (uncompressed, no truncation risk)
/// - **alwaysCompressed**: Always use AAC format regardless of duration
///   - May lose 0.5-2 seconds at end due to encoder buffering
///   - Smaller file size (~480 KB/min vs 1.92 MB/min for PCM)
/// - **uncompressed**: Always use PCM format regardless of duration
///   - No truncation risk, but larger file size
@HiveType(typeId: 12)
enum AudioCompressionPreference {
  @HiveField(0)
  auto,

  @HiveField(1)
  alwaysCompressed,

  @HiveField(2)
  uncompressed,
}

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final String? geminiApiKey;

  @HiveField(1)
  final String selectedPromptId;

  @HiveField(2)
  final String selectedVocabularyId;

  @HiveField(3)
  final String globalHotkey;

  @HiveField(4)
  final bool darkMode;

  @HiveField(5)
  final bool autoCopyToClipboard;

  @HiveField(6)
  final bool showNotifications;

  @HiveField(7)
  final String? criticalInstructions;

  @HiveField(10)
  final bool startAtLogin;

  @HiveField(11, defaultValue: 'auto')
  final String transcriptionLanguage;

  @HiveField(13, defaultValue: AudioCompressionPreference.auto)
  final AudioCompressionPreference audioCompressionPreference;

  @HiveField(14, defaultValue: [])
  final List<ApiKeyInfo> apiKeys;

  @HiveField(15)
  final String? selectedApiKeyId;

  AppSettings({
    this.geminiApiKey,
    this.selectedPromptId = 'default-clean',
    this.selectedVocabularyId = 'default-general',
    this.globalHotkey = 'Ctrl+Shift+R',
    this.darkMode = false,
    this.autoCopyToClipboard = true,
    this.showNotifications = true,
    this.criticalInstructions = '''CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary below is for reference ONLY - do not use it to generate fake transcriptions''',
    this.startAtLogin = false,
    this.transcriptionLanguage = 'auto',
    this.audioCompressionPreference = AudioCompressionPreference.auto,
    this.apiKeys = const [],
    this.selectedApiKeyId,
  });

  AppSettings copyWith({
    String? geminiApiKey,
    String? selectedPromptId,
    String? selectedVocabularyId,
    String? globalHotkey,
    bool? darkMode,
    bool? autoCopyToClipboard,
    bool? showNotifications,
    String? criticalInstructions,
    bool? startAtLogin,
    String? transcriptionLanguage,
    AudioCompressionPreference? audioCompressionPreference,
    List<ApiKeyInfo>? apiKeys,
    String? selectedApiKeyId,
  }) {
    return AppSettings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      selectedPromptId: selectedPromptId ?? this.selectedPromptId,
      selectedVocabularyId: selectedVocabularyId ?? this.selectedVocabularyId,
      globalHotkey: globalHotkey ?? this.globalHotkey,
      darkMode: darkMode ?? this.darkMode,
      autoCopyToClipboard: autoCopyToClipboard ?? this.autoCopyToClipboard,
      showNotifications: showNotifications ?? this.showNotifications,
      criticalInstructions: criticalInstructions ?? this.criticalInstructions,
      startAtLogin: startAtLogin ?? this.startAtLogin,
      transcriptionLanguage:
          transcriptionLanguage ?? this.transcriptionLanguage,
      audioCompressionPreference:
          audioCompressionPreference ?? this.audioCompressionPreference,
      apiKeys: apiKeys ?? this.apiKeys,
      selectedApiKeyId: selectedApiKeyId ?? this.selectedApiKeyId,
    );
  }

  /// Check if user has a valid API key configured
  ///
  /// Checks both the new multi-key system and legacy single key field
  bool get hasApiKey {
    // Check new multi-key system first
    if (apiKeys.isNotEmpty) {
      // Check if there's at least one available (non-rate-limited or expired) key
      return apiKeys.any((key) => !key.isRateLimited || key.isRateLimitExpired);
    }
    // Fall back to legacy single key
    return geminiApiKey != null && geminiApiKey!.isNotEmpty;
  }

  /// Get the currently selected API key from the multi-key system
  ///
  /// Returns the ApiKeyInfo that is currently selected, or null if:
  /// - No keys are stored
  /// - No key is selected
  /// - The selected key ID is invalid
  ApiKeyInfo? get selectedApiKey {
    if (selectedApiKeyId == null) return null;
    return apiKeys.firstWhereOrNull((key) => key.id == selectedApiKeyId);
  }

  /// Get the actual API key string to use
  ///
  /// Priority:
  /// 1. Selected key from multi-key system
  /// 2. Legacy geminiApiKey field (for backward compatibility)
  String? get effectiveApiKey {
    // Try new multi-key system first
    final selected = selectedApiKey;
    if (selected != null && !selected.isRateLimited) {
      return selected.apiKey;
    }
    // Fall back to legacy single key
    return geminiApiKey;
  }

  /// Get all available (non-rate-limited) API keys
  List<ApiKeyInfo> get availableApiKeys =>
      apiKeys.where((key) => !key.isRateLimited || key.isRateLimitExpired).toList();

  String get effectiveCriticalInstructions =>
      criticalInstructions ??
      '''CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary below is for reference ONLY - do not use it to generate fake transcriptions''';
}
