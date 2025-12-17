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
      final transcriptionResponse =
          await _model!.generateContent([audioContent]);

      final rawText = transcriptionResponse.text ?? '';
      print('[GeminiService] Raw transcription: $rawText');

      if (rawText.isEmpty) {
        print('[GeminiService] Warning: Empty transcription received');
        throw Exception('Empty transcription received from API');
      }

      // Then, process with the custom prompt
      final processedPrompt = promptTemplate.replaceAll('{{text}}', rawText);
      print('[GeminiService] Processing with custom prompt...');

      final processedResponse = await _model!.generateContent([
        Content.text(processedPrompt),
      ]);

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
