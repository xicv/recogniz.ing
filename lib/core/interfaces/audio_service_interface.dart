import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/transcription.dart';
import '../models/transcription_result.dart';
import '../models/app_settings.dart';
import '../models/custom_prompt.dart';
import '../models/vocabulary.dart';

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
  Future<List<Transcription>> getTranscriptions({int? limit, int? offset});
  Future<void> deleteTranscription(String id);
  Future<void> updateTranscription(String id, String newText);
  Future<AppSettings> getSettings();
  Future<CustomPrompt?> getPrompt(String id);
  Future<VocabularySet?> getVocabulary(String id);
}

abstract class NotificationServiceInterface {
  void showError(String message);
  void showSuccess(String message);
  void clearError();
  void setContentNavigatorKey(GlobalKey<NavigatorState> contentNavigatorKey);
  void setScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey);
}
