import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../error/error_handler.dart';
import '../models/transcription.dart';
import '../providers/app_providers.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class RecordingUseCase {
  final Ref ref;

  RecordingUseCase(this.ref);

  Future<void> toggleRecording(RecordingState state) async {
    final audioService = ref.read(audioServiceProvider);
    final settings = ref.read(settingsProvider);

    debugPrint('=== Toggle Recording ===');
    debugPrint('Current state: $state');
    debugPrint('Has API key: ${settings.hasApiKey}');

    if (state == RecordingState.idle) {
      await _startRecording(audioService);
    } else if (state == RecordingState.recording) {
      await _stopRecordingAndProcess(audioService);
    }
  }

  Future<void> _startRecording(AudioService audioService) async {
    try {
      debugPrint('Checking microphone permission...');
      final hasPermission = await audioService.hasPermission();
      debugPrint('Has permission: $hasPermission');

      if (!hasPermission) {
        ref.read(lastErrorProvider.notifier).state =
            'Microphone permission denied. Please grant access in System Settings.';
        return;
      }

      debugPrint('Starting recording...');
      await audioService.startRecording();
      ref.read(recordingStateProvider.notifier).state = RecordingState.recording;
      debugPrint('Recording started successfully');
    } catch (e) {
      final errorHandler = ref.read(errorHandlerProvider);
      errorHandler.handleError(e);
    }
  }

  Future<void> _stopRecordingAndProcess(AudioService audioService) async {
    debugPrint('Stopping recording...');
    ref.read(recordingStateProvider.notifier).state = RecordingState.processing;

    try {
      final result = await audioService.stopRecording();
      debugPrint(
          'Recording stopped. Result: ${result != null ? "Got audio data" : "No data"}');

      if (result == null) {
        debugPrint('No recording result');
        _showErrorAndReset(
            'No audio recorded. Please speak clearly and try again.\n'
            'Tip: Recordings must be at least ${AppConstants.minRecordingDurationSeconds}s long.');
        return;
      }

      // Check duration
      if (result.durationSeconds < AppConstants.minRecordingDurationSeconds) {
        debugPrint('Recording too short: ${result.durationSeconds}s');
        _showErrorAndReset(
            'Recording too short (${result.durationSeconds.toStringAsFixed(1)}s).\n'
            'Please speak for at least ${AppConstants.minRecordingDurationSeconds}s.');
        return;
      }

      // Check if audio analyzer found valid speech
      if (result.analysis?.containsSpeech == false) {
        debugPrint('Recording validation failed');
        _showErrorAndReset(
            'No clear speech detected in the recording.\n'
            'Please ensure you speak clearly and reduce background noise.');
        return;
      }

      debugPrint('Recording validated: ${(result.durationSeconds).toStringAsFixed(1)}s');

      // Send to transcription with duration
      await _transcribeAudio(result.bytes, result.durationSeconds);

    } catch (e) {
      debugPrint('Error processing recording: $e');
      _showErrorAndReset(AppErrorHandler.getUserMessage(e));
    }
  }

  void _showErrorAndReset(String message) {
    ref.read(lastErrorProvider.notifier).state = message;
    ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
  }

  Future<void> _transcribeAudio(List<int> audioData, double audioDurationSeconds) async {
    final geminiService = ref.read(geminiServiceProvider);
    final settings = ref.read(settingsProvider);

    // Get the actual prompt template
    final promptTemplate = _getPromptTemplate(settings.selectedPromptId);

    // Get the actual vocabulary words
    final vocabularyWords = _getVocabularyWords(settings.selectedVocabularyId);

    try {
      debugPrint('Sending to transcription service...');
      debugPrint('Using prompt: ${settings.selectedPromptId}');
      debugPrint('Using vocabulary: ${settings.selectedVocabularyId}');

      final result = await geminiService.transcribeAudio(
        audioBytes: Uint8List.fromList(audioData),
        vocabulary: vocabularyWords,
        promptTemplate: promptTemplate,
        criticalInstructions: settings.effectiveCriticalInstructions,
      );

      debugPrint('Transcription result: ${result.processedText.isNotEmpty ? "Success" : "Empty"}');

      if (result.processedText.isEmpty) {
        ref.read(lastErrorProvider.notifier).state =
            'No transcription received. Please try again.';
      } else {
        // Save transcription using the provider notifier to update UI
        final newTranscription = Transcription(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          rawText: result.rawText,
          processedText: result.processedText,
          createdAt: DateTime.now(),
          tokenUsage: result.tokenUsage,
          promptId: settings.selectedPromptId,
          audioDurationSeconds: audioDurationSeconds, // Now using actual duration
        );

        // Save through the provider to update UI state
        await ref.read(transcriptionsProvider.notifier).addTranscription(newTranscription);
        debugPrint('Transcription saved successfully');

        // Copy to clipboard if enabled - using super_clipboard for better compatibility
        if (settings.autoCopyToClipboard) {
          try {
            // Import super_clipboard if needed, otherwise fall back to default
            await Clipboard.setData(ClipboardData(text: result.processedText));
            debugPrint('Copied to clipboard');
          } catch (e) {
            debugPrint('Failed to copy to clipboard: $e');
            // Don't show error to user, just log it
          }
        }

        // Show success feedback
        ref.read(lastErrorProvider.notifier).state = null;
      }

    } catch (e) {
      debugPrint('Transcription error: $e');
      final errorHandler = ref.read(errorHandlerProvider);
      errorHandler.handleError(e);
    }

    ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
    debugPrint('=== Recording flow complete ===');
  }

  /// Get the prompt template by ID
  String _getPromptTemplate(String promptId) {
    try {
      final prompts = StorageService.prompts.values;
      final prompt = prompts.firstWhere(
        (p) => p.id == promptId,
        orElse: () => prompts.firstWhere((p) => p.id == 'default-clean'),
      );
      return prompt.promptTemplate;
    } catch (e) {
      debugPrint('[RecordingUseCase] Error getting prompt template: $e');
      // Return a default clean template
      return '''Clean up the following speech transcription by:
- Fixing grammar and punctuation
- Removing filler words (um, uh, like, you know)
- Keeping the original meaning intact
- Outputting ONLY the cleaned transcription text

TEXT TO CLEAN:
{{text}}
CLEANED VERSION:''';
    }
  }

  /// Get vocabulary words by ID
  String _getVocabularyWords(String vocabularyId) {
    try {
      final vocabularies = StorageService.vocabulary.values;
      final vocabulary = vocabularies.firstWhere(
        (v) => v.id == vocabularyId,
        orElse: () => vocabularies.firstWhere((v) => v.id == 'default-general'),
      );
      return vocabulary.words.join(', ');
    } catch (e) {
      debugPrint('[RecordingUseCase] Error getting vocabulary: $e');
      return '';
    }
  }
}