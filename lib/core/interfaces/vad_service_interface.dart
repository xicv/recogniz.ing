/// Voice Activity Detection Service Interface
///
/// Defines the contract for VAD implementations.
/// Multiple implementations can provide different detection strategies:
/// - SileroVADService: ML-based detection using Silero VAD models
/// - AmplitudeVADService: Simple amplitude-based detection (fallback)
abstract class VadServiceInterface {
  /// Whether the VAD service has been initialized
  bool get isInitialized;

  /// Whether the VAD service is currently listening
  bool get isListening;

  /// Whether this VAD implementation is available on the current platform
  bool get isAvailable;

  /// Human-readable name of this VAD implementation
  String get name;

  /// Initialize the VAD service
  ///
  /// Returns `true` if initialization succeeded, `false` otherwise.
  Future<bool> initialize();

  /// Start VAD listening
  ///
  /// [onSpeechStart] Called when speech is first detected
  /// [onSpeechEnd] Called when speech ends, providing audio samples
  /// [onProbability] Called with speech probability (0.0 to 1.0) for each frame
  /// [onError] Called when an error occurs
  Future<void> startListening({
    required void Function(List<double> audioData) onSpeechStart,
    required void Function(List<double> audioData) onSpeechEnd,
    required void Function(double probability) onProbability,
    required void Function(String error) onError,
  });

  /// Stop VAD listening
  Future<void> stopListening();

  /// Process audio chunk and return speech probability
  ///
  /// Returns null if VAD is not initialized or not listening.
  double? processAudioChunk(List<double> audioData);

  /// Check if audio contains speech
  bool containsSpeech(List<double> audioData);

  /// Get speech segments from audio data
  List<SpeechSegment> getSpeechSegments(List<double> audioData,
      {int sampleRate});

  /// Dispose VAD resources
  Future<void> dispose();
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
