import 'package:hive_flutter/hive_flutter.dart';
import '../models/transcription.dart';
import '../models/custom_prompt.dart';
import '../models/vocabulary.dart';
import '../models/app_settings.dart';
import '../config/prompt_config.dart';
import '../config/vocabulary_config.dart';
import '../interfaces/audio_service_interface.dart';

class StorageService implements StorageServiceInterface {
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

    // Add default prompts from config if empty
    if (promptsBox.isEmpty) {
      try {
        final promptConfig = await PromptConfig.fromAsset();
        for (final prompt in promptConfig.prompts) {
          final customPrompt = CustomPrompt(
            id: prompt.id,
            name: prompt.name,
            description: prompt.description,
            promptTemplate: prompt.template,
            isDefault: prompt.isDefault,
            createdAt: DateTime.now(),
          );
          await promptsBox.put(prompt.id, customPrompt);
        }
      } catch (e) {
        // Fallback to hardcoded defaults if config loading fails
        for (final prompt in CustomPrompt.defaults) {
          await promptsBox.put(prompt.id, prompt);
        }
      }
    }

    // Add default vocabulary from config if empty
    if (vocabBox.isEmpty) {
      try {
        final vocabConfig = await VocabularyConfig.fromAsset();
        for (final vocab in vocabConfig.vocabularies) {
          final vocabularySet = VocabularySet(
            id: vocab.id,
            name: vocab.name,
            description: vocab.description,
            words: vocab.words,
            isDefault: vocab.isDefault,
            createdAt: DateTime.now(),
          );
          await vocabBox.put(vocab.id, vocabularySet);
        }
      } catch (e) {
        // Fallback to hardcoded defaults if config loading fails
        for (final vocab in VocabularySet.defaults) {
          await vocabBox.put(vocab.id, vocab);
        }
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

  // Interface implementation
  @override
  AppSettings getSettings() => settings;

  @override
  Future<void> saveTranscription(Transcription transcription) async {
    final box = Hive.box<Transcription>(transcriptionsBox);
    await box.put(transcription.id, transcription);
  }

  @override
  Future<List<Transcription>> getTranscriptions() async {
    final box = Hive.box<Transcription>(transcriptionsBox);
    final values = box.values.toList();
    values.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  @override
  Future<void> deleteTranscription(String id) async {
    final box = Hive.box<Transcription>(transcriptionsBox);
    await box.delete(id);
  }

  @override
  Future<void> updateTranscription(String id, String newText) async {
    final box = Hive.box<Transcription>(transcriptionsBox);
    final transcription = box.get(id);
    if (transcription != null) {
      final updated = transcription.copyWith(processedText: newText);
      await box.put(id, updated);
    }
  }
}
