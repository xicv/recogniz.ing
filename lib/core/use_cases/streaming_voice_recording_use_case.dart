import 'dart:async';
import 'package:flutter/foundation.dart';
import '../constants/constants.dart';
import '../models/transcription.dart';
import '../models/transcription_result.dart';
import '../providers/ui_providers.dart';
import '../interfaces/audio_service_interface.dart';
import '../services/streaming_audio_recorder.dart';
import '../services/streaming_gemini_service.dart';
import '../config/app_config.dart';

/// Enhanced voice recording use case with real-time processing
/// Supports streaming transcription with immediate feedback
class StreamingVoiceRecordingUseCase {
  final StreamingAudioRecorder _audioRecorder;
  final StreamingGeminiService _transcriptionService;
  final StorageServiceInterface _storageService;
  final NotificationServiceInterface _notificationService;

  // Callbacks
  final Function(RecordingState) _onStateChanged;
  final Function(String) _onTextUpdate;
  final Function(Transcription) _onTranscriptionComplete;

  // State management
  StreamSubscription<StreamingRecordingState>? _stateSubscription;
  StreamSubscription<TranscriptionChunk>? _chunkSubscription;
  StreamSubscription<String>? _textSubscription;
  StreamSubscription<TranscriptionResult>? _resultSubscription;

  // Recording session state
  TranscriptionSession? _currentSession;
  String _transcribedText = '';
  int _speechChunks = 0;
  int _totalChunks = 0;
  DateTime? _lastSpeechTime;

  // Configuration (loaded from settings)
  bool _autoStopAfterSilence = true;
  Duration _autoStopSilence = const Duration(seconds: 3);
  final Duration _minRecordingDuration = const Duration(seconds: 1);
  Timer? _autoStopTimer;

  /// Map streaming recording state to UI recording state
  RecordingState _mapStreamingState(StreamingRecordingState streamingState) {
    switch (streamingState) {
      case StreamingRecordingState.idle:
        return RecordingState.idle;
      case StreamingRecordingState.recording:
        return RecordingState.recording;
      case StreamingRecordingState.paused:
        return RecordingState.recording; // Map paused to recording for UI
      case StreamingRecordingState.processing:
        return RecordingState.processing;
      case StreamingRecordingState.error:
        return RecordingState.recording; // Map error to recording for UI
    }
  }

  StreamingVoiceRecordingUseCase({
    required StreamingAudioRecorder audioRecorder,
    required StreamingGeminiService transcriptionService,
    required StorageServiceInterface storageService,
    required NotificationServiceInterface notificationService,
    required Function(RecordingState) onStateChanged,
    required Function(String) onTextUpdate,
    required Function(Transcription) onTranscriptionComplete,
  })  : _audioRecorder = audioRecorder,
        _transcriptionService = transcriptionService,
        _storageService = storageService,
        _notificationService = notificationService,
        _onStateChanged = onStateChanged,
        _onTextUpdate = onTextUpdate,
        _onTranscriptionComplete = onTranscriptionComplete;

  /// Initialize the use case
  Future<void> initialize() async {
    // Initialize audio recorder
    await _audioRecorder.initialize();

    // Listen to recording state changes
    _stateSubscription = _audioRecorder.stateChanges.listen((state) {
      final uiState = _mapStreamingState(state);
      _onStateChanged(uiState);
      _handleRecordingStateChange(state);
    });

    // Listen to transcription chunks
    _chunkSubscription =
        _transcriptionService.transcriptionChunks.listen((chunk) {
      _handleTranscriptionChunk(chunk);
    });

    // Listen to text updates
    _textSubscription = _transcriptionService.textUpdates.listen((text) {
      _transcribedText = text;
      _onTextUpdate(text);
    });

    debugPrint('[StreamingVoiceRecordingUseCase] Initialized');
  }

  /// Start real-time recording session
  Future<void> startRecording() async {
    try {
      debugPrint(
          '[StreamingVoiceRecordingUseCase] Starting recording session...');

      // Check permissions
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _notificationService.showError(
          'Microphone permission denied. Please grant access in System Settings.',
        );
        return;
      }

      // Get user settings
      final settings = await _storageService.getSettings();
      if (!settings.hasApiKey) {
        _notificationService.showError(
          'API key not configured. Please set your Gemini API key in Settings.',
        );
        return;
      }

      // Load auto-stop settings
      _autoStopAfterSilence = settings.autoStopAfterSilence;
      _autoStopSilence = Duration(seconds: settings.silenceDuration);
      debugPrint(
          '[StreamingVoiceRecordingUseCase] Auto-stop: $_autoStopAfterSilence, duration: $_autoStopSilence');

      // Initialize transcription service if needed
      if (!_transcriptionService.isInitialized &&
          settings.geminiApiKey?.isNotEmpty == true) {
        // Load config to get the model name
        try {
          final config = await AppConfig.fromAsset();
          _transcriptionService.initialize(settings.geminiApiKey!,
              model: config.api.model);
        } catch (e) {
          debugPrint(
              '[StreamingVoiceRecordingUseCase] Failed to load config, using default model: $e');
          _transcriptionService.initialize(settings.geminiApiKey!);
        }
      }

      // Start streaming session
      await _transcriptionService.startStreamingSession(
        vocabulary: await _getVocabulary(),
        promptTemplate: await _getPromptTemplate(),
        criticalInstructions: _getCriticalInstructions(),
      );

      // Start recording
      await _audioRecorder.startRecording();

      // Create session
      _currentSession = TranscriptionSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        vocabulary: await _getVocabulary(),
        promptId: await _getPromptId(),
      );

      debugPrint('[StreamingVoiceRecordingUseCase] Recording started');
    } catch (e) {
      _notificationService.showError(_getErrorMessage(e));
      debugPrint('[StreamingVoiceRecordingUseCase] Start error: $e');
    }
  }

  /// Stop recording and finalize transcription
  Future<void> stopRecording() async {
    try {
      debugPrint('[StreamingVoiceRecordingUseCase] Stopping recording...');

      // Cancel auto-stop timer
      _autoStopTimer?.cancel();

      // Stop recording
      final result = await _audioRecorder.stopRecording();

      // End streaming session
      final streamResult = await _transcriptionService.endStreamingSession();

      // Validate recording
      if (result == null) {
        _showErrorAndReset(
            'No audio recorded. Please speak clearly and try again.');
        return;
      }

      // Check minimum duration
      if (result.durationSeconds < AppConstants.minRecordingDurationSeconds) {
        _showErrorAndReset(
          'Recording too short (${result.durationSeconds.toStringAsFixed(1)}s). '
          'Please speak for at least ${AppConstants.minRecordingDurationSeconds}s.',
        );
        return;
      }

      // Create transcription
      final transcription = Transcription(
        id: _currentSession?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        rawText: streamResult.rawText,
        processedText: streamResult.processedText,
        createdAt: DateTime.now(),
        tokenUsage: streamResult.tokenUsage,
        promptId: _currentSession?.promptId ?? 'default',
        audioDurationSeconds: result.durationSeconds,
      );

      // Save transcription
      await _storageService.saveTranscription(transcription);

      // Notify completion
      _onTranscriptionComplete(transcription);
      _notificationService.showSuccess('Transcription saved successfully');

      debugPrint('[StreamingVoiceRecordingUseCase] Recording completed');
    } catch (e) {
      _notificationService.showError(_getErrorMessage(e));
      debugPrint('[StreamingVoiceRecordingUseCase] Stop error: $e');
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    debugPrint('[StreamingVoiceRecordingUseCase] Cancelling recording...');

    _autoStopTimer?.cancel();
    await _audioRecorder.stopRecording();
    await _transcriptionService.endStreamingSession();

    _cleanupSession();
  }

  /// Handle recording state changes
  void _handleRecordingStateChange(StreamingRecordingState state) {
    switch (state) {
      case StreamingRecordingState.recording:
        _autoStopTimer?.cancel();
        break;
      case StreamingRecordingState.paused:
        _autoStopTimer?.cancel();
        break;
      case StreamingRecordingState.idle:
        _autoStopTimer?.cancel();
        break;
      case StreamingRecordingState.error:
        _autoStopTimer?.cancel();
        _notificationService.showError('Recording error occurred');
        break;
      case StreamingRecordingState.processing:
        _autoStopTimer?.cancel();
        break;
    }
  }

  /// Handle transcription chunks
  void _handleTranscriptionChunk(TranscriptionChunk chunk) {
    if (chunk.isPartial) {
      // Auto-stop timer for silence detection (only if enabled)
      _autoStopTimer?.cancel();
      if (_autoStopAfterSilence) {
        _autoStopTimer = Timer(_autoStopSilence, () {
          debugPrint(
              '[StreamingVoiceRecordingUseCase] Auto-stopping due to silence');
          unawaited(stopRecording());
        });
      }
    }
  }

  /// Get current transcription text
  String get currentTranscription => _transcribedText;

  /// Get recording statistics
  RecordingStats? get recordingStats => _audioRecorder.stats;

  /// Check if recording is active
  bool get isRecording => _audioRecorder.isRecording;

  /// Pause recording
  Future<void> pauseRecording() async {
    await _audioRecorder.pauseRecording();
    _autoStopTimer?.cancel();
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    await _audioRecorder.resumeRecording();
  }

  /// Get vocabulary from settings
  Future<String> _getVocabulary() async {
    try {
      final vocabularySet = await _storageService.getVocabulary('default');
      return vocabularySet?.words.join(', ') ?? '';
    } catch (e) {
      debugPrint(
          '[StreamingVoiceRecordingUseCase] Error getting vocabulary: $e');
      return '';
    }
  }

  /// Get prompt template from settings
  Future<String> _getPromptTemplate() async {
    try {
      final prompt = await _storageService.getPrompt('default');
      return prompt?.promptTemplate ?? _getDefaultPrompt();
    } catch (e) {
      debugPrint('[StreamingVoiceRecordingUseCase] Error getting prompt: $e');
      return _getDefaultPrompt();
    }
  }

  /// Get prompt ID
  Future<String> _getPromptId() async {
    try {
      final prompt = await _storageService.getPrompt('default');
      return prompt?.id ?? 'default';
    } catch (e) {
      return 'default';
    }
  }

  /// Get critical instructions
  String _getCriticalInstructions() {
    return '''
CRITICAL INSTRUCTIONS:
- Transcribe only actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary provided is for reference ONLY - do not use it to generate fake transcriptions
''';
  }

  /// Get default prompt
  String _getDefaultPrompt() {
    return '''
Clean up the following speech transcription by:
1. Removing filler words (um, uh, like, you know)
2. Fixing obvious grammatical errors
3. Adding proper punctuation
4. Converting spoken numbers to digits where appropriate
5. Removing false starts and repetitions

Transcription: {{text}}

Cleaned transcription:''';
  }

  /// Show error and reset state
  void _showErrorAndReset(String message) {
    _notificationService.showError(message);
    _cleanupSession();
  }

  /// Clean up session state
  void _cleanupSession() {
    _currentSession = null;
    _transcribedText = '';
    _speechChunks = 0;
    _totalChunks = 0;
    _lastSpeechTime = null;
    _autoStopTimer?.cancel();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('permission')) {
        return 'Microphone access denied. Please check your settings.';
      }
      if (message.contains('network')) {
        return 'Network error. Please check your connection.';
      }
      if (message.contains('API')) {
        return 'API error. Please try again.';
      }
    }
    return 'An error occurred. Please try again.';
  }

  /// Dispose resources
  void dispose() {
    _stateSubscription?.cancel();
    _chunkSubscription?.cancel();
    _textSubscription?.cancel();
    _resultSubscription?.cancel();
    _autoStopTimer?.cancel();
    _audioRecorder.dispose();
    _transcriptionService.dispose();

    debugPrint('[StreamingVoiceRecordingUseCase] Disposed');
  }
}

/// Active transcription session
class TranscriptionSession {
  final String id;
  final DateTime startTime;
  final String vocabulary;
  final String promptId;
  DateTime? endTime;

  TranscriptionSession({
    required this.id,
    required this.startTime,
    required this.vocabulary,
    required this.promptId,
    this.endTime,
  });
}

/// Helper for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally unawaited
}
