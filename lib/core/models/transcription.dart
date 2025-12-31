import 'package:hive/hive.dart';

import 'transcription_status.dart';

part 'transcription.g.dart';

@HiveType(typeId: 0)
class Transcription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String rawText;

  @HiveField(2)
  final String processedText;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int tokenUsage;

  @HiveField(5)
  final String promptId;

  @HiveField(6)
  final double audioDurationSeconds;

  @HiveField(7)
  final bool? isFavorite;

  @HiveField(8)
  final String? audioBackupPath;

  @HiveField(9, defaultValue: 2) // Default to 'completed' for existing records
  final int statusIndex;

  @HiveField(10)
  final String? errorMessage;

  @HiveField(11, defaultValue: 0) // Default to 0 retries for existing records
  final int retryCount;

  @HiveField(12)
  final DateTime? completedAt;

  Transcription({
    required this.id,
    required this.rawText,
    required this.processedText,
    required this.createdAt,
    required this.tokenUsage,
    required this.promptId,
    required this.audioDurationSeconds,
    bool? isFavorite,
    this.audioBackupPath,
    TranscriptionStatus status = TranscriptionStatus.completed,
    this.errorMessage,
    this.retryCount = 0,
    this.completedAt,
  })  : isFavorite = isFavorite ?? false,
        statusIndex = status.index;

  /// Get the transcription status
  TranscriptionStatus get status => intToStatus(statusIndex);

  /// Whether this transcription has a backup audio file for retry
  bool get hasAudioBackup =>
      audioBackupPath != null && audioBackupPath!.isNotEmpty;

  /// Whether this transcription can be retried
  bool get canRetry => hasAudioBackup && status.canRetry;

  /// Whether the transcription processing is complete (success or failed)
  bool get isTerminal => status.isTerminal;

  Transcription copyWith({
    String? id,
    String? rawText,
    String? processedText,
    DateTime? createdAt,
    int? tokenUsage,
    String? promptId,
    double? audioDurationSeconds,
    bool? isFavorite,
    String? audioBackupPath,
    TranscriptionStatus? status,
    String? errorMessage,
    int? retryCount,
    DateTime? completedAt,
  }) {
    return Transcription(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      processedText: processedText ?? this.processedText,
      createdAt: createdAt ?? this.createdAt,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      promptId: promptId ?? this.promptId,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      isFavorite: isFavorite ?? this.isFavorite ?? false,
      audioBackupPath: audioBackupPath ?? this.audioBackupPath,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Create a pending transcription (before API call)
  static Transcription pending({
    required String id,
    required double audioDurationSeconds,
    required String audioBackupPath,
    required String promptId,
  }) {
    return Transcription(
      id: id,
      rawText: '',
      processedText: '',
      createdAt: DateTime.now(),
      tokenUsage: 0,
      promptId: promptId,
      audioDurationSeconds: audioDurationSeconds,
      audioBackupPath: audioBackupPath,
      status: TranscriptionStatus.pending,
    );
  }

  /// Create a failed transcription (after API error)
  Transcription asFailed(String error) {
    return copyWith(
      status: TranscriptionStatus.failed,
      errorMessage: error,
    );
  }

  /// Create a completed transcription (after API success)
  Transcription asCompleted({
    required String rawText,
    required String processedText,
    required int tokenUsage,
    bool clearAudioBackup = true,
  }) {
    return copyWith(
      rawText: rawText,
      processedText: processedText,
      tokenUsage: tokenUsage,
      status: TranscriptionStatus.completed,
      completedAt: DateTime.now(),
      audioBackupPath: clearAudioBackup ? null : audioBackupPath,
    );
  }

  /// Increment retry count for retry attempt
  Transcription incrementRetry() {
    return copyWith(
      retryCount: retryCount + 1,
      status: TranscriptionStatus.pending,
      errorMessage: null,
    );
  }
}
