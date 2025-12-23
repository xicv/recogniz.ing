import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'audio_processor.dart';
import 'audio_compression_service.dart';
import 'audio_enhancement_service.dart';
import '../config/app_config.dart';
import '../constants/constants.dart';
import '../interfaces/audio_service_interface.dart';

class AudioService implements AudioServiceInterface {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  // Initialize audio processor on first use
  static bool _processorInitialized = false;

  /// Initialize the audio analyzer for background analysis
  static Future<void> _ensureProcessorInitialized() async {
    if (!_processorInitialized) {
      await AudioProcessor.initialize();
      _processorInitialized = true;
    }
  }

  @override
  Future<bool> hasPermission() async {
    final result = await _recorder.hasPermission();
    if (kDebugMode) {
      debugPrint('[AudioService] hasPermission: $result');
    }
    return result;
  }

  @override
  Future<void> startRecording() async {
    if (_isRecording) {
      if (kDebugMode) {
        debugPrint('[AudioService] Already recording, ignoring start');
      }
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (kDebugMode) {
      debugPrint('[AudioService] Permission check: $hasPermission');
    }

    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    // Initialize processor for background analysis
    await _ensureProcessorInitialized();

    final dir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    _currentRecordingPath = '${dir.path}/recording_$uuid.m4a';

    if (kDebugMode) {
      debugPrint('[AudioService] Recording to: $_currentRecordingPath');
    }

    // Start with voice-optimized config
    final config = AudioCompressionService.getVoiceOptimizedConfig();
    await _recorder.start(config, path: _currentRecordingPath!);

    _isRecording = true;
    _recordingStartTime = DateTime.now();

    if (kDebugMode) {
      debugPrint('[AudioService] Recording started at $_recordingStartTime');
    }
  }

  @override
  Future<RecordingResult?> stopRecording() async {
    if (kDebugMode) {
      debugPrint(
          '[AudioService] stopRecording called, isRecording: $_isRecording');
    }

    if (!_isRecording) {
      if (kDebugMode) {
        debugPrint('[AudioService] Not recording, returning null');
      }
      return null;
    }

    final path = await _recorder.stop();
    _isRecording = false;

    if (kDebugMode) {
      debugPrint('[AudioService] Recorder stopped, path: $path');
    }
    if (kDebugMode) {
      debugPrint('[AudioService] Expected path: $_currentRecordingPath');
    }

    if (path == null || _currentRecordingPath == null) {
      if (kDebugMode) {
        debugPrint('[AudioService] No path returned');
      }
      return null;
    }

    final duration = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inMilliseconds /
            AppConstants.millisecondsPerSecond
        : 0.0;

    if (kDebugMode) {
      debugPrint('[AudioService] Recording duration: ${duration}s');
    }

    final file = File(_currentRecordingPath!);
    final exists = await file.exists();
    if (kDebugMode) {
      debugPrint('[AudioService] File exists: $exists');
    }

    if (!exists) {
      if (kDebugMode) {
        debugPrint('[AudioService] Recording file does not exist!');
      }
      return null;
    }

    final fileSize = await file.length();
    if (kDebugMode) {
      debugPrint('[AudioService] File size: $fileSize bytes');
    }

    final bytes = await file.readAsBytes();
    if (kDebugMode) {
      debugPrint('[AudioService] Read ${bytes.length} bytes');
    }

    _currentRecordingPath = null;
    _recordingStartTime = null;

    // Load config for thresholds
    final config = await AppConfig.fromAsset();
    final audioConfig = config.audio;

    // For AAC/M4A compressed audio, enhancement is not needed
    // The enhancement service expects raw PCM format and will fail on compressed data
    final isCompressedFormat = path.endsWith('.m4a') || path.endsWith('.aac');

    // Apply audio enhancement and compression only for uncompressed formats
    Uint8List finalBytes = bytes;
    if (!isCompressedFormat) {
      try {
        // First enhance the audio
        final enhancedBytes = AudioEnhancementService.enhanceVoice(bytes);

        // Then compress it
        final compressedBytes = await AudioCompressionService.compressAudioBytes(
          audioBytes: enhancedBytes,
          sampleRate: audioConfig.sampleRate,
          bitRate: 64000, // 64kbps optimized for voice
        );

        if (compressedBytes != null) {
          finalBytes = compressedBytes;
          final stats = AudioCompressionService.getCompressionStats(
            originalSize: bytes.length,
            compressedSize: compressedBytes.length,
            durationSeconds: duration,
          );

          // Get audio stats
          final audioStats = AudioEnhancementService.getAudioStats(enhancedBytes);
          debugPrint('[AudioEnhancement] RMS: ${audioStats['rms']}, Peak: ${audioStats['peak']}');
          debugPrint('[AudioCompression] ${stats['compressionRatio']} compression, ${stats['savingsPercent']} savings');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AudioService] Enhancement/Compression failed, using original: $e');
        }
        // Continue with original audio if enhancement/compression fails
      }
    } else {
      if (kDebugMode) {
        debugPrint('[AudioService] Using compressed AAC audio directly (enhancement not needed)');
      }
    }

    // Validate recording has minimum duration and content
    if (duration < audioConfig.minDuration) {
      if (kDebugMode) {
        debugPrint(
            '[AudioService] Recording too short: ${duration}s (min: ${audioConfig.minDuration}s)');
      }
      await file.delete();
      return null;
    }

    // Check if audio is likely silent (very small file size)
    if (fileSize < audioConfig.minFileSize) {
      if (kDebugMode) {
        debugPrint(
            '[AudioService] Audio file too small: $fileSize bytes (min: ${audioConfig.minFileSize})');
      }
      await file.delete();
      return null;
    }

    // For compressed formats (AAC/M4A), skip PCM-based analysis
    // The audio is already compressed and we can't analyze raw PCM samples
    AudioAnalysisResult? analysis;
    if (!isCompressedFormat) {
      // Analyze audio to detect speech using background analyzer
      final audioBytes = Uint8List.fromList(finalBytes);
      analysis = await AudioProcessor.analyzeAudio(
        audioBytes: audioBytes,
        amplitudeThreshold: audioConfig.amplitudeThreshold,
        speechRatioThreshold: audioConfig.speechRatioThreshold,
        sampleRate: audioConfig.sampleRate,
        bitDepth: audioConfig.bitDepth,
      );

      // Additional check: if no speech detected, delete the recording
      if (!analysis.containsSpeech) {
        if (kDebugMode) {
          debugPrint(
              '[AudioService] No speech detected, deleting recording: ${analysis.reason}');
        }
        await file.delete();
        return null;
      }

      if (kDebugMode) {
        debugPrint('[AudioService] Recording validation passed');
      }
    } else {
      // For compressed formats, create a basic analysis result
      // We assume the audio is valid if it passed duration and file size checks
      analysis = const AudioAnalysisResult(
        containsSpeech: true,
        reason: 'Compressed AAC format - validation bypassed',
        averageAmplitude: 0.1,
        maxAmplitude: 0.2,
        speechRatio: 0.5,
      );
      if (kDebugMode) {
        debugPrint('[AudioService] Compressed format validation passed (PCM analysis skipped)');
      }
    }

    return RecordingResult(
      path: path,
      bytes: finalBytes,
      durationSeconds: duration,
      analysis: analysis,
    );
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    await _recorder.stop();
    _isRecording = false;

    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _currentRecordingPath = null;
    _recordingStartTime = null;
    if (kDebugMode) {
      debugPrint('[AudioService] Recording cancelled');
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}

class RecordingResult implements RecordingResultInterface {
  final String _path;
  final List<int> _bytes;
  final double _durationSeconds;
  final AudioAnalysisResult? _analysis;

  RecordingResult({
    required String path,
    required List<int> bytes,
    required double durationSeconds,
    AudioAnalysisResult? analysis,
  })  : _path = path,
        _bytes = bytes,
        _durationSeconds = durationSeconds,
        _analysis = analysis;

  bool get containsSpeech => _analysis?.containsSpeech ?? true;

  @override
  String get path => _path;

  @override
  List<int> get bytes => _bytes;

  @override
  double get durationSeconds => _durationSeconds;

  @override
  AudioAnalysisResult? get analysis => _analysis;
}