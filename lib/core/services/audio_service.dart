import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    final result = await _recorder.hasPermission();
    print('[AudioService] hasPermission: $result');
    return result;
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      print('[AudioService] Already recording, ignoring start');
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    print('[AudioService] Permission check: $hasPermission');

    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final dir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    _currentRecordingPath = '${dir.path}/recording_$uuid.m4a';

    print('[AudioService] Recording to: $_currentRecordingPath');

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
    print('[AudioService] Recording started at $_recordingStartTime');
  }

  Future<RecordingResult?> stopRecording() async {
    print('[AudioService] stopRecording called, isRecording: $_isRecording');

    if (!_isRecording) {
      print('[AudioService] Not recording, returning null');
      return null;
    }

    final path = await _recorder.stop();
    _isRecording = false;

    print('[AudioService] Recorder stopped, path: $path');
    print('[AudioService] Expected path: $_currentRecordingPath');

    if (path == null || _currentRecordingPath == null) {
      print('[AudioService] No path returned');
      return null;
    }

    final duration = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inMilliseconds /
            1000.0
        : 0.0;

    print('[AudioService] Recording duration: ${duration}s');

    final file = File(_currentRecordingPath!);
    final exists = await file.exists();
    print('[AudioService] File exists: $exists');

    if (!exists) {
      print('[AudioService] Recording file does not exist!');
      return null;
    }

    final fileSize = await file.length();
    print('[AudioService] File size: $fileSize bytes');

    final bytes = await file.readAsBytes();
    print('[AudioService] Read ${bytes.length} bytes');

    _currentRecordingPath = null;
    _recordingStartTime = null;

    // Validate recording has minimum duration and content
    if (duration < 0.5) {
      print('[AudioService] Recording too short: ${duration}s');
      await file.delete();
      return null;
    }

    // Check if audio is likely silent (very small file size)
    const minFileSize = 1000; // 1KB minimum for valid audio
    if (fileSize < minFileSize) {
      print('[AudioService] Audio file too small: $fileSize bytes (likely silent)');
      await file.delete();
      return null;
    }

    print('[AudioService] Recording validation passed');

    return RecordingResult(
      path: path,
      bytes: bytes,
      durationSeconds: duration,
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
    print('[AudioService] Recording cancelled');
  }

  void dispose() {
    _recorder.dispose();
  }
}

class RecordingResult {
  final String path;
  final List<int> bytes;
  final double durationSeconds;

  RecordingResult({
    required this.path,
    required this.bytes,
    required this.durationSeconds,
  });
}
