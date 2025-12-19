import 'dart:typed_data';
import '../models/transcription.dart';
import '../models/transcription_result.dart';
import '../models/app_settings.dart';

// Audio analysis result
class AudioAnalysis {
  final bool containsSpeech;
  final String reason;

  const AudioAnalysis({
    required this.containsSpeech,
    required this.reason,
  });
}

// Recording result interface
abstract class RecordingResultInterface {
  String get path;
  List<int> get bytes;
  double get durationSeconds;
  AudioAnalysis? get analysis;
}

abstract class AudioServiceInterface {
  Future<bool> hasPermission();
  Future<void> startRecording();
  Future<RecordingResultInterface?> stopRecording();
}

abstract class TranscriptionServiceInterface {
  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
  });
}

abstract class StorageServiceInterface {
  Future<void> saveTranscription(Transcription transcription);
  Future<List<Transcription>> getTranscriptions();
  Future<void> deleteTranscription(String id);
  Future<void> updateTranscription(String id, String newText);
  AppSettings getSettings();
}

abstract class NotificationServiceInterface {
  void showError(String message);
  void showSuccess(String message);
  void clearError();
}
