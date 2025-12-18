import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'audio_analyzer.dart';
import '../config/app_config.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    final result = await _recorder.hasPermission();
    debugPrint('[AudioService] hasPermission: $result');
    return result;
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      debugPrint('[AudioService] Already recording, ignoring start');
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    debugPrint('[AudioService] Permission check: $hasPermission');

    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final dir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    _currentRecordingPath = '${dir.path}/recording_$uuid.m4a';

    debugPrint('[AudioService] Recording to: $_currentRecordingPath');

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );

    _isRecording = true;
    _recordingStartTime = DateTime.now();
    debugPrint('[AudioService] Recording started at $_recordingStartTime');
  }

  Future<RecordingResult?> stopRecording() async {
    debugPrint('[AudioService] stopRecording called, isRecording: $_isRecording');

    if (!_isRecording) {
      debugPrint('[AudioService] Not recording, returning null');
      return null;
    }

    final path = await _recorder.stop();
    _isRecording = false;

    debugPrint('[AudioService] Recorder stopped, path: $path');
    debugPrint('[AudioService] Expected path: $_currentRecordingPath');

    if (path == null || _currentRecordingPath == null) {
      debugPrint('[AudioService] No path returned');
      return null;
    }

    final duration = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inMilliseconds /
            1000.0
        : 0.0;

    debugPrint('[AudioService] Recording duration: ${duration}s');

    final file = File(_currentRecordingPath!);
    final exists = await file.exists();
    debugPrint('[AudioService] File exists: $exists');

    if (!exists) {
      debugPrint('[AudioService] Recording file does not exist!');
      return null;
    }

    final fileSize = await file.length();
    debugPrint('[AudioService] File size: $fileSize bytes');

    final bytes = await file.readAsBytes();
    debugPrint('[AudioService] Read ${bytes.length} bytes');

    _currentRecordingPath = null;
    _recordingStartTime = null;

    // Load config for thresholds
    final config = await AppConfig.fromAsset();
    final audioConfig = config.audio;

    // Validate recording has minimum duration and content
    if (duration < audioConfig.minDuration) {
      debugPrint('[AudioService] Recording too short: ${duration}s (min: ${audioConfig.minDuration}s)');
      await file.delete();
      return null;
    }

    // Check if audio is likely silent (very small file size)
    if (fileSize < audioConfig.minFileSize) {
      debugPrint('[AudioService] Audio file too small: $fileSize bytes (min: ${audioConfig.minFileSize})');
      await file.delete();
      return null;
    }

    // Analyze audio to detect speech
    final audioBytes = Uint8List.fromList(bytes);
    final analysis = AudioAnalyzer.analyzeAudioBytes(
      audioBytes,
      amplitudeThreshold: audioConfig.amplitudeThreshold,
      speechRatioThreshold: audioConfig.speechRatioThreshold,
      sampleRate: audioConfig.sampleRate,
      bitDepth: audioConfig.bitDepth,
    );

    // Additional check: if no speech detected, delete the recording
    if (!analysis.containsSpeech) {
      debugPrint('[AudioService] No speech detected, deleting recording: ${analysis.reason}');
      await file.delete();
      return null;
    }

    debugPrint('[AudioService] Recording validation passed');

    return RecordingResult(
      path: path,
      bytes: bytes,
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
    debugPrint('[AudioService] Recording cancelled');
  }

  void dispose() {
    _recorder.dispose();
  }
}

class RecordingResult {
  final String path;
  final List<int> bytes;
  final double durationSeconds;
  final AudioAnalysisResult? analysis;

  RecordingResult({
    required this.path,
    required this.bytes,
    required this.durationSeconds,
    this.analysis,
  });

  bool get containsSpeech => analysis?.containsSpeech ?? true;
}
