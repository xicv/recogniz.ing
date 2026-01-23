import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/voice_recording_use_case.dart';
import '../interfaces/audio_service_interface.dart';
import '../services/audio_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'app_providers.dart';
import 'config_providers.dart';
import 'api_keys_provider.dart';
import '../models/app_settings.dart';

// Service providers
final audioServiceProvider = Provider<AudioServiceInterface>((ref) {
  final service = AudioService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

// Unified Gemini service provider (singleton)
// This replaces the separate transcriptionServiceProvider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();

  // Listen to settings provider changes to reinitialize when API key changes
  ref.listen(settingsProvider, (prev, next) {
    final prevKey = prev.effectiveApiKey;
    final nextKey = next.effectiveApiKey;
    // Only reinitialize if the API key actually changed
    if (prevKey != nextKey && nextKey?.isNotEmpty == true) {
      _initializeService(service, ref);
    }
  });

  // Listen to API keys provider changes to reinitialize when selection changes
  ref.listen(apiKeysProvider, (prev, next) {
    final prevSelected = prev.where((k) => k.isSelected).firstOrNull;
    final nextSelected = next.where((k) => k.isSelected).firstOrNull;
    // Only reinitialize if the selected key changed
    if (prevSelected?.id != nextSelected?.id && nextSelected != null) {
      _initializeService(service, ref);
    }
  });

  // Initial initialization
  _initializeService(service, ref);

  ref.onDispose(() {
    // Clear any resources if needed
  });

  return service;
});

/// Initialize the Gemini service with current API key and configuration
void _initializeService(GeminiService service, WidgetRef ref) {
  final settings = ref.read(settingsProvider);
  final apiKeys = ref.read(apiKeysProvider);
  final config = ref.read(appConfigProvider);

  // Get model name from config or use default
  String modelName = 'gemini-3-flash-preview';
  config.whenData((value) => modelName = value.api.model);

  // Get the effective API key (prioritizing multi-key system)
  final apiKey = settings.effectiveApiKey;

  if (apiKey?.isNotEmpty == true) {
    service.initialize(
      apiKey!,
      model: modelName,
      // Rate limit callback - mark the current key as rate limited
      onRateLimit: (key) {
        final currentKey = apiKeys.firstWhere(
          (k) => k.apiKey == key,
          orElse: () => apiKeys.firstWhere(
            (k) => k.isSelected,
            orElse: () => throw Exception('No matching API key found'),
          ),
        );
        ref.read(apiKeysProvider.notifier).markRateLimited(currentKey.id);
      },
      // Get next available API key callback
      getNextApiKey: (currentKey) {
        final availableKeys = ref.read(availableApiKeysProvider);

        // Return first available key that isn't the current one
        final nextKey = availableKeys.firstWhere(
          (k) => k.apiKey != currentKey,
          orElse: () => availableKeys.firstWhere(
            (k) => k.apiKey != currentKey,
            orElse: () => throw Exception('No alternative API key available'),
          ),
        );
        return nextKey.apiKey;
      },
    );
  }
}

// Transcription service provider (alias to geminiServiceProvider)
final transcriptionServiceProvider =
    Provider<TranscriptionServiceInterface>((ref) {
  return ref.watch(geminiServiceProvider);
});

final storageServiceProvider = Provider<StorageServiceInterface>((ref) {
  return StorageService();
});

final notificationServiceProvider =
    Provider<NotificationServiceInterface>((ref) {
  final notificationService = NotificationService();
  // Navigator key should be set by the main app initialization
  // notificationService.setNavigatorKey(navigatorKey);
  return notificationService;
});

// App settings provider to access API key for streaming services
final appSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider);
});

// Recording use case provider
final voiceRecordingUseCaseProvider = Provider<VoiceRecordingUseCase>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final transcriptionService = ref.watch(transcriptionServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return VoiceRecordingUseCase(
    audioService: audioService,
    transcriptionService: transcriptionService,
    storageService: storageService,
    notificationService: notificationService,
    onStateChanged: (RecordingState state) {
      ref.read(recordingStateProvider.notifier).state = state;
    },
    onTranscriptionComplete: (transcription) {
      ref.read(transcriptionsProvider.notifier).addTranscription(transcription);
    },
  );
});
