import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vad/vad.dart';
import '../interfaces/vad_service_interface.dart';

/// Silero VAD Service
///
/// ML-based Voice Activity Detection using Silero VAD models (v4/v5).
/// Provides enterprise-grade speech detection with high accuracy.
///
/// This implementation uses the `vad` package which provides:
/// - Direct FFI bindings to ONNX Runtime for native platforms
/// - Cross-platform support (iOS, Android, macOS, Windows, Linux, Web)
/// - Silero VAD v4/v5 models with configurable parameters
///
/// Model: Silero VAD v5 (default) or v4 (legacy)
/// Sample Rate: 16 kHz (fixed)
/// Frame Size: 512 samples (32ms) for v5, 1536 samples (96ms) for v4
class SileroVadService implements VadServiceInterface {
  VadHandler? _vadHandler;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = true;
  String _initError = '';

  // Callbacks
  void Function(List<double>)? _onSpeechStart;
  void Function(List<double>)? _onSpeechEnd;
  void Function(double)? _onProbability;
  void Function(String)? _onError;

  // Stream subscriptions
  final List<StreamSubscription> _subscriptions = [];

  // Recent probability for frame-by-frame processing
  double _lastProbability = 0.0;

  // VAD Configuration
  final String _model; // 'legacy' for v4, 'v5' for v5
  final double _positiveSpeechThreshold;
  final double _negativeSpeechThreshold;
  final int _minSpeechFrames;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  String get name => 'Silero VAD ($_model)';

  SileroVadService({
    String model = 'v5',
    double positiveSpeechThreshold = 0.5,
    double negativeSpeechThreshold = 0.35,
    int minSpeechFrames = 3,
  })  : _model = model,
        _positiveSpeechThreshold = positiveSpeechThreshold,
        _negativeSpeechThreshold = negativeSpeechThreshold,
        _minSpeechFrames = minSpeechFrames;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (kDebugMode) {
        print('[SileroVadService] Initializing Silero VAD ($_model)...');
      }

      // Create VadHandler
      _vadHandler = VadHandler.create(isDebug: kDebugMode);

      // Set up event listeners
      _setupEventListeners();

      _isInitialized = true;
      _isAvailable = true;

      if (kDebugMode) {
        print('[SileroVadService] Initialized successfully');
      }

      return true;
    } catch (e) {
      _initError = e.toString();
      _isAvailable = false;
      _isInitialized = false;

      if (kDebugMode) {
        print('[SileroVadService] Initialization failed: $e');
      }

      return false;
    }
  }

  void _setupEventListeners() {
    if (_vadHandler == null) return;

    // Speech start detection
    _subscriptions.add(_vadHandler!.onSpeechStart.listen((_) {
      if (kDebugMode) {
        print('[SileroVadService] Speech start detected');
      }
      _onSpeechStart?.call(<double>[]);
    }));

    // Real speech start (confirmed after minSpeechFrames)
    _subscriptions.add(_vadHandler!.onRealSpeechStart.listen((_) {
      if (kDebugMode) {
        print('[SileroVadService] Real speech confirmed');
      }
    }));

    // Speech end detection
    _subscriptions.add(_vadHandler!.onSpeechEnd.listen((samples) {
      if (kDebugMode) {
        print('[SileroVadService] Speech ended (${samples.length} samples)');
      }
      _onSpeechEnd?.call(samples);
    }));

    // Frame processed (for probability updates)
    _subscriptions.add(_vadHandler!.onFrameProcessed.listen((frameData) {
      // frameData.isSpeech is a double probability value (0.0 to 1.0)
      _lastProbability = frameData.isSpeech;
      _onProbability?.call(_lastProbability);
    }));

    // VAD misfire (speech detected but didn't meet minimum frames)
    _subscriptions.add(_vadHandler!.onVADMisfire.listen((_) {
      if (kDebugMode) {
        print('[SileroVadService] VAD misfire (false positive)');
      }
    }));

    // Error handling
    _subscriptions.add(_vadHandler!.onError.listen((message) {
      if (kDebugMode) {
        print('[SileroVadService] Error: $message');
      }
      _onError?.call(message);
    }));
  }

  @override
  Future<void> startListening({
    required void Function(List<double> audioData) onSpeechStart,
    required void Function(List<double> audioData) onSpeechEnd,
    required void Function(double probability) onProbability,
    required void Function(String error) onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Failed to initialize Silero VAD: $_initError');
        return;
      }
    }

    if (_vadHandler == null) {
      onError('VAD handler not available');
      return;
    }

    _onSpeechStart = onSpeechStart;
    _onSpeechEnd = onSpeechEnd;
    _onProbability = onProbability;
    _onError = onError;

    try {
      // Determine frame samples based on model
      final frameSamples = _model == 'v5' ? 512 : 1536;

      await _vadHandler!.startListening(
        frameSamples: frameSamples,
        minSpeechFrames: _minSpeechFrames,
        preSpeechPadFrames: 1,
        redemptionFrames: 8,
        positiveSpeechThreshold: _positiveSpeechThreshold,
        negativeSpeechThreshold: _negativeSpeechThreshold,
        model: _model,
      );

      _isListening = true;

      if (kDebugMode) {
        print('[SileroVadService] Listening started');
      }
    } catch (e) {
      _isAvailable = false;
      onError('Failed to start listening: $e');
      if (kDebugMode) {
        print('[SileroVadService] Failed to start listening: $e');
      }
    }
  }

  @override
  Future<void> stopListening() async {
    if (_vadHandler == null || !_isListening) {
      return;
    }

    try {
      await _vadHandler!.stopListening();
      _isListening = false;

      if (kDebugMode) {
        print('[SileroVadService] Listening stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SileroVadService] Error stopping: $e');
      }
    }
  }

  @override
  double? processAudioChunk(List<double> audioData) {
    if (!_isInitialized || !_isListening) {
      return null;
    }

    // Silero VAD processes frames internally via the audio stream
    // Return the last known probability
    return _lastProbability;
  }

  @override
  bool containsSpeech(List<double> audioData) {
    final probability = processAudioChunk(audioData);
    return probability != null && probability > _positiveSpeechThreshold;
  }

  @override
  List<SpeechSegment> getSpeechSegments(List<double> audioData,
      {int sampleRate = 16000}) {
    // Silero VAD detects segments in real-time during listening
    // For batch processing, we'd need to send audio through the handler
    // This is a simplified implementation that returns empty segments
    // In production, you'd collect segments during onSpeechStart/onSpeechEnd
    return [];
  }

  @override
  Future<void> dispose() async {
    if (_isListening) {
      await stopListening();
    }

    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    if (_vadHandler != null) {
      await _vadHandler!.dispose();
      _vadHandler = null;
    }

    _isInitialized = false;
    _isListening = false;

    if (kDebugMode) {
      print('[SileroVadService] Disposed');
    }
  }

  /// Get the initialization error if initialization failed
  String? get initError => _initError.isEmpty ? null : _initError;
}
