import 'dart:math';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  String? _apiKey;

  // Gemini 2.5 Flash
  static const String _modelName = 'gemini-2.5-flash';

  bool get isInitialized => _model != null;

  void initialize(String apiKey) {
    print('[GeminiService] Initializing with model: $_modelName');
    _apiKey = apiKey;
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
    );
    print('[GeminiService] Initialized successfully');
  }

  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
  }) async {
    print('[GeminiService] transcribeAudio called');
    print('[GeminiService] Audio bytes: ${audioBytes.length}');
    print('[GeminiService] Vocabulary: $vocabulary');

    if (_model == null) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    // First, transcribe the audio
    final transcriptionPrompt = '''
Transcribe the following audio accurately.
Use this vocabulary for proper nouns and technical terms: $vocabulary
Output only the transcription, nothing else.
''';

    print('[GeminiService] Sending audio to Gemini for transcription...');

    try {
      // Create content with audio - try different MIME types
      final audioContent = Content.multi([
        TextPart(transcriptionPrompt),
        DataPart('audio/mp4', audioBytes), // m4a is mp4 audio
      ]);

      print('[GeminiService] Calling generateContent for transcription...');
      final transcriptionResponse = await _executeWithRetry(
        () => _model!.generateContent([audioContent]),
        operationName: 'transcription',
      );

      final rawText = transcriptionResponse.text ?? '';
      print('[GeminiService] Raw transcription: $rawText');

      if (rawText.isEmpty) {
        print('[GeminiService] Warning: Empty transcription received');
        throw Exception('Empty transcription received from API');
      }

      // Then, process with the custom prompt
      final processedPrompt = promptTemplate.replaceAll('{{text}}', rawText);
      print('[GeminiService] Processing with custom prompt...');

      final processedResponse = await _executeWithRetry(
        () => _model!.generateContent([Content.text(processedPrompt)]),
        operationName: 'processing',
      );

      final processedText = processedResponse.text ?? rawText;
      print('[GeminiService] Processed text: $processedText');

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
      print('[GeminiService] Error during transcription: $e');
      print('[GeminiService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<(bool isValid, String? error)> validateApiKey(String apiKey) async {
    print('[GeminiService] Validating API key...');
    try {
      final testModel = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
      );

      final response = await testModel.generateContent([
        Content.text('Say "OK"'),
      ]);

      print('[GeminiService] Validation response: ${response.text}');

      if (response.text != null && response.text!.isNotEmpty) {
        print('[GeminiService] API key is valid');
        return (true, null);
      }
      return (false, 'No response from API');
    } catch (e) {
      print('[GeminiService] Validation error: $e');
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
        print('[GeminiService] $operationName failed (attempt $attempt/$maxRetries): $e');

        final errorStr = e.toString().toLowerCase();

        // Don't retry on certain errors
        if (errorStr.contains('invalid_argument') ||
            errorStr.contains('permission_denied') ||
            errorStr.contains('not_found') ||
            errorStr.contains('api_key_invalid')) {
          print('[GeminiService] Non-retryable error, failing immediately');
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
            print('[GeminiService] Max retries exceeded for $operationName');
            rethrow;
          }

          // Exponential backoff with jitter
          final jitter = Random().nextDouble() * 0.5;
          final waitTime = Duration(
            milliseconds: (delay.inMilliseconds * (1 + jitter)).round(),
          );

          print('[GeminiService] Retrying $operationName in ${waitTime.inSeconds}s...');
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
    _apiKey = null;
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
