import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Result of audio analysis containing speech detection metrics
class AudioAnalysisResult {
  final double averageAmplitude;
  final double maxAmplitude;
  final double speechRatio;
  final bool containsSpeech;
  final String reason;

  const AudioAnalysisResult({
    required this.averageAmplitude,
    required this.maxAmplitude,
    required this.speechRatio,
    required this.containsSpeech,
    required this.reason,
  });
}

/// Service for analyzing audio to detect speech content before API calls
class AudioAnalyzer {
  static AudioAnalysisResult analyzeAudioBytes(
    Uint8List bytes, {
    double amplitudeThreshold = 0.01, // Lowered from 0.02 to be more sensitive
    double speechRatioThreshold = 0.05, // Lowered from 0.1 to be more lenient
    int sampleRate = 44100,
    int bitDepth = 16,
  }) {
    try {
      // Convert bytes to 16-bit samples
      final List<int> samples = _convertToSamples(bytes, bitDepth);

      if (samples.isEmpty) {
        return const AudioAnalysisResult(
          averageAmplitude: 0.0,
          maxAmplitude: 0.0,
          speechRatio: 0.0,
          containsSpeech: false,
          reason: 'No audio samples found',
        );
      }

      // Calculate amplitude metrics
      final double averageAmplitude = _calculateAverageAmplitude(samples);
      final double maxAmplitude = _calculateMaxAmplitude(samples);

      // Calculate speech ratio (percentage of samples above threshold)
      final int samplesAboveThreshold = _countSamplesAboveThreshold(
        samples,
        amplitudeThreshold,
      );
      final double speechRatio = samplesAboveThreshold / samples.length;

      // Determine if speech is present
      final bool containsSpeech = _detectSpeech(
        averageAmplitude: averageAmplitude,
        maxAmplitude: maxAmplitude,
        speechRatio: speechRatio,
        amplitudeThreshold: amplitudeThreshold,
        speechRatioThreshold: speechRatioThreshold,
      );

      String reason;
      if (!containsSpeech) {
        if (averageAmplitude < amplitudeThreshold * 0.5) {
          reason =
              'Audio too quiet (avg amplitude: ${averageAmplitude.toStringAsFixed(4)})';
        } else if (speechRatio < speechRatioThreshold) {
          reason =
              'Insufficient speech activity (speech ratio: ${(speechRatio * 100).toStringAsFixed(1)}%)';
        } else {
          reason = 'Audio appears to be mostly noise or silence';
        }
      } else {
        reason =
            'Speech detected (avg: ${averageAmplitude.toStringAsFixed(4)}, '
            'max: ${maxAmplitude.toStringAsFixed(4)}, '
            'speech ratio: ${(speechRatio * 100).toStringAsFixed(1)}%)';
      }

      debugPrint('[AudioAnalyzer] Analysis complete:');
      debugPrint(
          '  - Average amplitude: ${averageAmplitude.toStringAsFixed(4)}');
      debugPrint('  - Max amplitude: ${maxAmplitude.toStringAsFixed(4)}');
      debugPrint(
          '  - Speech ratio: ${(speechRatio * 100).toStringAsFixed(1)}%');
      debugPrint('  - Contains speech: $containsSpeech');
      debugPrint('  - Reason: $reason');

      return AudioAnalysisResult(
        averageAmplitude: averageAmplitude,
        maxAmplitude: maxAmplitude,
        speechRatio: speechRatio,
        containsSpeech: containsSpeech,
        reason: reason,
      );
    } catch (e) {
      debugPrint('[AudioAnalyzer] Error analyzing audio: $e');
      return AudioAnalysisResult(
        averageAmplitude: 0.0,
        maxAmplitude: 0.0,
        speechRatio: 0.0,
        containsSpeech: false,
        reason: 'Error analyzing audio: $e',
      );
    }
  }

  /// Convert raw audio bytes to signed 16-bit integer samples
  static List<int> _convertToSamples(Uint8List bytes, int bitDepth) {
    final List<int> samples = [];

    if (bitDepth == 16) {
      // Process 16-bit PCM (little-endian)
      for (int i = 0; i < bytes.length - 1; i += 2) {
        // Combine two bytes into a 16-bit signed integer
        int sample = bytes[i] | (bytes[i + 1] << 8);
        // Convert to signed value if necessary
        if (sample > 32767) sample -= 65536;
        samples.add(sample);
      }
    } else {
      // For other bit depths, we'll use a simplified approach
      // In a real implementation, you'd handle different bit depths properly
      debugPrint(
          '[AudioAnalyzer] Warning: Using simplified conversion for bit depth $bitDepth');
      for (int i = 0; i < bytes.length; i++) {
        samples.add(bytes[i] - 128); // Convert to signed value
      }
    }

    return samples;
  }

  /// Calculate RMS (Root Mean Square) amplitude
  static double _calculateAverageAmplitude(List<int> samples) {
    if (samples.isEmpty) return 0.0;

    double sum = 0.0;
    for (int sample in samples) {
      sum += sample * sample;
    }

    // Calculate RMS and normalize to 0-1 range (for 16-bit audio)
    final rms = (sum / samples.length);
    return (math.sqrt(rms)) / 32768.0;
  }

  /// Calculate maximum amplitude value
  static double _calculateMaxAmplitude(List<int> samples) {
    if (samples.isEmpty) return 0.0;

    int maxSample = 0;
    for (int sample in samples) {
      final int absSample = sample.abs();
      if (absSample > maxSample) {
        maxSample = absSample;
      }
    }

    // Normalize to 0-1 range (assuming 16-bit audio)
    return maxSample / 32768.0;
  }

  /// Count samples that exceed the amplitude threshold
  static int _countSamplesAboveThreshold(List<int> samples, double threshold) {
    final int thresholdValue = (threshold * 32768).round();
    int count = 0;

    for (int sample in samples) {
      if (sample.abs() > thresholdValue) {
        count++;
      }
    }

    return count;
  }

  /// Determine if audio contains speech based on various metrics
  static bool _detectSpeech({
    required double averageAmplitude,
    required double maxAmplitude,
    required double speechRatio,
    required double amplitudeThreshold,
    required double speechRatioThreshold,
  }) {
    // Debug output for understanding values
    debugPrint('[AudioAnalyzer] Detection logic:');
    debugPrint(
        '  - Avg amplitude vs threshold: ${averageAmplitude.toStringAsFixed(5)} vs ${(amplitudeThreshold).toStringAsFixed(5)}');
    debugPrint('  - Max amplitude: ${maxAmplitude.toStringAsFixed(5)}');
    debugPrint(
        '  - Speech ratio: ${(speechRatio * 100).toStringAsFixed(1)}% vs ${(speechRatioThreshold * 100).toStringAsFixed(1)}%');

    // Rule 1: Check if average amplitude is too low (likely silent)
    if (averageAmplitude < amplitudeThreshold) {
      debugPrint('  - Rejected: Average amplitude too low');
      return false;
    }

    // Rule 2: Check if maximum amplitude is reasonable (not completely silent)
    if (maxAmplitude < amplitudeThreshold * 0.5) {
      debugPrint('  - Rejected: Max amplitude too low');
      return false;
    }

    // Rule 3: Check speech ratio - this is the main indicator
    if (speechRatio < speechRatioThreshold) {
      debugPrint('  - Rejected: Speech ratio too low');
      return false;
    }

    // Rule 4: Check for constant amplitude (possible white noise or hum)
    // Speech typically has variation, so if everything is at max amplitude, it's likely noise
    if (averageAmplitude > 0.7 && maxAmplitude >= 0.99) {
      debugPrint('  - Rejected: Possible clipping or constant noise');
      return false;
    }

    // Rule 5: Check minimum duration and content
    // For very short recordings, be more lenient
    if (averageAmplitude > amplitudeThreshold * 2 &&
        speechRatio > speechRatioThreshold * 0.5) {
      debugPrint('  - Accepted: Strong signal despite ratio');
      return true;
    }

    debugPrint('  - Accepted: Normal speech characteristics');
    return true;
  }

  /// Quick check to determine if audio is worth sending to API
  static bool shouldSendToApi(AudioAnalysisResult analysis) {
    return analysis.containsSpeech;
  }
}
