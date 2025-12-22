import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/transcription_result.dart';
import '../interfaces/audio_service_interface.dart';

/// Performance optimizations for Gemini API
class GeminiPerformanceConfig {
  // Enable caching for repeated requests
  static const bool enableCaching = true;

  // Audio pre-processing to reduce API calls
  static const bool enableVADPreprocessing = true;

  // Minimum audio duration before sending to API (seconds)
  static const double minAudioDuration = 0.5;

  // Maximum audio duration for optimal performance (seconds)
  static const double maxAudioDuration = 60.0;
}

class GeminiService implements TranscriptionServiceInterface {
  GenerativeModel? _model;
  GenerativeModel? _lightningModel;



  // Simple LRU cache for transcription results
  final Map<String, TranscriptionResult> _cache = {};
  static const int _maxCacheSize = 50;

  bool get isInitialized => _model != null;

  void initialize(String apiKey) {
    debugPrint('[GeminiService] Initializing with models...');
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: 8192, // Increased for longer transcriptions
        topP: 0.8,
        topK: 40,
      ),
    );

    // Initialize a model configured for longer transcriptions
    _lightningModel = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens:
            8192, // Increased for longer transcriptions (~6000 words)
        topP: 0.8,
        topK: 40,
      ),
    );

    debugPrint('[GeminiService] Models initialized successfully');
  }

  /// Generate a cache key for the audio and parameters
  String _generateCacheKey(
      Uint8List audioBytes, String vocabulary, String promptTemplate) {
    final audioHash = audioBytes.fold<int>(
        0, (hash, byte) => hash = ((hash << 5) - hash) + byte);
    final paramsHash = '${vocabulary.length}_${promptTemplate.length}'.hashCode;
    return '${audioHash}_$paramsHash';
  }

  /// Get result from cache if available
  TranscriptionResult? _getFromCache(String cacheKey) {
    if (!GeminiPerformanceConfig.enableCaching) return null;
    return _cache[cacheKey];
  }

  /// Store result in cache
  void _storeInCache(String cacheKey, TranscriptionResult result) {
    if (!GeminiPerformanceConfig.enableCaching) return;

    // Simple LRU: if cache is full, remove oldest entry
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache[cacheKey] = result;
    debugPrint('[GeminiService] Cached transcription result');
  }

  /// Create and cache a transcription result
  TranscriptionResult _createResult({
    required String cacheKey,
    required String rawText,
    required String processedText,
    int? tokenUsage,
  }) {
    final result = TranscriptionResult(
      rawText: rawText,
      processedText: processedText,
      tokenUsage: tokenUsage ?? 0,
    );
    _storeInCache(cacheKey, result);
    return result;
  }

  @override
  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
    bool useSingleCall = true,
  }) async {
    debugPrint('[GeminiService] transcribeAudio called');
    debugPrint('[GeminiService] Audio bytes: ${audioBytes.length}');
    debugPrint('[GeminiService] Vocabulary: $vocabulary');
    debugPrint('[GeminiService] Single call mode: $useSingleCall');

    if (_model == null) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    // Check cache first
    final cacheKey = _generateCacheKey(audioBytes, vocabulary, promptTemplate);
    final cachedResult = _getFromCache(cacheKey);
    if (cachedResult != null) {
      debugPrint('[GeminiService] Returning cached transcription result');
      return cachedResult;
    }

    // Check if we can use single call mode
    final promptId = _extractPromptId(promptTemplate);
    final needsProcessing = _requiresPostProcessing(promptId);

    if (!needsProcessing || useSingleCall) {
      if (needsProcessing) {
        // Use combined prompt for single call
        return await _combinedTranscription(audioBytes, vocabulary,
            promptTemplate, criticalInstructions, cacheKey);
      } else {
        // Use direct transcription
        return await _directTranscription(
            audioBytes, vocabulary, criticalInstructions, cacheKey);
      }
    }

    // Fall back to two separate calls

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

      debugPrint(
          '[GeminiService] Calling generateContent for transcription...');
      final transcriptionResponse = await _executeWithRetry(
        () => _model!.generateContent([audioContent]),
        operationName: 'transcription',
      );

      final rawText = transcriptionResponse.text ?? '';
      debugPrint(
          '[GeminiService] Raw transcription received (${rawText.length} chars): ${rawText.length > 200 ? "${rawText.substring(0, 200)}..." : rawText}');

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
      debugPrint(
          '[GeminiService] Processed prompt preview: ${processedPrompt.length > 200 ? "${processedPrompt.substring(0, 200)}..." : processedPrompt}');

      final processedResponse = await _executeWithRetry(
        () => _model!.generateContent([Content.text(processedPrompt)]),
        operationName: 'processing',
      );

      final processedText = processedResponse.text ?? rawText;
      debugPrint(
          '[GeminiService] Processed text received (${processedText.length} chars): ${processedText.length > 200 ? "${processedText.substring(0, 200)}..." : processedText}');

      // Estimate token usage
      final estimatedTokens =
          ((rawText.length + processedPrompt.length + processedText.length) / 4)
              .round();

      return _createResult(
        cacheKey: cacheKey,
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
          debugPrint(
              '[GeminiService] Non-retryable error, failing immediately');
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
            debugPrint(
                '[GeminiService] Max retries exceeded for $operationName');
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

  /// Direct transcription without post-processing
  Future<TranscriptionResult> _directTranscription(
    Uint8List audioBytes,
    String vocabulary,
    String? criticalInstructions,
    String cacheKey,
  ) async {
    final transcriptionPrompt =
        _buildDirectPrompt(vocabulary, criticalInstructions);

    debugPrint('[GeminiService] Using direct transcription mode...');

    try {
      final audioContent = Content.multi([
        TextPart(transcriptionPrompt),
        DataPart('audio/mp4', audioBytes),
      ]);

      // Use lightning model for quicker responses
      final response = await _executeWithRetry(
        () => _lightningModel!.generateContent([audioContent]),
        operationName: 'direct-transcription',
        maxRetries: 2, // Fewer retries for speed
      );

      final rawText = response.text ?? '';
      debugPrint(
          '[GeminiService] Direct transcription complete (${rawText.length} chars): ${rawText.length > 200 ? "${rawText.substring(0, 200)}..." : rawText}');

      if (rawText.isEmpty) {
        throw Exception('Empty transcription received from API');
      }

      if (rawText.trim() == '[NO_SPEECH]') {
        throw Exception('No speech detected in audio');
      }

      final estimatedTokens = (rawText.length / 4).round();

      return _createResult(
        cacheKey: cacheKey,
        rawText: rawText,
        processedText: rawText, // Same text for direct mode
        tokenUsage: estimatedTokens,
      );
    } catch (e) {
      debugPrint('[GeminiService] Direct transcription error: $e');
      rethrow;
    }
  }

  /// Combined transcription and processing in a single API call
  Future<TranscriptionResult> _combinedTranscription(
    Uint8List audioBytes,
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
    String cacheKey,
  ) async {
    final combinedPrompt =
        _buildCombinedPrompt(promptTemplate, vocabulary, criticalInstructions);

    debugPrint('[GeminiService] Using combined transcription mode...');

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
      debugPrint('[GeminiService] Combined transcription complete');

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

      if (rawText.trim() == '[NO_SPEECH]') {
        throw Exception('No speech detected in audio');
      }

      final estimatedTokens = (resultText.length / 4).round();

      return _createResult(
        cacheKey: cacheKey,
        rawText: rawText,
        processedText: processedText,
        tokenUsage: estimatedTokens,
      );
    } catch (e) {
      debugPrint('[GeminiService] Combined transcription error: $e');
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
  String _buildCombinedPrompt(
      String promptTemplate, String vocabulary, String? criticalInstructions) {
    final buffer = StringBuffer();

    buffer.writeln(
        'Transcribe the following audio and then process it according to the instructions.');

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

  /// Extract prompt ID from template
  String _extractPromptId(String promptTemplate) {
    if (promptTemplate
        .contains('Clean up the following speech transcription')) {
      return 'default-clean';
    } else if (promptTemplate.contains(
        'Convert the following speech transcription into formal written text')) {
      return 'default-formal';
    } else if (promptTemplate.contains(
        'Convert the following speech transcription into organized bullet points')) {
      return 'default-bullet';
    }
    return 'unknown';
  }

  /// Determine if transcription needs post-processing
  bool _requiresPostProcessing(String promptId) {
    // No prompts should use direct mode since they all need processing
    // Direct mode bypasses the prompt template entirely
    return true; // Always use full processing
  }

  void dispose() {
    _model = null;
    _lightningModel = null;
  }
}
