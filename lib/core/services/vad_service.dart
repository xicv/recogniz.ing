import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import '../interfaces/vad_service_interface.dart';
import 'silero_vad_service.dart';
import 'amplitude_vad_service.dart';

/// Voice Activity Detection Service Facade
///
/// Provides a unified interface for Voice Activity Detection with graceful fallback.
/// Attempts to use Silero VAD (ML-based) first, falls back to Amplitude VAD
/// if Silero fails to initialize or becomes unavailable.
///
/// Architecture:
/// 1. On initialization, tries Silero VAD first
/// 2. If Silero fails, automatically falls back to Amplitude VAD
/// 3. All VAD operations delegate to the active implementation
/// 4. UI can check which implementation is active via `activeImplementationName`
///
/// Usage:
/// ```dart
/// await VadService.initialize();
/// final isActive = VadService.isSileroActive; // Check if Silero is being used
/// ```
class VadService {
  static VadServiceInterface? _activeImplementation;
  static bool _isInitialized = false;
  static bool _isSileroActive = false;

  // Configuration
  static const bool _preferSilero = true; // Set to false to force fallback

  /// Get the active VAD implementation name
  static String get activeImplementationName =>
      _activeImplementation?.name ?? 'None';

  /// Whether Silero VAD is currently active
  static bool get isSileroActive => _isSileroActive;

  /// Whether any VAD implementation is active
  static bool get isActive => _activeImplementation != null;

  /// Whether the VAD service has been initialized
  static bool get isInitialized => _isInitialized;

  /// Whether the VAD service is currently listening
  static bool get isListening => _activeImplementation?.isListening ?? false;

  /// Initialize VAD with automatic fallback
  ///
  /// Tries Silero VAD first, falls back to Amplitude VAD if Silero fails.
  /// Returns true if any implementation was initialized successfully.
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    if (kDebugMode) {
      print('[VadService] Initializing VAD service...');
    }

    if (_preferSilero) {
      // Try Silero VAD first
      if (kDebugMode) {
        print('[VadService] Attempting Silero VAD...');
      }
      final sileroVad = SileroVadService(
        model: 'v5',
        positiveSpeechThreshold: 0.5,
        negativeSpeechThreshold: 0.35,
        minSpeechFrames: 3,
      );

      final sileroInitialized = await sileroVad.initialize();
      if (sileroInitialized && sileroVad.isAvailable) {
        _activeImplementation = sileroVad;
        _isSileroActive = true;
        _isInitialized = true;

        if (kDebugMode) {
          print('[VadService] Silero VAD initialized successfully');
        }

        return true;
      }

      if (kDebugMode) {
        print('[VadService] Silero VAD failed to initialize, falling back to Amplitude VAD');
        if (sileroVad.initError != null) {
          print('[VadService] Silero error: ${sileroVad.initError}');
        }
      }

      // Clean up failed Silero service
      await sileroVad.dispose();
    }

    // Fall back to Amplitude VAD
    if (kDebugMode) {
      print('[VadService] Using Amplitude VAD (fallback)');
    }

    final amplitudeVad = AmplitudeVadService(
      speechThreshold: 0.5,
      silenceThreshold: 0.35,
    );

    final amplitudeInitialized = await amplitudeVad.initialize();
    if (amplitudeInitialized) {
      _activeImplementation = amplitudeVad;
      _isSileroActive = false;
      _isInitialized = true;

      if (kDebugMode) {
        print('[VadService] Amplitude VAD initialized successfully');
      }

      return true;
    }

    // Both implementations failed
    if (kDebugMode) {
      print('[VadService] All VAD implementations failed to initialize');
    }

    _isInitialized = false;
    return false;
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

    if (_activeImplementation == null) {
      throw Exception('VAD not initialized');
    }

    await _activeImplementation!.startListening(
      onSpeechStart: onSpeechStart,
      onSpeechEnd: onSpeechEnd,
      onProbability: onProbability,
      onError: (error) {
        if (kDebugMode) {
          print('[VadService] VAD error: $error');
        }
        // If Silero fails during operation, switch to fallback
        if (_isSileroActive) {
          _switchToFallback();
        }
      },
    );

    if (kDebugMode) {
      print('[VadService] VAD listening started using: $activeImplementationName');
    }
  }

  /// Stop VAD listening
  static Future<void> stopListening() async {
    await _activeImplementation?.stopListening();

    if (kDebugMode) {
      print('[VadService] VAD listening stopped');
    }
  }

  /// Process audio chunk and return speech probability
  static double? processAudioChunk(List<double> audioData) {
    return _activeImplementation?.processAudioChunk(audioData);
  }

  /// Check if audio contains speech
  static bool containsSpeech(List<double> audioData) {
    return _activeImplementation?.containsSpeech(audioData) ?? false;
  }

  /// Get speech segments from audio data
  static List<SpeechSegment> getSpeechSegments(List<double> audioData,
      {int sampleRate = 16000}) {
    final result = _activeImplementation?.getSpeechSegments(audioData,
        sampleRate: sampleRate);
    // The interface returns a List, but the concrete type may differ
    // We need to convert to our local SpeechSegment class
    if (result == null || result.isEmpty) {
      return [];
    }
    return result;
  }

  /// Optimize recording parameters for VAD
  static RecordConfig optimizeRecordingConfig(RecordConfig baseConfig) {
    return RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      bitRate: 16,
      numChannels: 1,
      device: baseConfig.device,
    );
  }

  /// Dispose VAD resources
  static Future<void> dispose() async {
    await _activeImplementation?.dispose();
    _activeImplementation = null;
    _isInitialized = false;
    _isSileroActive = false;

    if (kDebugMode) {
      print('[VadService] VAD disposed');
    }
  }

  /// Switch to fallback implementation
  static Future<void> _switchToFallback() async {
    if (!_isSileroActive) return;

    if (kDebugMode) {
      print('[VadService] Switching to Amplitude VAD fallback...');
    }

    // Dispose current implementation
    await _activeImplementation?.dispose();

    // Initialize fallback
    final amplitudeVad = AmplitudeVadService();
    await amplitudeVad.initialize();
    _activeImplementation = amplitudeVad;
    _isSileroActive = false;

    if (kDebugMode) {
      print('[VadService] Switched to Amplitude VAD');
    }
  }
}
