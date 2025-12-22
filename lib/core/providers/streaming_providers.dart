import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/streaming_audio_recorder.dart';
import '../services/streaming_gemini_service.dart';
import '../services/advanced_audio_processor.dart';
import '../use_cases/streaming_voice_recording_use_case.dart';
import '../interfaces/audio_service_interface.dart';
import '../providers/app_providers.dart';
import '../models/transcription.dart';
import '../services/streaming_audio_recorder.dart';
import 'providers.dart';

// Export the streaming recording state for use in other files
export '../services/streaming_audio_recorder.dart' show StreamingRecordingState;

// Advanced Audio Processor Provider
final advancedAudioProcessorProvider = Provider<AdvancedAudioProcessor>((ref) {
  return AdvancedAudioProcessor();
});

// Streaming Audio Recorder Provider
final streamingAudioRecorderProvider = Provider<StreamingAudioRecorder>((ref) {
  final recorder = StreamingAudioRecorder();

  // Initialize the recorder
  recorder.initialize();

  return recorder;
});

// Streaming Gemini Service Provider
final streamingGeminiServiceProvider = Provider<StreamingGeminiService>((ref) {
  final service = StreamingGeminiService();

  // Will be initialized when API key is available
  return service;
});

// Streaming Voice Recording Use Case Provider
final streamingVoiceRecordingUseCaseProvider = Provider<StreamingVoiceRecordingUseCase>((ref) {
  return StreamingVoiceRecordingUseCase(
    audioRecorder: ref.watch(streamingAudioRecorderProvider),
    transcriptionService: ref.watch(streamingGeminiServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
    onStateChanged: (state) {
      // Update UI recording state
      ref.read(recordingStateProvider.notifier).state = state;
    },
    onTextUpdate: (text) {
      // Update current transcription text
      ref.read(currentTranscriptionTextProvider.notifier).updateText(text);
    },
    onTranscriptionComplete: (transcription) {
      // Add to transcriptions
      ref.read(transcriptionsProvider.notifier).addTranscription(transcription);
    },
  );
});

// Recording State Provider for Streaming
final streamingRecordingStateProvider = StateNotifierProvider<RecordingStateNotifier, StreamingRecordingState>((ref) {
  return RecordingStateNotifier();
});

class RecordingStateNotifier extends StateNotifier<StreamingRecordingState> {
  RecordingStateNotifier() : super(StreamingRecordingState.idle);

  void updateState(StreamingRecordingState state) {
    super.state = state;
  }
}

// Current Transcription Text Provider
final currentTranscriptionTextProvider = StateNotifierProvider<CurrentTranscriptionTextNotifier, String>((ref) {
  return CurrentTranscriptionTextNotifier();
});

class CurrentTranscriptionTextNotifier extends StateNotifier<String> {
  CurrentTranscriptionTextNotifier() : super('');

  void updateText(String text) {
    state = text;
  }
}

// Real-time VAD Events Provider
final vadEventsProvider = StreamProvider<VadEvent>((ref) {
  return AdvancedAudioProcessor.vadEvents;
});

// Audio Chunks Provider
final audioChunksProvider = StreamProvider<AudioChunk>((ref) {
  return AdvancedAudioProcessor.audioChunks;
});

// Transcription Chunks Provider
final transcriptionChunksProvider = StreamProvider<TranscriptionChunk>((ref) {
  return ref.watch(streamingGeminiServiceProvider).transcriptionChunks;
});

// Text Updates Provider
final textUpdatesProvider = StreamProvider<String>((ref) {
  return ref.watch(streamingGeminiServiceProvider).textUpdates;
});

// Initialize Streaming Services Provider
final initializeStreamingServicesProvider = FutureProvider<void>((ref) async {
  // Initialize advanced audio processor
  await AdvancedAudioProcessor.initialize();

  // Initialize audio recorder
  final recorder = ref.read(streamingAudioRecorderProvider);
  await recorder.initialize();

  debugPrint('[StreamingProviders] All services initialized');
});