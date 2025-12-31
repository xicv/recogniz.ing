/// Status of a transcription in its lifecycle
enum TranscriptionStatus {
  /// Audio recorded, queued for API processing
  pending,

  /// API call currently in progress
  processing,

  /// Transcription completed successfully
  completed,

  /// API call failed, can be retried
  failed,
}

/// Extension for TranscriptionStatus utilities
extension TranscriptionStatusExtension on TranscriptionStatus {
  /// String value for storage/display
  String get value {
    switch (this) {
      case TranscriptionStatus.pending:
        return 'pending';
      case TranscriptionStatus.processing:
        return 'processing';
      case TranscriptionStatus.completed:
        return 'completed';
      case TranscriptionStatus.failed:
        return 'failed';
    }
  }

  /// Display label for UI
  String get label {
    switch (this) {
      case TranscriptionStatus.pending:
        return 'Pending';
      case TranscriptionStatus.processing:
        return 'Processing';
      case TranscriptionStatus.completed:
        return 'Completed';
      case TranscriptionStatus.failed:
        return 'Failed';
    }
  }

  /// Whether the transcription can be retried
  bool get canRetry => this == TranscriptionStatus.failed;

  /// Whether the transcription is in a terminal state
  bool get isTerminal =>
      this == TranscriptionStatus.completed ||
      this == TranscriptionStatus.failed;

  /// Convert from integer index (for Hive storage)
  static TranscriptionStatus fromIndex(int index) {
    return TranscriptionStatus.values[index];
  }
}

/// Convert status to integer for Hive storage
int statusToInt(TranscriptionStatus status) => status.index;

/// Convert integer from Hive to status
TranscriptionStatus intToStatus(int value) =>
    TranscriptionStatusExtension.fromIndex(value);
