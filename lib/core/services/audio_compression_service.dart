import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../models/app_settings.dart';

/// Audio format options for recording
enum AudioFormat {
  /// AAC-LC compressed format (default, smaller files, but may have truncation issues)
  ///
  /// ⚠️ WARNING: AAC encoders have a KNOWN BUG where they lose 0.5-2 seconds
  /// at the end of recordings due to unflushed encoder buffers. This is a bug in
  /// Android/iOS AAC encoders that cannot be worked around at recording time.
  ///
  /// Format: M4A/AAC
  /// Size: ~480 KB/minute (at 64 kbps)
  /// Truncation Risk: HIGH (0.5-2 seconds lost at end)
  aacLc,

  /// Uncompressed PCM format (larger files, but no truncation risk)
  ///
  /// ✅ SAFE: PCM format has no encoder buffering and guarantees all audio
  /// is captured exactly as recorded. This is the RECOMMENDED format for
  /// important recordings.
  ///
  /// Format: WAV/PCM
  /// Size: ~1.92 MB/minute (at 16kHz, 16-bit, mono)
  /// Truncation Risk: NONE
  pcm16bits,
}

/// Audio compression service for optimizing audio files before API upload
///
/// ## Important Note on AAC Truncation Bug
///
/// There is a KNOWN BUG in Android/iOS AAC encoders where recordings lose
/// 0.5-2 seconds at the end due to unflushed encoder buffers. This is
/// documented in multiple Stack Overflow threads and cannot be worked around
/// during recording.
///
/// References:
/// - https://stackoverflow.com/questions/15886416/mediarecorder-cuts-off-end-of-file
/// - https://stackoverflow.com/questions/31658736/android-audiorecording-losing-last-few-seconds-of-audio
///
/// ## Solution
///
/// Use PCM format for recording (guarantees no truncation), then optionally
/// compress to AAC AFTER recording is complete if smaller file size is needed.
/// The original PCM file should always be preserved locally as backup.
class AudioCompressionService {
  /// Whether to use PCM format for reliable recording (no truncation)
  ///
  /// Set to true to use uncompressed PCM format which guarantees all audio
  /// is captured, but results in 4x larger files. Set to false for AAC compression
  /// which is smaller but may lose some audio due to encoder buffering issues.
  ///
  /// ⚠️ IMPORTANT: If set to false (AAC), recordings may lose the last 0.5-2 seconds.
  static bool useReliableFormat =
      true; // ENABLED: Using PCM for reliable recording
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
  ///
  /// By default uses AAC-LC compression for smaller file sizes. If [useReliableFormat]
  /// is true, returns an uncompressed PCM config that eliminates truncation issues
  /// at the cost of 4x larger file sizes.
  static RecordConfig getVoiceOptimizedConfig({bool? forceReliable}) {
    final useReliable = forceReliable ?? useReliableFormat;

    if (useReliable) {
      // Use uncompressed PCM for maximum reliability
      return const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      );
    }

    // Default: AAC-LC compression for smaller files
    return const RecordConfig(
      encoder: AudioEncoder.aacLc, // AAC-LC is efficient for voice
      sampleRate: 16000, // Voice optimized
      bitRate: 64000, // 64kbps - good balance of quality and size
      numChannels: 1, // Mono for voice
    );
  }

  /// Get recommended recording config based on duration and user preference
  ///
  /// Implements smart format selection:
  /// - **auto**: Duration-based selection
  ///   - < 2 min: AAC (compressed, fast)
  ///   - 2-5 min: AAC with warning about potential truncation
  ///   - 5+ min: PCM (uncompressed, no truncation risk)
  /// - **alwaysCompressed**: Always use AAC regardless of duration
  /// - **uncompressed**: Always use PCM regardless of duration
  ///
  /// Returns a tuple of (RecordConfig, shouldShowWarning, warningMessage).
  static (RecordConfig config, bool showWarning, String? warning)
      getConfigForPreference({
    required Duration estimatedDuration,
    required AudioCompressionPreference preference,
  }) {
    final durationSeconds = estimatedDuration.inSeconds;

    switch (preference) {
      case AudioCompressionPreference.alwaysCompressed:
        return (
          getConfigForFormat(AudioFormat.aacLc),
          true,
          'AAC format may lose 0.5-2 seconds at the end due to encoder buffering. '
              'Use "Uncompressed" for important recordings.',
        );

      case AudioCompressionPreference.uncompressed:
        return (
          getConfigForFormat(AudioFormat.pcm16bits),
          false,
          null,
        );

      case AudioCompressionPreference.auto:
        // Auto mode: smart selection based on duration
        if (durationSeconds < 120) {
          // < 2 minutes: Use AAC (fast, small files, minimal impact)
          return (
            getConfigForFormat(AudioFormat.aacLc),
            false,
            null,
          );
        } else if (durationSeconds < 300) {
          // 2-5 minutes: Use AAC with warning
          return (
            getConfigForFormat(AudioFormat.aacLc),
            true,
            'Recording is ${_formatDuration(durationSeconds)}. AAC format may lose 0.5-2 seconds '
                'at the end. Consider using "Uncompressed" preference for better reliability.',
          );
        } else {
          // 5+ minutes: Use PCM automatically
          return (
            getConfigForFormat(AudioFormat.pcm16bits),
            false,
            null,
          );
        }
    }
  }

  /// Format duration for display (e.g., "2:30", "5:15")
  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Get a reliable recording config that guarantees no audio truncation
  ///
  /// Uses uncompressed PCM format which eliminates the AAC encoder buffering
  /// issues that cause audio loss. Results in 4x larger files (3.36 MB/min
  /// vs 840 KB/min for 105 second recordings).
  static RecordConfig getReliableConfig() {
    return const RecordConfig(
      encoder: AudioEncoder.pcm16bits, // Uncompressed - no encoder buffering
      sampleRate: 16000,
      numChannels: 1,
    );
  }

  /// Get recording config for a specific audio format
  static RecordConfig getConfigForFormat(AudioFormat format) {
    switch (format) {
      case AudioFormat.pcm16bits:
        return const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        );
      case AudioFormat.aacLc:
        return const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 64000,
          numChannels: 1,
        );
    }
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
