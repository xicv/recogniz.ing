/// Result from audio transcription service
class TranscriptionResult {
  final String rawText;
  final String processedText;
  final int tokenUsage;

  TranscriptionResult({
    required this.rawText,
    required this.processedText,
    required this.tokenUsage,
  });
}