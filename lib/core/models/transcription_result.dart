/// Result from audio transcription service
class TranscriptionResult {
  final String rawText;
  final String processedText;
  final int tokenUsage;
  final String? detectedLanguage;

  TranscriptionResult({
    required this.rawText,
    required this.processedText,
    required this.tokenUsage,
    this.detectedLanguage,
  });
}
