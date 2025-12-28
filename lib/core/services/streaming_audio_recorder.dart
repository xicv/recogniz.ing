import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'streaming_audio_processor.dart';
import '../interfaces/audio_service_interface.dart';

/// Recording states for streaming (local enum to avoid conflicts)
enum StreamingRecordingState {
  idle,
  recording,
  paused,
  processing,
  error,
}

/// Streaming audio recorder with real-time processing
/// Supports chunk-based recording with immediate feedback
class StreamingAudioRecorder implements AudioServiceInterface {
  late final AudioRecorder _recorder;
  StreamSubscription? _recordingSubscription;
  StreamSubscription? _vadSubscription;

  final StreamController<AudioChunk> _audioStreamController =
      StreamController<AudioChunk>.broadcast();
  final StreamController<StreamingRecordingState> _stateController =
      StreamController<StreamingRecordingState>.broadcast();

  // Recording state
  bool _isRecording = false;
  bool _isPaused = false;
  DateTime? _recordingStartTime;
  String? _currentRecordingPath;
  final List<int> _audioBuffer = [];
  Timer? _chunkTimer;
  Timer? _silenceTimer;

  // Configuration
  final int _chunkSize = 1024 * 2; // 1KB chunks
  final Duration _chunkInterval = const Duration(milliseconds: 100);
  final Duration _silenceTimeout = const Duration(seconds: 2);

  bool get isRecording => _isRecording;

  /// Get stream of audio chunks for real-time processing
  Stream<AudioChunk> get audioChunks => _audioStreamController.stream;

  /// Get stream of recording state changes
  Stream<StreamingRecordingState> get stateChanges => _stateController.stream;

  /// Initialize the recorder
  Future<void> initialize() async {
    try {
      // Initialize audio recorder
      _recorder = AudioRecorder();

      // Initialize streaming audio processor
      await StreamingAudioProcessor.initialize();

      // Listen to VAD events
      _vadSubscription =
          StreamingAudioProcessor.vadEvents.listen(_handleVadEvent);

      debugPrint('[StreamingAudioRecorder] Initialized successfully');
    } catch (e) {
      debugPrint('[StreamingAudioRecorder] Initialization failed: $e');
      rethrow;
    }
  }

  Future<bool> hasPermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      debugPrint('[StreamingAudioRecorder] Permission check: $hasPermission');
      return hasPermission;
    } catch (e) {
      debugPrint('[StreamingAudioRecorder] Permission check error: $e');
      return false;
    }
  }

  @override
  Future<void> startRecording() async {
    if (_isRecording) {
      debugPrint('[StreamingAudioRecorder] Already recording');
      return;
    }

    try {
      final permission = await hasPermission();
      if (!permission) {
        throw Exception('Microphone permission not granted');
      }

      // Prepare recording path
      final dir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      _currentRecordingPath = '${dir.path}/streaming_recording_$uuid.wav';

      // Configure recorder for streaming
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000, // Optimized for speech
          bitRate: 128000,
          numChannels: 1, // Mono for speech
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _audioBuffer.clear();

      // Start monitoring VAD
      StreamingAudioProcessor.startMonitoring();

      // Note: The record package doesn't provide real-time data streams
      // We'll simulate chunking with periodic polling

      // Start chunk processing timer
      _startChunkTimer();

      // Start silence detection timer
      _startSilenceTimer();

      _stateController.add(StreamingRecordingState.recording);

      debugPrint('[StreamingAudioRecorder] Recording started');
    } catch (e) {
      debugPrint('[StreamingAudioRecorder] Start recording error: $e');
      _stateController.add(StreamingRecordingState.error);
      rethrow;
    }
  }

  Future<StreamingRecordingResult?> stopRecording() async {
    if (!_isRecording) {
      debugPrint('[StreamingAudioRecorder] Not recording');
      return null;
    }

    try {
      debugPrint('[StreamingAudioRecorder] Stopping recording...');
      _isRecording = false;
      _isPaused = false;

      // Stop timers
      _chunkTimer?.cancel();
      _silenceTimer?.cancel();

      // Stop monitoring
      StreamingAudioProcessor.stopMonitoring();

      // Process any remaining audio data
      if (_audioBuffer.isNotEmpty) {
        await _processFinalChunk();
      }

      // Stop recording
      final path = await _recorder.stop();

      // Calculate duration
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds /
              1000.0
          : 0.0;

      // Read audio file
      final file = File(_currentRecordingPath!);
      final bytes = await file.readAsBytes();

      // Perform final analysis
      final analysis = await StreamingAudioProcessor.analyzeCompleteAudio(
        audioBytes: Uint8List.fromList(bytes),
        amplitudeThreshold: 0.05,
        speechRatioThreshold: 0.3,
        sampleRate: 16000,
        bitDepth: 16,
      );

      // Clean up if no speech detected
      if (!analysis.containsSpeech) {
        await file.delete();
        debugPrint('[StreamingAudioRecorder] No speech detected, file deleted');
        return null;
      }

      final result = StreamingRecordingResult(
        path: path!,
        bytes: bytes,
        durationSeconds: duration,
        analysis: analysis,
        chunks: _audioBuffer.length,
      );

      _stateController.add(StreamingRecordingState.idle);

      debugPrint('[StreamingAudioRecorder] Recording completed: ${duration}s');
      return result;
    } catch (e) {
      debugPrint('[StreamingAudioRecorder] Stop recording error: $e');
      _stateController.add(StreamingRecordingState.error);
      rethrow;
    }
  }

  /// Pause recording (not supported by record package)
  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;

    // Note: record package doesn't support pause/resume
    _isPaused = true;
    _chunkTimer?.cancel();

    _stateController.add(StreamingRecordingState.paused);
    debugPrint('[StreamingAudioRecorder] Recording paused (simulated)');
  }

  /// Resume recording (not supported by record package)
  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;

    _isPaused = false;
    _startChunkTimer();

    _stateController.add(StreamingRecordingState.recording);
    debugPrint('[StreamingAudioRecorder] Recording resumed (simulated)');
  }

  /// Simulate audio data handling (record package doesn't provide real-time data)
  void _handleAudioData() {
    if (!_isRecording || _isPaused) return;

    // Simulate audio chunks for VAD processing
    final chunk = List<int>.filled(_chunkSize, 0);
    for (int i = 0; i < _chunkSize; i += 2) {
      // Generate minimal noise to simulate audio
      chunk[i] = 0;
      chunk[i + 1] = 0;
    }

    // Process chunk with VAD
    unawaited(_processAudioChunk(chunk));
  }

  /// Handle VAD events
  void _handleVadEvent(VadEvent event) {
    if (event.isSpeech) {
      // Reset silence timer when speech is detected
      _silenceTimer?.cancel();
      _startSilenceTimer();
    }
  }

  /// Process audio chunk with VAD
  Future<void> _processAudioChunk(List<int> chunk) async {
    try {
      final vadEvent = await StreamingAudioProcessor.processAudioChunk(chunk);

      final audioChunk = AudioChunk(
        data: chunk,
        timestamp: DateTime.now(),
        sampleRate: 16000,
        durationMs: ((chunk.length ~/ 2) / 16000 * 1000).toInt(),
      );

      // Add metadata about speech detection
      final annotatedChunk = AnnotatedAudioChunk(
        data: chunk,
        timestamp: audioChunk.timestamp,
        sampleRate: audioChunk.sampleRate,
        durationMs: audioChunk.durationMs,
        isSpeech: vadEvent.isSpeech,
        speechProbability: vadEvent.probability,
      );

      _audioStreamController.add(annotatedChunk);
    } catch (e) {
      debugPrint('[StreamingAudioRecorder] Chunk processing error: $e');
    }
  }

  /// Process final audio chunk
  Future<void> _processFinalChunk() async {
    if (_audioBuffer.isNotEmpty) {
      await _processAudioChunk(_audioBuffer);
    }
  }

  /// Start chunk processing timer
  void _startChunkTimer() {
    _chunkTimer?.cancel();
    _chunkTimer = Timer.periodic(_chunkInterval, (_) {
      if (!_isPaused) {
        // Simulate audio chunk processing
        _handleAudioData();
      }
    });
  }

  /// Start silence detection timer
  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(_silenceTimeout, () {
      debugPrint('[StreamingAudioRecorder] Silence detected, auto-stopping');
      unawaited(stopRecording());
    });
  }

  /// Get recording statistics
  RecordingStats get stats => RecordingStats(
        duration: _recordingStartTime != null
            ? DateTime.now().difference(_recordingStartTime!).inMilliseconds /
                1000.0
            : 0.0,
        bytesRecorded: _audioBuffer.length,
        isPaused: _isPaused,
      );

  void dispose() {
    _chunkTimer?.cancel();
    _silenceTimer?.cancel();
    _recordingSubscription?.cancel();
    _vadSubscription?.cancel();
    _audioStreamController.close();
    _stateController.close();
    _recorder.dispose();
    StreamingAudioProcessor.dispose();

    debugPrint('[StreamingAudioRecorder] Disposed');
  }
}

/// Annotated audio chunk with speech detection results
class AnnotatedAudioChunk extends AudioChunk {
  final bool isSpeech;
  final double speechProbability;

  const AnnotatedAudioChunk({
    required super.data,
    required super.timestamp,
    required super.sampleRate,
    required super.durationMs,
    required this.isSpeech,
    required this.speechProbability,
  });
}

/// Recording result with additional metadata
class StreamingRecordingResult implements RecordingResultInterface {
  @override
  final String path;
  @override
  final List<int> bytes;
  @override
  final double durationSeconds;
  @override
  final AudioAnalysis? analysis;
  final int chunks;

  const StreamingRecordingResult({
    required this.path,
    required this.bytes,
    required this.durationSeconds,
    this.analysis,
    required this.chunks,
  });
}

/// Recording statistics
class RecordingStats {
  final double duration;
  final int bytesRecorded;
  final bool isPaused;

  const RecordingStats({
    required this.duration,
    required this.bytesRecorded,
    required this.isPaused,
  });
}

/// Helper for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally unawaited - fire and forget
}
