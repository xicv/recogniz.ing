import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Manages the lifecycle of audio files used for transcription
///
/// Audio files are stored in the application documents directory
/// and automatically cleaned up after successful transcription
/// or after the retention period expires.
class AudioStorageService {
  static const String _audioSubdir = 'transcription_audio';
  static const Duration _failedRetention = Duration(days: 1);

  static Directory? _audioDirectory;
  static bool _initialized = false;

  /// Initialize the audio storage service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      _audioDirectory = Directory('${documentsDir.path}/$_audioSubdir');

      // Create directory if it doesn't exist
      if (!await _audioDirectory!.exists()) {
        await _audioDirectory!.create(recursive: true);
        debugPrint(
            '[AudioStorageService] Created audio directory: $_audioDirectory');
      }

      // Clean up old failed audio files
      await cleanupOldAudio();

      _initialized = true;
      debugPrint('[AudioStorageService] Initialized');
    } catch (e) {
      debugPrint('[AudioStorageService] Initialization error: $e');
      rethrow;
    }
  }

  /// Save audio bytes to persistent storage
  ///
  /// Returns the file path where the audio was saved.
  /// File name format: transcription_{timestamp}_{uuid}.m4a
  static Future<String> saveAudioBytes(List<int> audioBytes,
      {String? transcriptionId}) async {
    await _ensureInitialized();

    final uuid = transcriptionId ?? const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'transcription_${timestamp}_$uuid.m4a';
    final filePath = '${_audioDirectory!.path}/$fileName';
    final file = File(filePath);

    try {
      await file.writeAsBytes(audioBytes);
      debugPrint(
          '[AudioStorageService] Saved audio: $fileName (${audioBytes.length} bytes)');
    } catch (e) {
      debugPrint('[AudioStorageService] Failed to write audio: $e');
      rethrow;
    }

    return filePath;
  }

  /// Get audio bytes from storage
  static Future<Uint8List?> getAudioBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('[AudioStorageService] Audio file not found: $filePath');
        return null;
      }

      final bytes = await file.readAsBytes();
      debugPrint('[AudioStorageService] Loaded audio: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      debugPrint('[AudioStorageService] Error loading audio: $e');
      return null;
    }
  }

  /// Delete audio file from storage
  static Future<void> deleteAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('[AudioStorageService] Deleted audio: $filePath');
      } else {
        debugPrint(
            '[AudioStorageService] File not found for deletion: $filePath');
      }
    } catch (e) {
      debugPrint('[AudioStorageService] Error deleting audio: $e');
    }
  }

  /// Check if audio file exists
  static Future<bool> audioExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the size of an audio file in bytes
  static Future<int?> getAudioFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clean up old audio files older than the retention period
  ///
  /// IMPORTANT: This should only be called from [initialize()] when the
  /// audio directory is already set up. Do NOT call [_ensureInitialized()]
  /// from here as it would create a circular dependency.
  static Future<void> cleanupOldAudio() async {
    try {
      final entities = _audioDirectory!.listSync();
      final now = DateTime.now();
      int deletedCount = 0;
      int totalSize = 0;

      for (final entity in entities) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);

          // Delete files older than retention period
          if (age > _failedRetention) {
            final size = await entity.length();
            totalSize += size;
            await entity.delete();
            deletedCount++;
            debugPrint(
                '[AudioStorageService] Cleaned up old audio: ${entity.path}');
          }
        }
      }

      if (deletedCount > 0) {
        final sizeMb = (totalSize / (1024 * 1024)).toStringAsFixed(2);
        debugPrint(
            '[AudioStorageService] Cleanup complete: $deletedCount files, $sizeMb MB freed');
      } else {
        debugPrint('[AudioStorageService] No old audio files to clean up');
      }
    } catch (e) {
      debugPrint('[AudioStorageService] Error during cleanup: $e');
    }
  }

  /// Get total size of all audio files in storage
  static Future<int> getTotalStorageSize() async {
    await _ensureInitialized();

    try {
      final entities = _audioDirectory!.listSync();
      int totalSize = 0;

      for (final entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get the count of audio files in storage
  static Future<int> getAudioFileCount() async {
    await _ensureInitialized();

    try {
      final entities = _audioDirectory!.listSync();
      return entities.whereType<File>().length;
    } catch (e) {
      return 0;
    }
  }

  /// Ensure the service is initialized
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Get the audio directory path (for debugging)
  static String? get audioDirectoryPath => _audioDirectory?.path;
}
