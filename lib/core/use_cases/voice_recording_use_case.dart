import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../models/transcription.dart';
import '../models/transcription_result.dart';
import '../providers/ui_providers.dart';
import '../interfaces/audio_service_interface.dart';

class VoiceRecordingUseCase {
  final AudioServiceInterface _audioService;
  final TranscriptionServiceInterface _transcriptionService;
  final StorageServiceInterface _storageService;
  final NotificationServiceInterface _notificationService;

  final Function(RecordingState) _onStateChanged;
  final Function(Transcription) _onTranscriptionComplete;

  VoiceRecordingUseCase({
    required AudioServiceInterface audioService,
    required TranscriptionServiceInterface transcriptionService,
    required StorageServiceInterface storageService,
    required NotificationServiceInterface notificationService,
    required Function(RecordingState) onStateChanged,
    required Function(Transcription) onTranscriptionComplete,
  })  : _audioService = audioService,
        _transcriptionService = transcriptionService,
        _storageService = storageService,
        _notificationService = notificationService,
        _onStateChanged = onStateChanged,
        _onTranscriptionComplete = onTranscriptionComplete;

  Future<void> startRecording() async {
    try {
      debugPrint('Checking microphone permission...');
      final hasPermission = await _audioService.hasPermission();
      debugPrint('Has permission: $hasPermission');

      if (!hasPermission) {
        _notificationService.showError(
          'Microphone permission denied. Please grant access in System Settings.',
        );
        return;
      }

      debugPrint('Starting recording...');
      await _audioService.startRecording();
      _onStateChanged(RecordingState.recording);
      debugPrint('Recording started successfully');
    } catch (e) {
      _notificationService.showError(_getErrorMessage(e));
    }
  }

  Future<void> stopRecording() async {
    debugPrint('Stopping recording...');
    _onStateChanged(RecordingState.processing);

    try {
      final result = await _audioService.stopRecording();
      debugPrint(
          'Recording stopped. Result: ${result != null ? "Got audio data" : "No data"}');

      if (result == null) {
        _showErrorAndReset(
            'No audio recorded. Please speak clearly and try again.\n'
            'Tip: Recordings must be at least ${AppConstants.minRecordingDurationSeconds}s long.');
        return;
      }

      // Use the RecordingResultInterface directly
      final recordingResult = result;

      if (recordingResult.durationSeconds <
          AppConstants.minRecordingDurationSeconds) {
        _showErrorAndReset(
            'Recording too short (${recordingResult.durationSeconds.toStringAsFixed(1)}s).\n'
            'Please speak for at least ${AppConstants.minRecordingDurationSeconds}s.');
        return;
      }

      if (recordingResult.analysis?.containsSpeech == false) {
        _showErrorAndReset('No clear speech detected in the recording.\n'
            'Please ensure you speak clearly and reduce background noise.');
        return;
      }

      debugPrint(
          'Recording validated: ${(recordingResult.durationSeconds).toStringAsFixed(1)}s');
      await _processAudio(
          recordingResult.bytes, recordingResult.durationSeconds);
    } catch (e) {
      debugPrint('Error processing recording: $e');
      _showErrorAndReset(_getErrorMessage(e));
    }
  }

  Future<void> _processAudio(
      List<int> audioData, double audioDurationSeconds) async {
    final settings = await _storageService.getSettings();

    if (!settings.hasApiKey) {
      _showErrorAndReset(
          'Please add your Gemini API key in Settings to start transcribing.');
      return;
    }

    try {
      debugPrint('Sending to transcription service...');

      // Get vocabulary and prompt through storage service
      final vocabulary =
          await _storageService.getVocabulary(settings.selectedVocabularyId);
      final prompt = await _storageService.getPrompt(settings.selectedPromptId);

      final result = await _transcriptionService.transcribeAudio(
        audioBytes: Uint8List.fromList(audioData),
        vocabulary: vocabulary?.words.join(', ') ?? '',
        promptTemplate:
            prompt?.promptTemplate ?? AppConstants.defaultPromptTemplate,
        criticalInstructions: settings.effectiveCriticalInstructions,
      );

      debugPrint(
          'Transcription result: ${result.processedText.isNotEmpty ? "Success" : "Empty"}');

      if (result.processedText.isEmpty) {
        _notificationService
            .showError('No transcription received. Please try again.');
      } else {
        final transcription = Transcription(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          rawText: result.rawText,
          processedText: result.processedText,
          createdAt: DateTime.now(),
          tokenUsage: result.tokenUsage,
          promptId: settings.selectedPromptId,
          audioDurationSeconds: audioDurationSeconds,
        );

        await _storageService.saveTranscription(transcription);
        _onTranscriptionComplete(transcription);
        debugPrint('Transcription saved successfully');
        _notificationService.clearError();

        if (settings.autoCopyToClipboard) {
          await _copyToClipboard(result.processedText);
        }
      }
    } catch (e) {
      debugPrint('Transcription error: $e');
      _showErrorAndReset(_getErrorMessage(e));
    }

    _onStateChanged(RecordingState.idle);
    debugPrint('=== Recording flow complete ===');
  }

  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      debugPrint('Copied to clipboard: $text');
    } catch (e) {
      debugPrint('Failed to copy to clipboard: $e');
    }
  }

  void _showErrorAndReset(String message) {
    _notificationService.showError(message);
    _onStateChanged(RecordingState.idle);
  }

  String _getErrorMessage(dynamic error) {
    // Centralized error message handling
    if (error.toString().contains('permission')) {
      return 'Microphone permission required for recording.';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
