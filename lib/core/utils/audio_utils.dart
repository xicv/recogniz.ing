import 'dart:typed_data';
import 'dart:math' as math;

/// Shared audio utility functions
class AudioUtils {
  /// Calculate RMS (Root Mean Square) amplitude from raw audio bytes
  /// Assumes 16-bit PCM format
  static double calculateRMS(Uint8List audioBytes) {
    if (audioBytes.isEmpty) return 0.0;

    double sum = 0;
    final sampleCount = audioBytes.length ~/ 2;

    for (int i = 0; i < audioBytes.length - 1; i += 2) {
      final sample = (audioBytes[i] | (audioBytes[i + 1] << 8));
      final normalizedSample = (sample & 0x8000) != 0
          ? -(65536 - sample) / 32768.0
          : sample / 32767.0;
      sum += normalizedSample * normalizedSample;
    }

    return math.sqrt(sum / sampleCount);
  }

  /// Calculate RMS amplitude from a list of sample values
  static double calculateRMSFromSamples(List<double> samples) {
    if (samples.isEmpty) return 0.0;

    final sum = samples.fold<double>(
      0,
      (previous, sample) => previous + sample * sample,
    );

    return math.sqrt(sum / samples.length);
  }

  /// Calculate speech ratio (percentage of samples above threshold)
  static double calculateSpeechRatio(
    Uint8List audioBytes, {
    double threshold = 0.01,
  }) {
    if (audioBytes.isEmpty) return 0.0;

    int speechSamples = 0;
    final sampleCount = audioBytes.length ~/ 2;

    for (int i = 0; i < audioBytes.length - 1; i += 2) {
      final sample = (audioBytes[i] | (audioBytes[i + 1] << 8));
      final normalizedSample = (sample & 0x8000) != 0
          ? -(65536 - sample) / 32768.0
          : sample / 32767.0;

      if (normalizedSample.abs() > threshold) {
        speechSamples++;
      }
    }

    return speechSamples / sampleCount;
  }

  /// Find peak amplitude in audio bytes
  static double findPeakAmplitude(Uint8List audioBytes) {
    if (audioBytes.isEmpty) return 0.0;

    double peak = 0;

    for (int i = 0; i < audioBytes.length - 1; i += 2) {
      final sample = (audioBytes[i] | (audioBytes[i + 1] << 8));
      final normalizedSample = (sample & 0x8000) != 0
          ? -(65536 - sample) / 32768.0
          : sample / 32767.0;
      peak = math.max(peak, normalizedSample.abs());
    }

    return peak;
  }

  /// Calculate speech probability based on RMS and speech ratio
  static double calculateSpeechProbability({
    required double rms,
    required double speechRatio,
    double speechThreshold = 0.5,
    double silenceThreshold = 0.35,
  }) {
    // Combine RMS and speech ratio for a robust probability estimate
    final rmsFactor =
        (rms - silenceThreshold) / (speechThreshold - silenceThreshold);
    final combinedScore = rmsFactor * 0.6 + speechRatio * 0.4;

    return combinedScore.clamp(0.0, 1.0);
  }

  /// Convert audio bytes to 16-bit PCM samples
  static List<double> bytesToSamples(Uint8List bytes) {
    final samples = <double>[];
    for (int i = 0; i < bytes.length - 1; i += 2) {
      final sample = (bytes[i] | (bytes[i + 1] << 8));
      final normalizedSample = (sample & 0x8000) != 0
          ? -(65536 - sample) / 32768.0
          : sample / 32767.0;
      samples.add(normalizedSample);
    }
    return samples;
  }

  /// Convert samples back to bytes
  static Uint8List samplesToBytes(List<double> samples) {
    final bytes = Uint8List(samples.length * 2);
    for (int i = 0; i < samples.length; i++) {
      final sample = samples[i].clamp(-1.0, 1.0);
      final intValue = (sample * 32767).round();
      bytes[i * 2] = intValue & 0xFF;
      bytes[i * 2 + 1] = (intValue >> 8) & 0xFF;
    }
    return bytes;
  }
}
