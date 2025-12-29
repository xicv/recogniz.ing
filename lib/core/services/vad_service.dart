import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import '../utils/audio_utils.dart';

/// Voice Activity Detection Service
/// Uses static methods for singleton pattern
class VadService {
  static bool _isInitialized = false;
  static bool _isListening = false;

  // VAD configuration optimized for voice typing
  static const double _speechThreshold = 0.5;
  static const double _silenceThreshold = 0.35;
  static const int _frameSize = 400; // 400ms frames
  static const int _sampleRate = 16000;

  static Function(List<double>)? _onSpeechStart;
  static Function(List<double>)? _onSpeechEnd;
  static Function(double)? _onProbability;

  /// Initialize VAD
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize VAD state
      _isInitialized = true;

      if (kDebugMode) {
        print('VAD initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize VAD: $e');
      }
      _isInitialized = false;
    }
  }

  /// Start VAD listening
  static Future<void> startListening({
    required Function(List<double> audioData) onSpeechStart,
    required Function(List<double> audioData) onSpeechEnd,
    required Function(double probability) onProbability,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      throw Exception('VAD not initialized');
    }

    _isListening = true;
    _onSpeechStart = onSpeechStart;
    _onSpeechEnd = onSpeechEnd;
    _onProbability = onProbability;

    if (kDebugMode) {
      print('VAD listening started');
    }
  }

  /// Stop VAD listening
  static void stopListening() {
    _isListening = false;
    _onSpeechStart = null;
    _onSpeechEnd = null;
    _onProbability = null;

    if (kDebugMode) {
      print('VAD listening stopped');
    }
  }

  /// Process audio chunk and return speech probability
  static double? processAudioChunk(List<double> audioData) {
    if (!_isInitialized || !_isListening) {
      return null;
    }

    try {
      // Calculate speech probability
      final probability = _calculateSpeechProbability(audioData);

      // Notify callbacks
      if (_onProbability != null) {
        _onProbability!(probability);
      }

      // Check for speech start/end
      if (probability > _speechThreshold) {
        if (_onSpeechStart != null) {
          _onSpeechStart!(audioData);
        }
      } else if (probability < _silenceThreshold) {
        if (_onSpeechEnd != null) {
          _onSpeechEnd!(audioData);
        }
      }

      return probability;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing audio: $e');
      }
      return null;
    }
  }

  /// Check if audio contains speech
  static bool containsSpeech(List<double> audioData) {
    final probability = processAudioChunk(audioData);
    return probability != null && probability > _speechThreshold;
  }

  /// Get speech segments from audio data
  static List<SpeechSegment> getSpeechSegments(List<double> audioData,
      {int sampleRate = _sampleRate}) {
    if (!_isInitialized) {
      return [];
    }

    final segments = <SpeechSegment>[];
    bool inSpeech = false;
    int speechStart = -1;

    for (int i = 0; i < audioData.length; i += _frameSize) {
      final frameEnd = (i + _frameSize).clamp(0, audioData.length);
      final frame = audioData.sublist(i, frameEnd);

      final probability = _calculateSpeechProbability(frame);
      final isSpeech = probability > _speechThreshold;

      // Detect speech start
      if (!inSpeech && isSpeech) {
        inSpeech = true;
        speechStart = i;
      }
      // Detect speech end
      else if (inSpeech && !isSpeech) {
        inSpeech = false;
        if (speechStart >= 0) {
          segments.add(SpeechSegment(
            start: speechStart,
            end: i,
            startTime: Duration(milliseconds: speechStart * 1000 ~/ sampleRate),
            endTime: Duration(milliseconds: i * 1000 ~/ sampleRate),
          ));
          speechStart = -1;
        }
      }
    }

    // Handle case where audio ends during speech
    if (inSpeech && speechStart >= 0) {
      segments.add(SpeechSegment(
        start: speechStart,
        end: audioData.length,
        startTime: Duration(milliseconds: speechStart * 1000 ~/ sampleRate),
        endTime: Duration(milliseconds: audioData.length * 1000 ~/ sampleRate),
      ));
    }

    return segments;
  }

  /// Calculate speech probability using shared AudioUtils
  static double _calculateSpeechProbability(List<double> audioData) {
    // Calculate RMS using shared utility
    final rms = AudioUtils.calculateRMSFromSamples(audioData);

    // Calculate speech ratio
    int speechSamples = 0;
    for (final sample in audioData) {
      if (sample.abs() > 0.01) {
        speechSamples++;
      }
    }
    final speechRatio = speechSamples / audioData.length;

    // Use shared utility for probability calculation
    return AudioUtils.calculateSpeechProbability(
      rms: rms,
      speechRatio: speechRatio,
      speechThreshold: _speechThreshold,
      silenceThreshold: _silenceThreshold,
    );
  }

  /// Optimize recording parameters for VAD
  static RecordConfig optimizeRecordingConfig(RecordConfig baseConfig) {
    return RecordConfig(
      encoder: AudioEncoder.wav, // Use WAV for better VAD processing
      sampleRate: _sampleRate,
      bitRate: 128000, // Adjust as needed
      numChannels: 1, // Mono for voice
      device: baseConfig.device,
    );
  }

  /// Dispose VAD resources
  static void dispose() {
    _isListening = false;
    _isInitialized = false;
  }

  /// Get VAD status
  static bool get isInitialized => _isInitialized;
  static bool get isListening => _isListening;
}

/// Speech segment data
class SpeechSegment {
  final int start;
  final int end;
  final Duration startTime;
  final Duration endTime;
  final Duration duration;

  SpeechSegment({
    required this.start,
    required this.end,
    required this.startTime,
    required this.endTime,
  }) : duration = endTime - startTime;
}
