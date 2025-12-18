import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;

  static const String _modelName = 'gemini-3-flash-preview';

  bool get isInitialized => _model != null;

  void initialize(String apiKey) {
    debugPrint('[GeminiService] Initializing with model: $_modelName');
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
    );
    debugPrint('[GeminiService] Initialized successfully');
  }

  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
  }) async {
    debugPrint('[GeminiService] transcribeAudio called');
    debugPrint('[GeminiService] Audio bytes: ${audioBytes.length}');
    debugPrint('[GeminiService] Vocabulary: $vocabulary');

    if (_model == null) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    // First, transcribe the audio
    String transcriptionPrompt = '''
Transcribe the following audio accurately.

${criticalInstructions ?? '''CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary below is for reference ONLY - do not use it to generate fake transcriptions'''}
''';

    // Only include vocabulary if it's not empty
    if (vocabulary.isNotEmpty) {
      transcriptionPrompt += '''
Reference vocabulary for technical terms (use ONLY if you actually hear these words spoken):
$vocabulary

Remember: Only transcribe what is actually spoken in the audio. If there is no speech, respond with [NO_SPEECH].
Output only the transcription, nothing else.''';
    } else {
      transcriptionPrompt += '''
Output only the transcription, nothing else.''';
    }

    debugPrint('[GeminiService] Sending audio to Gemini for transcription...');

    try {
      // Create content with audio - try different MIME types
      final audioContent = Content.multi([
        TextPart(transcriptionPrompt),
        DataPart('audio/mp4', audioBytes), // m4a is mp4 audio
      ]);

      debugPrint('[GeminiService] Calling generateContent for transcription...');
      final transcriptionResponse = await _executeWithRetry(
        () => _model!.generateContent([audioContent]),
        operationName: 'transcription',
      );

      final rawText = transcriptionResponse.text ?? '';
      debugPrint('[GeminiService] Raw transcription: $rawText');

      if (rawText.isEmpty) {
        debugPrint('[GeminiService] Warning: Empty transcription received');
        throw Exception('Empty transcription received from API');
      }

      // Check if no speech was detected
      if (rawText.trim() == '[NO_SPEECH]') {
        debugPrint('[GeminiService] No speech detected in audio');
        throw Exception('No speech detected in audio');
      }

      // Then, process with the custom prompt
      final processedPrompt = promptTemplate.replaceAll('{{text}}', rawText);
      debugPrint('[GeminiService] Processing with custom prompt...');

      final processedResponse = await _executeWithRetry(
        () => _model!.generateContent([Content.text(processedPrompt)]),
        operationName: 'processing',
      );

      final processedText = processedResponse.text ?? rawText;
      debugPrint('[GeminiService] Processed text: $processedText');

      // Estimate token usage
      final estimatedTokens =
          ((rawText.length + processedPrompt.length + processedText.length) / 4)
              .round();

      return TranscriptionResult(
        rawText: rawText,
        processedText: processedText,
        tokenUsage: estimatedTokens,
      );
    } catch (e, stackTrace) {
      debugPrint('[GeminiService] Error during transcription: $e');
      debugPrint('[GeminiService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<(bool isValid, String? error)> validateApiKey(String apiKey) async {
    debugPrint('[GeminiService] Validating API key...');
    try {
      final testModel = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
      );

      final response = await testModel.generateContent([
        Content.text('Say "OK"'),
      ]);

      debugPrint('[GeminiService] Validation response: ${response.text}');

      if (response.text != null && response.text!.isNotEmpty) {
        debugPrint('[GeminiService] API key is valid');
        return (true, null);
      }
      return (false, 'No response from API');
    } catch (e) {
      debugPrint('[GeminiService] Validation error: $e');
      final errorStr = e.toString();

      if (errorStr.contains('403') ||
          errorStr.contains('API_KEY_INVALID') ||
          errorStr.contains('invalid')) {
        return (false, 'Invalid API Key');
      }
      if (errorStr.contains('404') || errorStr.contains('not found')) {
        return (false, 'Model not found');
      }
      if (errorStr.contains('429')) {
        return (false, 'Rate limited');
      }

      return (
        false,
        errorStr.length > 100 ? errorStr.substring(0, 100) : errorStr
      );
    }
  }

  // Execute operation with exponential backoff retry
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    String operationName = 'API call',
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        debugPrint(
            '[GeminiService] $operationName failed (attempt $attempt/$maxRetries): $e');

        final errorStr = e.toString().toLowerCase();

        // Don't retry on certain errors
        if (errorStr.contains('invalid_argument') ||
            errorStr.contains('permission_denied') ||
            errorStr.contains('not_found') ||
            errorStr.contains('api_key_invalid')) {
          debugPrint('[GeminiService] Non-retryable error, failing immediately');
          rethrow;
        }

        // Retry on 503, 429, and other transient errors
        if (errorStr.contains('503') ||
            errorStr.contains('unavailable') ||
            errorStr.contains('429') ||
            errorStr.contains('resource_exhausted') ||
            errorStr.contains('deadline_exceeded') ||
            errorStr.contains('internal')) {
          if (attempt >= maxRetries) {
            debugPrint('[GeminiService] Max retries exceeded for $operationName');
            rethrow;
          }

          // Exponential backoff with jitter
          final jitter = Random().nextDouble() * 0.5;
          final waitTime = Duration(
            milliseconds: (delay.inMilliseconds * (1 + jitter)).round(),
          );

          debugPrint(
              '[GeminiService] Retrying $operationName in ${waitTime.inSeconds}s...');
          await Future.delayed(waitTime);

          delay *= 2;
        } else {
          // Unknown error, don't retry
          rethrow;
        }
      }
    }

    throw Exception('$operationName failed after $maxRetries attempts');
  }

  void dispose() {
    _model = null;
  }
}

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
