import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class AudioCompressionService {
  static const String _compressedAudioDir = 'compressed_audio';
  static const int _targetSampleRate = 16000; // 16kHz for voice
  static const int _targetBitRate = 64000; // 64kbps for voice
  static const int _channels = 1; // Mono for voice

  /// Initialize compression service
  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final compressedDir = Directory('${directory.path}/$_compressedAudioDir');

    if (!await compressedDir.exists()) {
      await compressedDir.create(recursive: true);
    }

    // Clean old compressed files (older than 1 day)
    await _cleanOldFiles(compressedDir);
  }

  /// Compress audio file for API transmission
  /// Returns the path to the compressed file
  static Future<String?> compressAudio({
    required String inputPath,
    String? outputPath,
    int? sampleRate,
    int? bitRate,
    bool deleteOriginal = false,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final defaultOutputPath = '${directory.path}/$_compressedAudioDir/compressed_$timestamp.aac';
      final finalOutputPath = outputPath ?? defaultOutputPath;

      // Build FFmpeg command for compression
      final command = [
        '-i', inputPath,
        '-ar', (sampleRate ?? _targetSampleRate).toString(),
        '-ac', _channels.toString(),
        '-b:a', '${bitRate ?? _targetBitRate}',
        '-c:a', 'aac',
        '-movflags', '+faststart', // For streaming
        '-y', // Overwrite output
        finalOutputPath,
      ];

      if (kDebugMode) {
        print('Audio compression command: ffmpeg ${command.join(' ')}');
      }

      // Execute compression
      final session = await FFmpegKit.execute(command.join(' '));
      final returnCode = await session.getReturnCode();

      if (returnCode?.getValue() == 0) {
        // Get file sizes for comparison
        final inputFile = File(inputPath);
        final outputFile = File(finalOutputPath);
        final originalSize = await inputFile.length();
        final compressedSize = await outputFile.length();

        final compressionRatio = ((originalSize - compressedSize) / originalSize * 100).round();

        if (kDebugMode) {
          print('Audio compressed successfully:');
          print('  Original: ${(originalSize / 1024).round()} KB');
          print('  Compressed: ${(compressedSize / 1024).round()} KB');
          print('  Reduction: $compressionRatio%');
        }

        // Delete original if requested
        if (deleteOriginal) {
          await inputFile.delete();
        }

        return finalOutputPath;
      } else {
        final logs = await session.getLogs();
        final errorMessage = logs.map((log) => log.getMessage()).join('\n');
        if (kDebugMode) {
          print('Audio compression failed: $errorMessage');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing audio: $e');
      }
      return null;
    }
  }

  /// Compress audio bytes directly
  /// Returns compressed bytes
  static Future<Uint8List?> compressAudioBytes({
    required Uint8List audioBytes,
    String format = 'm4a',
    int? sampleRate,
    int? bitRate,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final inputPath = '${directory.path}/$_compressedAudioDir/temp_input_$timestamp.$format';
      final outputPath = '${directory.path}/$_compressedAudioDir/temp_output_$timestamp.aac';

      // Write input bytes to file
      final inputFile = File(inputPath);
      await inputFile.writeAsBytes(audioBytes);

      // Compress the file
      final compressedPath = await compressAudio(
        inputPath: inputPath,
        outputPath: outputPath,
        sampleRate: sampleRate,
        bitRate: bitRate,
        deleteOriginal: true,
      );

      if (compressedPath != null) {
        // Read compressed bytes
        final outputFile = File(compressedPath);
        final compressedBytes = await outputFile.readAsBytes();

        // Clean up
        await outputFile.delete();

        return compressedBytes;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing audio bytes: $e');
      }
      return null;
    }
  }

  /// Get optimal compression settings based on audio length
  static AudioCompressionSettings getOptimalSettings(Duration duration) {
    // For very short recordings, use higher quality
    if (duration.inSeconds < 10) {
      return AudioCompressionSettings(
        sampleRate: 16000,
        bitRate: 96000, // 96kbps
        format: 'aac',
      );
    }

    // For medium recordings
    if (duration.inMinutes < 5) {
      return AudioCompressionSettings(
        sampleRate: 16000,
        bitRate: 64000, // 64kbps
        format: 'aac',
      );
    }

    // For long recordings, use more aggressive compression
    return AudioCompressionSettings(
      sampleRate: 16000,
      bitRate: 48000, // 48kbps
      format: 'aac',
    );
  }

  /// Clean up old compressed files
  static Future<void> _cleanOldFiles(Directory directory) async {
    try {
      final files = await directory.list().toList();
      final now = DateTime.now();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          // Delete files older than 24 hours
          if (age.inHours > 24) {
            await file.delete();
            if (kDebugMode) {
              print('Deleted old compressed file: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning old files: $e');
      }
    }
  }

  /// Check if FFmpeg is available
  static Future<bool> isFFmpegAvailable() async {
    try {
      final session = await FFmpegKit.execute('-version');
      final returnCode = await session.getReturnCode();
      return returnCode?.getValue() == 0;
    } catch (e) {
      return false;
    }
  }

  /// Batch compress multiple audio files
  static Future<List<String>> batchCompress({
    required List<String> inputPaths,
    bool deleteOriginals = false,
  }) async {
    final results = <String>[];

    for (final inputPath in inputPaths) {
      final compressedPath = await compressAudio(
        inputPath: inputPath,
        deleteOriginal: deleteOriginals,
      );

      if (compressedPath != null) {
        results.add(compressedPath);
      }
    }

    return results;
  }
}

/// Audio compression settings
class AudioCompressionSettings {
  final int sampleRate;
  final int bitRate;
  final String format;
  final int channels;

  const AudioCompressionSettings({
    required this.sampleRate,
    required this.bitRate,
    required this.format,
    this.channels = 1,
  });
}