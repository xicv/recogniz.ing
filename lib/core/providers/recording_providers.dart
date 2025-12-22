import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/voice_recording_use_case.dart';
import '../use_cases/streaming_voice_recording_use_case.dart';
import '../interfaces/audio_service_interface.dart';
import '../services/audio_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../providers/app_providers.dart';
import '../providers/streaming_providers.dart';
import '../providers/settings_providers.dart';
import '../models/app_settings.dart';
import '../../main.dart';

// Service providers
final audioServiceProvider = Provider<AudioServiceInterface>((ref) {
  return AudioService();
});

// Legacy transcription service provider
final transcriptionServiceProvider =
    Provider<TranscriptionServiceInterface>((ref) {
  final geminiService = GeminiService();
  final settings = ref.watch(settingsProvider);
  if (settings.geminiApiKey?.isNotEmpty == true) {
    geminiService.initialize(settings.geminiApiKey!);
  }
  return geminiService;
});

// Enhanced Gemini service provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();
  final settings = ref.watch(appSettingsProvider);
  if (settings.geminiApiKey?.isNotEmpty == true) {
    service.initialize(settings.geminiApiKey!);
  }
  return service;
});

final storageServiceProvider = Provider<StorageServiceInterface>((ref) {
  return StorageService();
});

final notificationServiceProvider =
    Provider<NotificationServiceInterface>((ref) {
  final notificationService = NotificationService();
  // Set navigator key from main.dart
  notificationService.setNavigatorKey(navigatorKey);
  return notificationService;
});

// App settings provider to access API key for streaming services
final appSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider);
});

// Legacy Recording use case provider (for backward compatibility)
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

// Streaming Recording use case provider (new implementation)
final streamingVoiceRecordingUseCaseProvider = Provider<StreamingVoiceRecordingUseCase>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return StreamingVoiceRecordingUseCase(
    audioRecorder: ref.watch(streamingAudioRecorderProvider),
    transcriptionService: ref.watch(streamingGeminiServiceProvider),
    storageService: storageService,
    notificationService: notificationService,
    onStateChanged: (RecordingState state) {
      ref.read(recordingStateProvider.notifier).state = state;
    },
    onTextUpdate: (text) {
      ref.read(currentTranscriptionTextProvider.notifier).state = text;
    },
    onTranscriptionComplete: (transcription) {
      ref.read(transcriptionsProvider.notifier).addTranscription(transcription);
    },
  );
});
