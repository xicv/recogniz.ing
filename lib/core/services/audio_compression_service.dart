import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// Audio compression service for optimizing audio files before API upload
class AudioCompressionService {
  /// Compress audio file to a more efficient format
  static Future<String?> compressAudioFile({
    required String inputPath,
    int bitRate = 64000, // 64kbps default for voice
    int sampleRate = 16000, // 16kHz optimized for voice
    String format = 'aac',
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[AudioCompression] Starting compression of: $inputPath');
      }

      // For now, we'll use a simpler approach
      // The record package already compresses to AAC by default
      if (inputPath.endsWith('.m4a') || inputPath.endsWith('.aac')) {
        // Check if we need to re-compress at a lower bitrate
        final file = File(inputPath);
        final fileSize = await file.length();

        // If file is already small enough, just copy it
        if (fileSize < _getMaxFileSizeForBitRate(bitRate)) {
          if (kDebugMode) {
            debugPrint(
                '[AudioCompression] File already optimized: $fileSize bytes');
          }
          return inputPath;
        }
      }

      // Return original path for now - the record package already handles AAC compression
      if (kDebugMode) {
        debugPrint('[AudioCompression] Using optimized recording settings');
      }

      return inputPath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AudioCompression] Error compressing audio: $e');
      }
      return null;
    }
  }

  /// Compress raw audio bytes with optimized settings for voice
  static Future<Uint8List?> compressAudioBytes({
    required Uint8List audioBytes,
    int sampleRate = 16000,
    int bitRate = 64000,
    String format = 'aac',
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
            '[AudioCompression] Compressing ${audioBytes.length} bytes of audio');
      }

      // Calculate compression ratio
      final targetSize = (audioBytes.length * bitRate) ~/ (sampleRate * 16 * 8);
      final compressionRatio = audioBytes.length / targetSize;

      if (kDebugMode) {
        debugPrint(
            '[AudioCompression] Target compression ratio: ${compressionRatio.toStringAsFixed(2)}x');
      }

      // For voice audio, we can apply a simple compression by:
      // 1. Resampling to 16kHz if needed
      // 2. Reducing bit depth to 16-bit
      // 3. Applying basic compression

      final compressedBytes = _applyVoiceCompression(audioBytes, sampleRate);

      if (kDebugMode) {
        final actualRatio = audioBytes.length / compressedBytes.length;
        debugPrint(
            '[AudioCompression] Actual compression: ${actualRatio.toStringAsFixed(2)}x');
      }

      return compressedBytes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AudioCompression] Error compressing audio bytes: $e');
      }
      return null;
    }
  }

  /// Get recommended recording config for voice
  static RecordConfig getVoiceOptimizedConfig() {
    return const RecordConfig(
      encoder: AudioEncoder.aacLc, // AAC-LC is efficient for voice
      sampleRate: 16000, // Voice optimized
      bitRate: 64000, // 64kbps - good balance of quality and size
      numChannels: 1, // Mono for voice
    );
  }

  /// Estimate compression ratio for given settings
  static double estimateCompressionRatio({
    required int originalBitRate,
    required int targetBitRate,
    String format = 'aac',
  }) {
    // AAC typically achieves 10:1 compression at 64kbps for voice
    const aacEfficiency = 10.0;

    switch (format) {
      case 'aac':
      case 'aac_lc':
        return aacEfficiency * (targetBitRate / originalBitRate);
      case 'mp3':
        return aacEfficiency *
            0.8 *
            (targetBitRate / originalBitRate); // MP3 is less efficient
      default:
        return 1.0;
    }
  }

  /// Apply basic voice compression to raw bytes
  static Uint8List _applyVoiceCompression(
      Uint8List bytes, int targetSampleRate) {
    // This is a simplified compression that:
    // 1. Reduces dynamic range for voice
    // 2. Removes frequencies outside voice range (80Hz - 8kHz)
    // 3. Applies basic compression

    // For now, return the original bytes with minimal processing
    // In a real implementation, you would apply audio processing algorithms
    return Uint8List.fromList(bytes);
  }

  /// Get max file size for given bitrate (1 minute of audio)
  static int _getMaxFileSizeForBitRate(int bitRate) {
    // Calculate: bitRate * 60 seconds / 8 bits per byte
    return (bitRate * 60) ~/ 8;
  }

  /// Validate if audio is properly compressed
  static bool isAudioOptimized({
    required int fileSize,
    required double durationSeconds,
    required int bitRate,
  }) {
    final expectedSize = (bitRate * durationSeconds) ~/ 8;
    final tolerance = expectedSize * 0.2; // Allow 20% tolerance

    return (fileSize - expectedSize).abs() <= tolerance;
  }

  /// Get compression statistics
  static Map<String, dynamic> getCompressionStats({
    required int originalSize,
    required int compressedSize,
    required double durationSeconds,
  }) {
    final compressionRatio = originalSize / compressedSize;
    final savingsPercent =
        ((originalSize - compressedSize) / originalSize * 100).round();
    final finalBitRate = (compressedSize * 8) ~/ durationSeconds;

    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': '${compressionRatio.toStringAsFixed(2)}x',
      'savingsPercent': '$savingsPercent%',
      'finalBitRate': '${finalBitRate}kbps',
      'duration': '${durationSeconds.toStringAsFixed(1)}s',
    };
  }
}
