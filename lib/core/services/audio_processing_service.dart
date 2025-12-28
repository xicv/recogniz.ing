import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Audio processing service for improving voice recording quality
class AudioProcessingService {
  /// Apply noise reduction to raw audio data
  static Uint8List applyNoiseReduction(Uint8List audioData) {
    if (kDebugMode) {
      debugPrint('[AudioProcessing] Applying noise reduction');
    }

    // Convert bytes to 16-bit PCM samples
    final samples = _bytesToSamples(audioData);

    // Apply simple noise gate
    final noiseThreshold = 0.01; // Adjust based on environment
    final cleanedSamples = <double>[];

    for (int i = 0; i < samples.length; i++) {
      double sample = samples[i].abs();

      // Apply noise gate
      if (sample < noiseThreshold) {
        sample = 0;
      }

      cleanedSamples.add(sample * (samples[i] < 0 ? -1 : 1));
    }

    return _samplesToBytes(cleanedSamples);
  }

  /// Normalize audio levels
  static Uint8List normalizeAudio(Uint8List audioData) {
    if (kDebugMode) {
      debugPrint('[AudioProcessing] Normalizing audio levels');
    }

    final samples = _bytesToSamples(audioData);

    // Find peak value
    double peak = 0;
    for (final sample in samples) {
      peak = math.max(peak, sample.abs());
    }

    if (peak == 0) return audioData; // Silent audio

    // Calculate normalization factor
    final targetPeak = 0.95; // 95% of maximum
    final normalizationFactor = targetPeak / peak;

    // Apply normalization
    final normalizedSamples =
        samples.map((s) => s * normalizationFactor).toList();

    return _samplesToBytes(normalizedSamples);
  }

  /// Apply high-pass filter to remove low-frequency noise
  static Uint8List applyHighPassFilter(Uint8List audioData,
      {double cutoffFrequency = 80.0}) {
    if (kDebugMode) {
      debugPrint(
          '[AudioProcessing] Applying high-pass filter at ${cutoffFrequency}Hz');
    }

    final samples = _bytesToSamples(audioData);
    final filteredSamples = <double>[];
    const sampleRate = 16000.0;
    final rc = 1.0 / (2.0 * math.pi * cutoffFrequency);
    final dt = 1.0 / sampleRate;
    final alpha = rc / (rc + dt);

    double previousOutput = 0;
    double previousInput = 0;

    for (final input in samples) {
      final output = alpha * (previousOutput + input - previousInput);
      filteredSamples.add(output);
      previousOutput = output;
      previousInput = input;
    }

    return _samplesToBytes(filteredSamples);
  }

  /// Apply voice enhancement (combination of filters)
  static Uint8List processVoice(Uint8List audioData) {
    if (kDebugMode) {
      debugPrint('[AudioProcessing] Applying voice processing');
    }

    // Apply enhancement pipeline
    var enhanced = applyHighPassFilter(audioData, cutoffFrequency: 80.0);
    enhanced = applyNoiseReduction(enhanced);
    enhanced = normalizeAudio(enhanced);

    return enhanced;
  }

  /// Convert audio bytes to 16-bit PCM samples
  static List<double> _bytesToSamples(Uint8List bytes) {
    final samples = <double>[];
    for (int i = 0; i < bytes.length - 1; i += 2) {
      final sample = (bytes[i] | (bytes[i + 1] << 8));
      // Convert to signed 16-bit and normalize to -1.0 to 1.0
      final normalizedSample = (sample & 0x8000) != 0
          ? -(65536 - sample) / 32768.0
          : sample / 32767.0;
      samples.add(normalizedSample);
    }
    return samples;
  }

  /// Convert samples back to bytes
  static Uint8List _samplesToBytes(List<double> samples) {
    final bytes = Uint8List(samples.length * 2);
    for (int i = 0; i < samples.length; i++) {
      // Clamp and convert to 16-bit PCM
      final sample = samples[i].clamp(-1.0, 1.0);
      final intValue = (sample * 32767).round();
      bytes[i * 2] = intValue & 0xFF;
      bytes[i * 2 + 1] = (intValue >> 8) & 0xFF;
    }
    return bytes;
  }

  /// Get audio statistics
  static Map<String, dynamic> getAudioStats(Uint8List audioData) {
    final samples = _bytesToSamples(audioData);

    // Calculate RMS (Root Mean Square)
    double sum = 0;
    double peak = 0;
    int zeroCrossings = 0;

    for (int i = 0; i < samples.length; i++) {
      final sample = samples[i];
      sum += sample * sample;
      peak = math.max(peak, sample.abs());

      // Count zero crossings
      if (i > 0 && (samples[i - 1] < 0 && sample >= 0) ||
          (samples[i - 1] >= 0 && sample < 0)) {
        zeroCrossings++;
      }
    }

    final rms = math.sqrt(sum / samples.length);
    final zeroCrossingRate = zeroCrossings / samples.length;

    return {
      'rms': rms.toStringAsFixed(4),
      'peak': peak.toStringAsFixed(4),
      'zeroCrossingRate': zeroCrossingRate.toStringAsFixed(6),
      'samples': samples.length,
      'duration':
          '${(samples.length / 16000).toStringAsFixed(2)}s', // Assuming 16kHz
      'hasVoice':
          rms > 0.01 && zeroCrossingRate > 0.01, // Simple voice detection
    };
  }
}
