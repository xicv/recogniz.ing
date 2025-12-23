import 'package:hive/hive.dart';

part 'app_settings.g.dart';

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

  @HiveField(8)
  final bool autoStopAfterSilence;

  @HiveField(9)
  final int silenceDuration;

  @HiveField(10)
  final bool startAtLogin;

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
    this.autoStopAfterSilence = true,
    this.silenceDuration = 3,
    this.startAtLogin = false,
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
    bool? autoStopAfterSilence,
    int? silenceDuration,
    bool? startAtLogin,
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
      autoStopAfterSilence: autoStopAfterSilence ?? this.autoStopAfterSilence,
      silenceDuration: silenceDuration ?? this.silenceDuration,
      startAtLogin: startAtLogin ?? this.startAtLogin,
    );
  }

  bool get hasApiKey => geminiApiKey != null && geminiApiKey!.isNotEmpty;

  String get effectiveCriticalInstructions =>
      criticalInstructions ??
      '''CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary below is for reference ONLY - do not use it to generate fake transcriptions''';
}
