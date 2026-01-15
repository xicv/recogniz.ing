import 'dart:async';
import 'package:flutter/foundation.dart';
import '../interfaces/vad_service_interface.dart';
import '../utils/audio_utils.dart';

/// Amplitude VAD Service
///
/// Fallback Voice Activity Detection using RMS amplitude analysis.
/// This is a simplified implementation that:
/// - Calculates RMS (Root Mean Square) amplitude of audio
/// - Compares against fixed thresholds (speech/silence)
/// - Counts samples above threshold to determine "speech probability"
///
/// LIMITATIONS:
/// - Cannot distinguish speech from other loud sounds (music, typing, etc.)
/// - May have false positives in noisy environments
/// - Cannot detect voice characteristics (pitch, spectral features)
/// - Thresholds are heuristic and may need tuning per environment
///
/// This service is used as a fallback when Silero VAD is unavailable.
class AmplitudeVadService implements VadServiceInterface {
  bool _isInitialized = false;
  bool _isListening = false;

  // VAD configuration
  final double _speechThreshold;
  final double _silenceThreshold;
  final int _frameSize;

  // Callbacks
  void Function(List<double>)? _onSpeechStart;
  void Function(List<double>)? _onSpeechEnd;
  void Function(double)? _onProbability;
  void Function(String)? _onError;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => true; // Always available (no external dependencies)

  @override
  String get name => 'Amplitude VAD (fallback)';

  AmplitudeVadService({
    double speechThreshold = 0.5,
    double silenceThreshold = 0.35,
    int frameSize = 400,
  })  : _speechThreshold = speechThreshold,
        _silenceThreshold = silenceThreshold,
        _frameSize = frameSize;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = true;

      if (kDebugMode) {
        print('[AmplitudeVadService] Initialized successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[AmplitudeVadService] Failed to initialize: $e');
      }
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<void> startListening({
    required void Function(List<double> audioData) onSpeechStart,
    required void Function(List<double> audioData) onSpeechEnd,
    required void Function(double probability) onProbability,
    required void Function(String error) onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      onError('Amplitude VAD not initialized');
      return;
    }

    _isListening = true;
    _onSpeechStart = onSpeechStart;
    _onSpeechEnd = onSpeechEnd;
    _onProbability = onProbability;
    _onError = onError;

    if (kDebugMode) {
      print('[AmplitudeVadService] Listening started');
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _onSpeechStart = null;
    _onSpeechEnd = null;
    _onProbability = null;

    if (kDebugMode) {
      print('[AmplitudeVadService] Listening stopped');
    }
  }

  @override
  double? processAudioChunk(List<double> audioData) {
    if (!_isInitialized || !_isListening) {
      return null;
    }

    try {
      final probability = _calculateSpeechProbability(audioData);

      // Notify callbacks
      _onProbability?.call(probability);

      // Check for speech start/end
      if (probability > _speechThreshold) {
        _onSpeechStart?.call(audioData);
      } else if (probability < _silenceThreshold) {
        _onSpeechEnd?.call(audioData);
      }

      return probability;
    } catch (e) {
      if (kDebugMode) {
        print('[AmplitudeVadService] Error processing audio: $e');
      }
      _onError?.call(e.toString());
      return null;
    }
  }

  @override
  bool containsSpeech(List<double> audioData) {
    final probability = processAudioChunk(audioData);
    return probability != null && probability > _speechThreshold;
  }

  @override
  List<SpeechSegment> getSpeechSegments(List<double> audioData,
      {int sampleRate = 16000}) {
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

      if (!inSpeech && isSpeech) {
        inSpeech = true;
        speechStart = i;
      } else if (inSpeech && !isSpeech) {
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

  /// Calculate speech probability using RMS and speech ratio
  double _calculateSpeechProbability(List<double> audioData) {
    if (audioData.isEmpty) return 0.0;

    // Calculate RMS using shared utility
    final rms = AudioUtils.calculateRMSFromSamples(audioData);

    // Calculate speech ratio (samples above threshold)
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

  @override
  Future<void> dispose() async {
    _isListening = false;
    _isInitialized = false;
  }
}
