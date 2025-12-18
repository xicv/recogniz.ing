import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/transcription_result.dart';

/// Optimized Gemini service with performance improvements
class OptimizedGeminiService {
  GenerativeModel? _model;
  GenerativeModel? _lightningModel; // For fast responses

  static const String _modelName = 'gemini-3-flash-preview';
  static const String _lightningModelName = 'gemini-3-flash-preview';

  bool get isInitialized => _model != null;

  void initialize(String apiKey) {
    debugPrint('[OptimizedGeminiService] Initializing with models...');
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
    );

    // Initialize a faster model for simple tasks
    _lightningModel = GenerativeModel(
      model: _lightningModelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1, // Lower for more consistent responses
        maxOutputTokens: 1024, // Limit output for speed
        topP: 0.8,
        topK: 40,
      ),
    );

    debugPrint('[OptimizedGeminiService] Models initialized successfully');
  }

  /// Transcribe audio with optional direct transcription mode for speed
  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
    bool enableDirectMode = true,
  }) async {
    debugPrint('[OptimizedGeminiService] Starting optimized transcription...');
    debugPrint('Audio bytes: ${audioBytes.length}');
    debugPrint('Vocabulary: $vocabulary');
    debugPrint('Direct mode: $enableDirectMode');

    if (_model == null) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    // Check if we can use direct mode (no post-processing needed)
    final promptId = _extractPromptId(promptTemplate);
    final shouldProcess = _shouldProcessTranscription(promptId);

    if (!shouldProcess || enableDirectMode) {
      return _directTranscription(audioBytes, vocabulary, criticalInstructions);
    }

    // Use combined prompt approach for better performance
    return _combinedTranscription(audioBytes, vocabulary, promptTemplate, criticalInstructions);
  }

  /// Direct transcription without post-processing for maximum speed
  Future<TranscriptionResult> _directTranscription(
    Uint8List audioBytes,
    String vocabulary,
    String? criticalInstructions,
  ) async {
    final transcriptionPrompt = _buildDirectPrompt(vocabulary, criticalInstructions);

    debugPrint('[OptimizedGeminiService] Using direct transcription mode...');

    try {
      final audioContent = Content.multi([
        TextPart(transcriptionPrompt),
        DataPart('audio/mp4', audioBytes),
      ]);

      // Use lightning model for faster responses
      final response = await _executeWithRetry(
        () => _lightningModel!.generateContent([audioContent]),
        operationName: 'direct-transcription',
        maxRetries: 2, // Fewer retries for speed
      );

      final rawText = response.text ?? '';
      debugPrint('[OptimizedGeminiService] Direct transcription complete');

      if (rawText.isEmpty) {
        throw Exception('Empty transcription received from API');
      }

      if (rawText.trim() == '[NO_SPEECH]') {
        throw Exception('No speech detected in audio');
      }

      final estimatedTokens = (rawText.length / 4).round();

      return TranscriptionResult(
        rawText: rawText,
        processedText: rawText, // Same text for direct mode
        tokenUsage: estimatedTokens,
      );
    } catch (e) {
      debugPrint('[OptimizedGeminiService] Direct transcription error: $e');
      rethrow;
    }
  }

  /// Combined transcription and processing in a single API call
  Future<TranscriptionResult> _combinedTranscription(
    Uint8List audioBytes,
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
  ) async {
    final combinedPrompt = _buildCombinedPrompt(promptTemplate, vocabulary, criticalInstructions);

    debugPrint('[OptimizedGeminiService] Using combined transcription mode...');

    try {
      final audioContent = Content.multi([
        TextPart(combinedPrompt),
        DataPart('audio/mp4', audioBytes),
      ]);

      final response = await _executeWithRetry(
        () => _model!.generateContent([audioContent]),
        operationName: 'combined-transcription',
      );

      final resultText = response.text ?? '';
      debugPrint('[OptimizedGeminiService] Combined transcription complete');

      if (resultText.isEmpty) {
        throw Exception('Empty transcription received from API');
      }

      // Extract raw and processed text from the response
      final parts = resultText.split('\n---\n');
      String rawText = resultText;
      String processedText = resultText;

      if (parts.length >= 2) {
        rawText = parts[0].trim();
        processedText = parts[1].trim();
      }

      final estimatedTokens = (resultText.length / 4).round();

      return TranscriptionResult(
        rawText: rawText,
        processedText: processedText,
        tokenUsage: estimatedTokens,
      );
    } catch (e) {
      debugPrint('[OptimizedGeminiService] Combined transcription error: $e');
      rethrow;
    }
  }

  /// Build direct transcription prompt
  String _buildDirectPrompt(String vocabulary, String? criticalInstructions) {
    final buffer = StringBuffer();

    buffer.writeln('Transcribe the audio accurately.');

    if (criticalInstructions != null) {
      buffer.writeln(criticalInstructions);
    } else {
      buffer.writeln('''
CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear
- If there is only silence or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT use the vocabulary below to generate fake transcriptions''');
    }

    if (vocabulary.isNotEmpty) {
      buffer.writeln('''
Reference vocabulary for technical terms (use ONLY if you actually hear these words spoken):
$vocabulary''');
    }

    buffer.writeln('''
Transcribe only what is spoken. Output only the transcription, nothing else.''');

    return buffer.toString();
  }

  /// Build combined prompt for single-call processing
  String _buildCombinedPrompt(String promptTemplate, String vocabulary, String? criticalInstructions) {
    final buffer = StringBuffer();

    buffer.writeln('Transcribe the following audio and then process it according to the instructions.');

    if (criticalInstructions != null) {
      buffer.writeln(criticalInstructions);
    }

    if (vocabulary.isNotEmpty) {
      buffer.writeln('''
Reference vocabulary for technical terms (use ONLY if you actually hear these words spoken):
$vocabulary''');
    }

    buffer.writeln('''
Step 1: Transcribe exactly what is spoken.
Step 2: Apply the following processing template to the transcription:
$promptTemplate

Output the raw transcription first, then "---", and finally the processed text.''');

    return buffer.toString();
  }

  /// Extract prompt ID from template for optimization decisions
  String _extractPromptId(String promptTemplate) {
    // This would ideally be passed directly, but we can extract it
    if (promptTemplate.contains('Clean up the following speech transcription')) {
      return 'default-clean';
    } else if (promptTemplate.contains('Convert the following speech transcription into formal written text')) {
      return 'default-formal';
    } else if (promptTemplate.contains('Convert the following speech transcription into organized bullet points')) {
      return 'default-bullet';
    }
    // Default to unknown
    return 'unknown';
  }

  /// Determine if transcription needs post-processing
  bool _shouldProcessTranscription(String promptId) {
    // For certain simple prompts, direct transcription is sufficient
    const directModePrompts = {'default-clean'};
    return !directModePrompts.contains(promptId);
  }

  /// Stream-based transcription for real-time feedback
  Stream<String> streamTranscription({
    required Stream<List<int>> audioStream,
    required String vocabulary,
    String? criticalInstructions,
  }) async* {
    // Accumulate audio chunks
    final audioBuffer = <int>[];

    await for (final chunk in audioStream) {
      audioBuffer.addAll(chunk);

      // Process when we have enough audio (e.g., 2 seconds)
      if (audioBuffer.length > 16000 * 2) { // Assuming 16kHz, 2 bytes per sample
        final result = await _directTranscription(
          Uint8List.fromList(audioBuffer),
          vocabulary,
          criticalInstructions,
        );

        yield result.processedText;

        // Keep some overlap for continuity
        audioBuffer.clear();
      }
    }
  }

  /// Execute operation with optimized retry strategy
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    String operationName = 'API call',
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(milliseconds: 500);

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        debugPrint('[OptimizedGeminiService] $operationName failed (attempt $attempt/$maxRetries): $e');

        final errorStr = e.toString().toLowerCase();

        // Don't retry on certain errors
        if (errorStr.contains('invalid_argument') ||
            errorStr.contains('permission_denied') ||
            errorStr.contains('not_found') ||
            errorStr.contains('api_key_invalid')) {
          debugPrint('[OptimizedGeminiService] Non-retryable error, failing immediately');
          rethrow;
        }

        // Faster retry for transient errors
        if (errorStr.contains('503') ||
            errorStr.contains('unavailable') ||
            errorStr.contains('429') ||
            errorStr.contains('resource_exhausted')) {
          if (attempt >= maxRetries) {
            rethrow;
          }

          // Exponential backoff with smaller initial delay
          final waitTime = Duration(
            milliseconds: (delay.inMilliseconds * (1 + Random().nextDouble() * 0.2)).round(),
          );

          debugPrint('[OptimizedGeminiService] Retrying $operationName in ${waitTime.inMilliseconds}ms...');
          await Future.delayed(waitTime);

          delay *= 2;
        } else {
          rethrow;
        }
      }
    }

    throw Exception('$operationName failed after $maxRetries attempts');
  }

  Future<(bool isValid, String? error)> validateApiKey(String apiKey) async {
    debugPrint('[OptimizedGeminiService] Validating API key...');
    try {
      final testModel = GenerativeModel(
        model: _lightningModelName,
        apiKey: apiKey,
      );

      final response = await testModel.generateContent([
        Content.text('OK'),
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        return (true, null);
      }
      return (false, 'No response from API');
    } catch (e) {
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
    _lightningModel = null;
  }
}