import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Diagnostic result containing all duration measurements
class DiagnosticResult {
  final double timerDurationSeconds;
  final double? fileDurationSeconds;
  final int fileSizeBytes;
  final int bitrate;
  final double expectedDurationSeconds;
  final double? missingSeconds;
  final double? lossPercentage;
  final bool hasTruncation;
  final String assessment;

  const DiagnosticResult({
    required this.timerDurationSeconds,
    required this.fileDurationSeconds,
    required this.fileSizeBytes,
    required this.bitrate,
    required this.expectedDurationSeconds,
    required this.missingSeconds,
    required this.lossPercentage,
    required this.hasTruncation,
    required this.assessment,
  });

  @override
  String toString() {
    return '''
AudioDiagnosticResult:
  Timer Duration: ${timerDurationSeconds.toStringAsFixed(2)}s
  File Duration: ${fileDurationSeconds?.toStringAsFixed(2)}s ?? "N/A"}
  Expected (size): ${expectedDurationSeconds.toStringAsFixed(2)}s
  Missing: ${missingSeconds?.toStringAsFixed(2)}s ?? "N/A"}
  Loss: ${lossPercentage?.toStringAsFixed(1)}% ?? "N/A"}
  Has Truncation: $hasTruncation
  Assessment: $assessment
''';
  }

  Map<String, dynamic> toJson() {
    return {
      'timerDurationSeconds': timerDurationSeconds,
      'fileDurationSeconds': fileDurationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'bitrate': bitrate,
      'expectedDurationSeconds': expectedDurationSeconds,
      'missingSeconds': missingSeconds,
      'lossPercentage': lossPercentage,
      'hasTruncation': hasTruncation,
      'assessment': assessment,
    };
  }
}

/// Audio diagnostic service for detecting recording issues
///
/// This service helps identify problems with audio recording by comparing:
/// - Timer duration (time between start/stop calls)
/// - Actual file duration (from audio file metadata)
/// - Expected duration (based on file size and bitrate)
class AudioDiagnosticService {
  static final AudioPlayer _player = AudioPlayer();

  /// Diagnose an audio recording to detect truncation issues
  ///
  /// Compares the timer duration (time between start/stop calls) with the
  /// actual audio file duration to detect if audio was lost during recording.
  ///
  /// Parameters:
  /// - [filePath]: Path to the audio file
  /// - [timerDurationSeconds]: Time between start() and stop() calls
  /// - [bitrate]: Recording bitrate in bps (e.g., 64000 for 64kbps)
  static Future<DiagnosticResult> diagnose({
    required String filePath,
    required double timerDurationSeconds,
    required int bitrate,
  }) async {
    final file = File(filePath);
    final fileSize = await file.length();

    // Calculate expected duration based on file size and bitrate
    // Expected duration = (file size in bytes * 8) / bitrate
    final expectedDurationSeconds = (fileSize * 8) / bitrate;

    // Get actual file duration using just_audio
    double? fileDurationSeconds;
    try {
      // Set the audio source to get duration
      final duration = await _player.setFilePath(filePath);
      if (duration != null) {
        fileDurationSeconds = duration.inMicroseconds / 1000000;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AudioDiagnostic] Could not get file duration: $e');
      }
    }

    // Calculate missing audio
    double? missingSeconds;
    double? lossPercentage;
    bool hasTruncation = false;

    // Prefer file duration if available, otherwise use expected duration
    final actualDuration = fileDurationSeconds ?? expectedDurationSeconds;

    if (actualDuration < timerDurationSeconds) {
      missingSeconds = timerDurationSeconds - actualDuration;
      lossPercentage = (missingSeconds / timerDurationSeconds) * 100;
      hasTruncation =
          lossPercentage > 5.0; // More than 5% loss is considered truncation
    }

    // Generate assessment
    String assessment;
    if (lossPercentage == null) {
      assessment = 'Unable to determine (file duration not available)';
    } else if (lossPercentage < 5) {
      assessment =
          'Normal - minimal loss (${lossPercentage.toStringAsFixed(1)}%)';
    } else if (lossPercentage < 15) {
      assessment =
          'WARNING - Moderate truncation detected (${lossPercentage.toStringAsFixed(1)}% loss)';
    } else {
      assessment =
          'CRITICAL - Severe truncation detected (${lossPercentage.toStringAsFixed(1)}% loss)';
    }

    final result = DiagnosticResult(
      timerDurationSeconds: timerDurationSeconds,
      fileDurationSeconds: fileDurationSeconds,
      fileSizeBytes: fileSize,
      bitrate: bitrate,
      expectedDurationSeconds: expectedDurationSeconds,
      missingSeconds: missingSeconds,
      lossPercentage: lossPercentage,
      hasTruncation: hasTruncation,
      assessment: assessment,
    );

    // Log the result
    if (kDebugMode) {
      debugPrint('[AudioDiagnostic] ${result.toString()}');
    }

    return result;
  }

  /// Quick check using only file size (no audio decoding required)
  ///
  /// This is faster but less accurate than the full diagnose method.
  /// Use this for real-time checks during recording.
  static DiagnosticResult quickCheck({
    required int fileSizeBytes,
    required double timerDurationSeconds,
    required int bitrate,
  }) {
    // Calculate expected duration based on file size and bitrate
    final expectedDurationSeconds = (fileSizeBytes * 8) / bitrate;

    final missingSeconds = timerDurationSeconds - expectedDurationSeconds;
    final lossPercentage = (missingSeconds / timerDurationSeconds) * 100;
    final hasTruncation = lossPercentage > 5.0;

    String assessment;
    if (lossPercentage < 5) {
      assessment =
          'Normal - minimal loss (${lossPercentage.toStringAsFixed(1)}%)';
    } else if (lossPercentage < 15) {
      assessment =
          'WARNING - Moderate truncation (${lossPercentage.toStringAsFixed(1)}% loss)';
    } else {
      assessment =
          'CRITICAL - Severe truncation (${lossPercentage.toStringAsFixed(1)}% loss)';
    }

    final result = DiagnosticResult(
      timerDurationSeconds: timerDurationSeconds,
      fileDurationSeconds: null,
      fileSizeBytes: fileSizeBytes,
      bitrate: bitrate,
      expectedDurationSeconds: expectedDurationSeconds,
      missingSeconds: missingSeconds,
      lossPercentage: lossPercentage,
      hasTruncation: hasTruncation,
      assessment: assessment,
    );

    if (kDebugMode) {
      debugPrint('[AudioDiagnostic] Quick check: ${result.toString()}');
    }

    return result;
  }

  /// Dispose resources
  static void dispose() {
    _player.dispose();
  }
}
