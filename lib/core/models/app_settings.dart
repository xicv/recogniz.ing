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

  AppSettings({
    this.geminiApiKey,
    this.selectedPromptId = 'default-clean',
    this.selectedVocabularyId = 'default-general',
    this.globalHotkey = 'Ctrl+Shift+R',
    this.darkMode = false,
    this.autoCopyToClipboard = true,
    this.showNotifications = true,
  });

  AppSettings copyWith({
    String? geminiApiKey,
    String? selectedPromptId,
    String? selectedVocabularyId,
    String? globalHotkey,
    bool? darkMode,
    bool? autoCopyToClipboard,
    bool? showNotifications,
  }) {
    return AppSettings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      selectedPromptId: selectedPromptId ?? this.selectedPromptId,
      selectedVocabularyId: selectedVocabularyId ?? this.selectedVocabularyId,
      globalHotkey: globalHotkey ?? this.globalHotkey,
      darkMode: darkMode ?? this.darkMode,
      autoCopyToClipboard: autoCopyToClipboard ?? this.autoCopyToClipboard,
      showNotifications: showNotifications ?? this.showNotifications,
    );
  }

  bool get hasApiKey => geminiApiKey != null && geminiApiKey!.isNotEmpty;
}
