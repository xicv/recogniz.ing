import 'package:hive_flutter/hive_flutter.dart';
import '../models/transcription.dart';
import '../models/custom_prompt.dart';
import '../models/vocabulary.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String transcriptionsBox = 'transcriptions';
  static const String promptsBox = 'prompts';
  static const String vocabularyBox = 'vocabulary';
  static const String settingsBox = 'settings';

  static Future<void> initialize() async {
    // Register adapters
    Hive.registerAdapter(TranscriptionAdapter());
    Hive.registerAdapter(CustomPromptAdapter());
    Hive.registerAdapter(VocabularySetAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // Open boxes
    await Hive.openBox<Transcription>(transcriptionsBox);
    await Hive.openBox<CustomPrompt>(promptsBox);
    await Hive.openBox<VocabularySet>(vocabularyBox);
    await Hive.openBox<AppSettings>(settingsBox);

    // Initialize defaults
    await _initializeDefaults();
  }

  static Future<void> _initializeDefaults() async {
    final promptsBox = Hive.box<CustomPrompt>(StorageService.promptsBox);
    final vocabBox = Hive.box<VocabularySet>(StorageService.vocabularyBox);
    final settingsBox = Hive.box<AppSettings>(StorageService.settingsBox);

    // Add default prompts if empty
    if (promptsBox.isEmpty) {
      for (final prompt in CustomPrompt.defaults) {
        await promptsBox.put(prompt.id, prompt);
      }
    }

    // Add default vocabulary if empty
    if (vocabBox.isEmpty) {
      for (final vocab in VocabularySet.defaults) {
        await vocabBox.put(vocab.id, vocab);
      }
    }

    // Initialize settings if empty
    if (settingsBox.isEmpty) {
      await settingsBox.put('settings', AppSettings());
    }
  }

  // Transcriptions
  static Box<Transcription> get transcriptions =>
      Hive.box<Transcription>(transcriptionsBox);

  // Prompts
  static Box<CustomPrompt> get prompts => Hive.box<CustomPrompt>(promptsBox);

  // Vocabulary
  static Box<VocabularySet> get vocabulary =>
      Hive.box<VocabularySet>(vocabularyBox);

  // Settings
  static AppSettings get settings =>
      Hive.box<AppSettings>(settingsBox).get('settings') ?? AppSettings();

  static Future<void> saveSettings(AppSettings settings) async {
    await Hive.box<AppSettings>(settingsBox).put('settings', settings);
  }
}
