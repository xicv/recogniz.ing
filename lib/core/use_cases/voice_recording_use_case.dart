import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../models/transcription.dart';
import '../models/transcription_status.dart';
import '../providers/ui_providers.dart';
import '../services/audio_storage_service.dart';
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

      // Get user's audio compression preference from settings
      final settings = await _storageService.getSettings();
      debugPrint('Starting recording with compression preference: ${settings.audioCompressionPreference}');

      debugPrint('Starting recording...');
      await _audioService.startRecording(
        compressionPreference: settings.audioCompressionPreference,
      );
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

      await _processAudioWithRetry(recordingResult.bytes, recordingResult.path,
          recordingResult.durationSeconds);
    } catch (e) {
      debugPrint('Error processing recording: $e');
      _showErrorAndReset(_getErrorMessage(e));
    }
  }

  /// Retry a failed transcription using the stored audio
  Future<void> retryTranscription(Transcription failedTranscription) async {
    if (!failedTranscription.canRetry) {
      _notificationService.showError(
        'This transcription cannot be retried. No audio backup available.',
      );
      return;
    }

    debugPrint('[Retry] Retrying transcription: ${failedTranscription.id}');
    _onStateChanged(RecordingState.processing);

    try {
      // Load audio from storage
      final audioBytes = await AudioStorageService.getAudioBytes(
          failedTranscription.audioBackupPath!);
      if (audioBytes == null) {
        _notificationService.showError(
          'Could not load audio file for retry. It may have been deleted.',
        );
        _onStateChanged(RecordingState.idle);
        return;
      }

      // Increment retry count and update status
      final updatedTranscription = failedTranscription.incrementRetry();
      await _storageService.saveTranscription(updatedTranscription);
      _onTranscriptionComplete(updatedTranscription);

      // Process the audio
      await _callTranscriptionAPI(
        transcriptionId: failedTranscription.id,
        audioBytes: audioBytes,
        audioPath: failedTranscription.audioBackupPath!,
        audioDurationSeconds: failedTranscription.audioDurationSeconds,
      );
    } catch (e) {
      debugPrint('[Retry] Error: $e');
      _showErrorAndReset(_getErrorMessage(e));
    }
  }

  /// Process audio with the new workflow: create pending, then process
  Future<void> _processAudioWithRetry(List<int> audioData, String audioPath,
      double audioDurationSeconds) async {
    final settings = await _storageService.getSettings();

    if (!settings.hasApiKey) {
      _showErrorAndReset(
          'Please add your Gemini API key in Settings to start transcribing.');
      return;
    }

    // Create a pending transcription first
    final transcriptionId = DateTime.now().millisecondsSinceEpoch.toString();
    final pendingTranscription = Transcription.pending(
      id: transcriptionId,
      audioDurationSeconds: audioDurationSeconds,
      audioBackupPath: audioPath,
      promptId: settings.selectedPromptId,
    );

    await _storageService.saveTranscription(pendingTranscription);
    _onTranscriptionComplete(pendingTranscription);
    debugPrint(
        '[Transcription] Pending transcription created: $transcriptionId');

    // Now call the API
    await _callTranscriptionAPI(
      transcriptionId: transcriptionId,
      audioBytes: Uint8List.fromList(audioData),
      audioPath: audioPath,
      audioDurationSeconds: audioDurationSeconds,
    );
  }

  /// Call the transcription API and handle success/failure
  Future<void> _callTranscriptionAPI({
    required String transcriptionId,
    required Uint8List audioBytes,
    required String audioPath,
    required double audioDurationSeconds,
  }) async {
    final settings = await _storageService.getSettings();

    try {
      debugPrint('[Transcription] Calling API...');

      // Get vocabulary and prompt through storage service
      final vocabulary =
          await _storageService.getVocabulary(settings.selectedVocabularyId);
      final prompt = await _storageService.getPrompt(settings.selectedPromptId);

      final result = await _transcriptionService.transcribeAudio(
        audioBytes: audioBytes,
        vocabulary: vocabulary?.words.join(', ') ?? '',
        promptTemplate:
            prompt?.promptTemplate ?? AppConstants.defaultPromptTemplate,
        criticalInstructions: settings.effectiveCriticalInstructions,
      );

      debugPrint(
          '[Transcription] Result: ${result.processedText.isNotEmpty ? "Success" : "Empty"}');

      if (result.processedText.isEmpty) {
        throw Exception('No transcription received. Please try again.');
      }

      // Update to completed status
      final completedTranscription = Transcription(
        id: transcriptionId,
        rawText: result.rawText,
        processedText: result.processedText,
        createdAt: DateTime.now(),
        tokenUsage: result.tokenUsage,
        promptId: settings.selectedPromptId,
        audioDurationSeconds: audioDurationSeconds,
        status: TranscriptionStatus.completed,
        completedAt: DateTime.now(),
        // Clear audio backup path on success
        audioBackupPath: null,
      );

      await _storageService.saveTranscription(completedTranscription);
      _onTranscriptionComplete(completedTranscription);
      debugPrint('[Transcription] Completed successfully');

      // Delete audio backup file
      await AudioStorageService.deleteAudio(audioPath);

      _notificationService.clearError();

      if (settings.autoCopyToClipboard) {
        await _copyToClipboard(result.processedText);
      }

      _onStateChanged(RecordingState.idle);
      debugPrint('=== Recording flow complete ===');
    } catch (e) {
      debugPrint('[Transcription] Error: $e');

      // Update to failed status (keep audio for retry)
      final current = await _storageService.getTranscriptions();
      final existing = current.cast<Transcription?>().firstWhere(
            (t) => t?.id == transcriptionId,
            orElse: () => null,
          );

      if (existing != null) {
        final failedTranscription = existing.asFailed(e.toString());
        await _storageService.saveTranscription(failedTranscription);
        _onTranscriptionComplete(failedTranscription);
        debugPrint(
            '[Transcription] Marked as failed, audio preserved for retry');
      }

      _showErrorAndReset(_getErrorMessage(e));
    }
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
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('permission')) {
      return 'Microphone permission required for recording.';
    } else if (errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection')) {
      return 'Network error. Please check your connection and retry.';
    } else if (errorStr.contains('api') ||
        errorStr.contains('401') ||
        errorStr.contains('403')) {
      return 'API error. Please check your API key and retry.';
    } else if (errorStr.contains('rate') ||
        errorStr.contains('429') ||
        errorStr.contains('quota')) {
      return 'Rate limited. Please wait a moment and retry.';
    } else if (errorStr.contains('timeout') || errorStr.contains('deadline')) {
      return 'Request timeout. The server took too long to respond. Please retry.';
    } else {
      return errorStr.length > 100
          ? '${errorStr.substring(0, 100)}... Please try again.'
          : 'An error occurred: $errorStr';
    }
  }
}
