import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/voice_recording_use_case.dart';
import '../interfaces/audio_service_interface.dart';
import '../services/audio_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../providers/app_providers.dart';
import '../../main.dart';
import '../providers/ui_providers.dart';
import '../models/transcription.dart';

// Service providers
final audioServiceProvider = Provider<AudioServiceInterface>((ref) {
  return AudioService();
});

final transcriptionServiceProvider =
    Provider<TranscriptionServiceInterface>((ref) {
  final geminiService = GeminiService();
  final settings = ref.watch(settingsProvider);
  if (settings.geminiApiKey?.isNotEmpty == true) {
    geminiService.initialize(settings.geminiApiKey!);
  }
  return geminiService;
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
