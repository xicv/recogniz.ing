import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_service.dart';
import '../services/gemini_service.dart';
import '../services/optimized_gemini_service.dart';
import '../use_cases/recording_use_case.dart';
import 'settings_providers.dart';

/// Service providers for application-wide services
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

final optimizedGeminiServiceProvider = Provider<OptimizedGeminiService>((ref) {
  final service = OptimizedGeminiService();
  final settings = ref.watch(settingsProvider);
  if (settings.hasApiKey) {
    service.initialize(settings.geminiApiKey!);
  }
  ref.onDispose(() => service.dispose());
  return service;
});

/// Use case providers
final recordingUseCaseProvider = Provider<RecordingUseCase>((ref) => RecordingUseCase(ref));