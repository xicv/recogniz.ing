import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../utils/audio_utils.dart';

/// Audio processing service for improving voice recording quality
class AudioProcessingService {
  /// Apply noise reduction to raw audio data
  static Uint8List applyNoiseReduction(Uint8List audioData) {
    if (kDebugMode) {
      debugPrint('[AudioProcessing] Applying noise reduction');
    }

    // Convert bytes to 16-bit PCM samples using shared utility
    final samples = AudioUtils.bytesToSamples(audioData);

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

    return AudioUtils.samplesToBytes(cleanedSamples);
  }

  /// Normalize audio levels
  static Uint8List normalizeAudio(Uint8List audioData) {
    if (kDebugMode) {
      debugPrint('[AudioProcessing] Normalizing audio levels');
    }

    final samples = AudioUtils.bytesToSamples(audioData);

    // Find peak value using shared utility
    final peak = AudioUtils.findPeakAmplitude(audioData);

    if (peak == 0) return audioData; // Silent audio

    // Calculate normalization factor
    final targetPeak = 0.95; // 95% of maximum
    final normalizationFactor = targetPeak / peak;

    // Apply normalization
    final normalizedSamples =
        samples.map((s) => s * normalizationFactor).toList();

    return AudioUtils.samplesToBytes(normalizedSamples);
  }

  /// Apply high-pass filter to remove low-frequency noise
  static Uint8List applyHighPassFilter(Uint8List audioData,
      {double cutoffFrequency = 80.0}) {
    if (kDebugMode) {
      debugPrint(
          '[AudioProcessing] Applying high-pass filter at ${cutoffFrequency}Hz');
    }

    final samples = AudioUtils.bytesToSamples(audioData);
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

    return AudioUtils.samplesToBytes(filteredSamples);
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

  /// Get audio statistics using shared utilities
  static Map<String, dynamic> getAudioStats(Uint8List audioData) {
    final samples = AudioUtils.bytesToSamples(audioData);

    // Calculate RMS using shared utility
    final rms = AudioUtils.calculateRMS(audioData);

    // Find peak using shared utility
    final peak = AudioUtils.findPeakAmplitude(audioData);

    // Count zero crossings
    int zeroCrossings = 0;
    for (int i = 1; i < samples.length; i++) {
      if ((samples[i - 1] < 0 && samples[i] >= 0) ||
          (samples[i - 1] >= 0 && samples[i] < 0)) {
        zeroCrossings++;
      }
    }

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
