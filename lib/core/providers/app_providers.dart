import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/custom_prompt.dart';
import '../models/transcription.dart';
import '../models/vocabulary.dart';
import '../services/audio_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

// Services
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();
  final settings = ref.watch(settingsProvider);
  if (settings.hasApiKey) {
    service.initialize(settings.geminiApiKey!);
  }
  ref.onDispose(() => service.dispose());
  return service;
});

// Settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(StorageService.settings);

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
}

// Transcriptions
final transcriptionsProvider =
    StateNotifierProvider<TranscriptionsNotifier, List<Transcription>>((ref) {
  return TranscriptionsNotifier();
});

class TranscriptionsNotifier extends StateNotifier<List<Transcription>> {
  TranscriptionsNotifier() : super(_loadTranscriptions());

  static List<Transcription> _loadTranscriptions() {
    return StorageService.transcriptions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addTranscription(Transcription transcription) async {
    await StorageService.transcriptions.put(transcription.id, transcription);
    state = _loadTranscriptions();
  }

  Future<void> updateTranscription(String id, String newText) async {
    final existing = StorageService.transcriptions.get(id);
    if (existing != null) {
      final updated = existing.copyWith(processedText: newText);
      await StorageService.transcriptions.put(id, updated);
      state = _loadTranscriptions();
    }
  }

  Future<void> deleteTranscription(String id) async {
    await StorageService.transcriptions.delete(id);
    state = _loadTranscriptions();
  }

  void refresh() {
    state = _loadTranscriptions();
  }
}

// Prompts
final promptsProvider =
    StateNotifierProvider<PromptsNotifier, List<CustomPrompt>>((ref) {
  return PromptsNotifier();
});

class PromptsNotifier extends StateNotifier<List<CustomPrompt>> {
  PromptsNotifier() : super(_loadPrompts());

  static List<CustomPrompt> _loadPrompts() {
    return StorageService.prompts.values.toList();
  }

  Future<void> addPrompt(CustomPrompt prompt) async {
    await StorageService.prompts.put(prompt.id, prompt);
    state = _loadPrompts();
  }

  Future<void> updatePrompt(CustomPrompt prompt) async {
    await StorageService.prompts.put(prompt.id, prompt);
    state = _loadPrompts();
  }

  Future<void> deletePrompt(String id) async {
    final prompt = StorageService.prompts.get(id);
    if (prompt != null && !prompt.isDefault) {
      await StorageService.prompts.delete(id);
      state = _loadPrompts();
    }
  }
}

// Vocabulary
final vocabularyProvider =
    StateNotifierProvider<VocabularyNotifier, List<VocabularySet>>((ref) {
  return VocabularyNotifier();
});

class VocabularyNotifier extends StateNotifier<List<VocabularySet>> {
  VocabularyNotifier() : super(_loadVocabulary());

  static List<VocabularySet> _loadVocabulary() {
    return StorageService.vocabulary.values.toList();
  }

  Future<void> addVocabulary(VocabularySet vocab) async {
    await StorageService.vocabulary.put(vocab.id, vocab);
    state = _loadVocabulary();
  }

  Future<void> updateVocabulary(VocabularySet vocab) async {
    await StorageService.vocabulary.put(vocab.id, vocab);
    state = _loadVocabulary();
  }

  Future<void> deleteVocabulary(String id) async {
    final vocab = StorageService.vocabulary.get(id);
    if (vocab != null && !vocab.isDefault) {
      await StorageService.vocabulary.delete(id);
      state = _loadVocabulary();
    }
  }
}

// Recording state
final recordingStateProvider = StateProvider<RecordingState>((ref) {
  return RecordingState.idle;
});

enum RecordingState {
  idle,
  recording,
  processing,
}

// Search query for transcriptions
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered transcriptions
final filteredTranscriptionsProvider = Provider<List<Transcription>>((ref) {
  final transcriptions = ref.watch(transcriptionsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return transcriptions;

  return transcriptions
      .where((t) =>
          t.rawText.toLowerCase().contains(query) ||
          t.processedText.toLowerCase().contains(query))
      .toList();
});

// Statistics
final statisticsProvider = Provider<Statistics>((ref) {
  final transcriptions = ref.watch(transcriptionsProvider);

  final totalUsage = transcriptions.length;
  final totalTokens =
      transcriptions.fold<int>(0, (sum, t) => sum + t.tokenUsage);
  final totalDuration =
      transcriptions.fold<double>(0, (sum, t) => sum + t.audioDurationSeconds);

  // Usage by day for last 7 days
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final recentTranscriptions =
      transcriptions.where((t) => t.createdAt.isAfter(weekAgo)).toList();

  return Statistics(
    totalUsage: totalUsage,
    totalTokens: totalTokens,
    totalDurationMinutes: totalDuration / 60,
    thisWeekUsage: recentTranscriptions.length,
  );
});

class Statistics {
  final int totalUsage;
  final int totalTokens;
  final double totalDurationMinutes;
  final int thisWeekUsage;

  Statistics({
    required this.totalUsage,
    required this.totalTokens,
    required this.totalDurationMinutes,
    required this.thisWeekUsage,
  });
}

// Tray recording trigger - increment to trigger recording toggle from tray
final trayRecordingTriggerProvider = StateProvider<int>((ref) => 0);

// Current page provider (moved here for global access)
final currentPageProvider = StateProvider<int>((ref) => 0);
