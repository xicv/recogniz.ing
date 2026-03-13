/// Result from audio transcription service
class TranscriptionResult {
  final String rawText;
  final String processedText;
  final int tokenUsage;
  final String? detectedLanguage;
  final bool isTruncated;

  TranscriptionResult({
    required this.rawText,
    required this.processedText,
    required this.tokenUsage,
    this.detectedLanguage,
    this.isTruncated = false,
  });
}
