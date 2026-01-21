import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:crypto/crypto.dart';

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
  GoogleAIClient? _client;
  bool _disposed = false;

  // Model name from configuration
  static const String _defaultModelName = 'gemini-3-flash-preview';
  String _modelName = _defaultModelName;

  // API key
  String? _apiKey;

  // Request timeout for large audio files (5 minutes for files up to 100MB)
  static const Duration _requestTimeout = Duration(minutes: 5);

  // Simple LRU cache for transcription results
  final Map<String, TranscriptionResult> _cache = {};
  static const int _maxCacheSize = 50;

  bool get isInitialized => _client != null && _apiKey != null;

  /// Get the current model name
  String get modelName => _modelName;

  /// Initialize the service with API key and optional model name
  void initialize(String apiKey, {String? model, String? systemInstruction}) {
    if (_disposed) {
      debugPrint('[GeminiService] Service was disposed, creating new client');
      _disposed = false;
    }

    if (model != null) {
      _modelName = model;
    }

    _apiKey = apiKey;
    debugPrint(
        '[GeminiService] Initializing googleai_dart with model: $_modelName...');

    _client = GoogleAIClient(
      config: GoogleAIConfig(
        authProvider: ApiKeyProvider(apiKey),
        timeout: _requestTimeout, // Extended timeout for large audio files
      ),
    );

    debugPrint(
        '[GeminiService] Client initialized successfully (timeout: ${_requestTimeout.inMinutes}min)');
  }

  /// Build system instruction for multi-language transcription
  String _buildSystemInstruction() {
    return '''
You are a multilingual transcription assistant.

<TRANSCRIPTION_RULES>
- Detect the language automatically from the audio
- Transcribe in the ORIGINAL language only - NEVER translate
- If the audio mixes languages (code-switching), preserve each language as spoken
- Example: "这个feature很酷" should be transcribed exactly as-is
- Only transcribe actual speech; respond [NO_SPEECH] for only silence/noise
</TRANSCRIPTION_RULES>
''';
  }

  /// Generate a cache key for the audio and parameters
  ///
  /// Uses SHA-256 hash of the full audio bytes for accurate cache keys.
  /// This prevents false cache hits from different recordings that happen
  /// to have similar start/end byte patterns.
  String _generateCacheKey(
      Uint8List audioBytes, String vocabulary, String promptTemplate) {
    // Use SHA-256 for accurate, collision-resistant cache keys
    final audioDigest = sha256.convert(audioBytes);
    final audioHash = audioDigest.toString();

    // Include parameters in the hash
    final paramsDigest = sha256.convert(
      Uint8List.fromList('$vocabulary|$promptTemplate'.codeUnits),
    );
    final paramsHash = paramsDigest.toString();

    // Use first 16 chars of each hash for shorter keys
    return '${audioHash.substring(0, 16)}_$paramsHash';
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
    String? detectedLanguage,
  }) {
    final result = TranscriptionResult(
      rawText: rawText,
      processedText: processedText,
      tokenUsage: tokenUsage ?? 0,
      detectedLanguage: detectedLanguage,
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
    String? targetLanguage,
    bool useSingleCall = true,
  }) async {
    debugPrint('[GeminiService] transcribeAudio called');
    debugPrint('[GeminiService] Audio bytes: ${audioBytes.length}');

    if (_client == null || _apiKey == null) {
      throw Exception('Gemini service not initialized. Please set API key.');
    }

    // Check cache first
    final cacheKey = _generateCacheKey(audioBytes, vocabulary, promptTemplate);
    final cachedResult = _getFromCache(cacheKey);
    if (cachedResult != null) {
      debugPrint('[GeminiService] Returning cached transcription result');
      return cachedResult;
    }

    // Always use combined call for optimal performance
    return await _combinedTranscription(
      audioBytes,
      vocabulary,
      promptTemplate,
      criticalInstructions,
      cacheKey,
    );
  }

  Future<(bool isValid, String? error)> validateApiKey(String apiKey) async {
    debugPrint('[GeminiService] Validating API key...');
    try {
      final testClient = GoogleAIClient(
        config: GoogleAIConfig(
          authProvider: ApiKeyProvider(apiKey),
          timeout:
              const Duration(seconds: 30), // Shorter timeout for validation
        ),
      );

      final response = await testClient.models.generateContent(
        model: _modelName,
        request: const GenerateContentRequest(
          contents: [
            Content(
              parts: [TextPart('Say "OK"')],
              role: 'user',
            ),
          ],
        ),
      );

      final text = _extractTextFromResponse(response);
      debugPrint('[GeminiService] Validation response: $text');

      if (text != null && text.isNotEmpty) {
        debugPrint('[GeminiService] API key is valid');
        return (true, null);
      }
      return (false, 'No response from API');
    } catch (e) {
      debugPrint('[GeminiService] Validation error: $e');
      return _parseApiError(e);
    }
  }

  /// Parse API error and return user-friendly message
  (bool, String? error) _parseApiError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Handle empty response errors specifically
    if (errorStr.contains('empty transcription') ||
        errorStr.contains('empty_response') ||
        errorStr.contains('finishreason')) {
      return (
        false,
        'The API returned an empty response. This is a temporary issue. '
            'Please try again. If it persists, try recording again.'
      );
    }

    if (errorStr.contains('403') ||
        errorStr.contains('permission_denied') ||
        errorStr.contains('api_key_invalid') ||
        errorStr.contains('invalid api key') ||
        errorStr.contains('leaked')) {
      return (
        false,
        'Invalid API Key. Please check your Gemini API key in Settings.'
      );
    }
    if (errorStr.contains('404') || errorStr.contains('not_found')) {
      return (
        false,
        'Model not found. Please check the model name in Settings.'
      );
    }
    if (errorStr.contains('429') ||
        errorStr.contains('resource_exhausted') ||
        errorStr.contains('rate limit')) {
      return (false, 'Rate limited. Please wait a moment and try again.');
    }
    if (errorStr.contains('timeout') ||
        errorStr.contains('deadline_exceeded') ||
        errorStr.contains('504')) {
      return (
        false,
        'Request timed out. Your recording may be too long or your connection is slow. Try again or use a shorter recording.'
      );
    }
    if (errorStr.contains('500') || errorStr.contains('internal')) {
      return (false, 'Gemini API error. Please try again in a moment.');
    }
    if (errorStr.contains('503') || errorStr.contains('unavailable')) {
      return (
        false,
        'Gemini API temporarily unavailable. Please try again in a moment.'
      );
    }
    if (errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('socket')) {
      return (false, 'Network error. Please check your internet connection.');
    }

    // Default error message
    final message = errorStr.length > 150
        ? 'Transcription failed. Please try again.'
        : errorStr;
    return (false, message);
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

  /// Combined transcription and processing in a single API call
  ///
  /// Includes automatic retry for empty responses, which can occur due to
  /// transient API issues even with valid audio input.
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

    // Auto-retry for empty responses (known Gemini API transient issue)
    const maxEmptyRetries = 2;
    int emptyRetryCount = 0;

    while (emptyRetryCount <= maxEmptyRetries) {
      try {
        // Use Blob.fromBytes convenience factory for cleaner code
        final audioBlob = Blob.fromBytes('audio/wav', audioBytes);

        // Use audio/wav for PCM format (recommended for Gemini API)
        final audioContent = Content(
          parts: [
            TextPart(combinedPrompt),
            InlineDataPart(audioBlob),
          ],
          role: 'user',
        );

        // Build request with system instruction
        final request = GenerateContentRequest(
          contents: [audioContent],
          systemInstruction: Content(
            parts: [TextPart(_buildSystemInstruction())],
            role: 'user',
          ),
          generationConfig: const GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 8192,
            topP: 0.8,
            topK: 40,
          ),
        );

        final response = await _executeWithRetry(
          () => _client!.models.generateContent(
            model: _modelName,
            request: request,
          ),
          operationName: 'combined-transcription',
        );

        final resultText = _extractTextFromResponse(response) ?? '';
        debugPrint('[GeminiService] Combined transcription complete');

        // Handle empty response with automatic retry
        if (resultText.isEmpty) {
          if (emptyRetryCount < maxEmptyRetries) {
            emptyRetryCount++;
            debugPrint(
                '[GeminiService] Empty response received (attempt $emptyRetryCount/$maxEmptyRetries), retrying...');
            await Future.delayed(Duration(milliseconds: 500 * emptyRetryCount));
            continue;
          } else {
            // Final retry failed, throw detailed error
            debugPrint(
                '[GeminiService] Empty response after $maxEmptyRetries retries');
            throw _createEmptyResponseException(response);
          }
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

        // Get token usage from response metadata
        final tokenUsage = response.usageMetadata?.totalTokenCount ??
            (resultText.length / 4).round();

        return _createResult(
          cacheKey: cacheKey,
          rawText: rawText,
          processedText: processedText,
          tokenUsage: tokenUsage,
        );
      } catch (e) {
        // If it's not an empty response error, fail immediately
        if (!e.toString().contains('Empty transcription') &&
            !e.toString().contains('empty_response')) {
          debugPrint('[GeminiService] Combined transcription error: $e');
          final (_, userError) = _parseApiError(e);
          throw Exception(userError ?? 'Transcription failed: $e');
        }
        // If it's the last empty retry, rethrow
        if (emptyRetryCount >= maxEmptyRetries) {
          debugPrint('[GeminiService] Combined transcription error: $e');
          rethrow;
        }
      }
    }

    // Should never reach here, but satisfy the type checker
    throw Exception('Transcription failed after retries');
  }

  /// Create a detailed exception for empty API responses
  Exception _createEmptyResponseException(GenerateContentResponse response) {
    final candidates = response.candidates ?? [];
    final finishReason = candidates.isNotEmpty
        ? candidates.first.finishReason?.name ?? 'unknown'
        : 'no candidates';

    final buffer = StringBuffer(
        'Empty transcription received from API (finishReason: $finishReason)');

    if (response.promptFeedback != null) {
      buffer.write('. Prompt feedback: ${response.promptFeedback}');
    }

    return Exception(buffer.toString());
  }

  /// Extract text from GenerateContentResponse
  String? _extractTextFromResponse(GenerateContentResponse response) {
    for (final candidate in response.candidates ?? []) {
      for (final part in candidate.content?.parts ?? []) {
        if (part is TextPart) {
          return part.text;
        }
      }
    }
    return null;
  }

  /// Build combined prompt for single-call processing
  /// Optimized: concise instructions, reduced token overhead
  String _buildCombinedPrompt(
      String promptTemplate, String vocabulary, String? criticalInstructions) {
    final buffer =
        StringBuffer('Transcribe the audio, then apply:\n\n$promptTemplate');

    if (vocabulary.isNotEmpty) {
      buffer.write('\n\nVocabulary reference (use only if heard): $vocabulary');
    }

    if (criticalInstructions != null) {
      buffer.write('\n\n$criticalInstructions');
    }

    buffer.write('\n\nFormat: [raw transcription]\n---\n[processed text]');
    buffer.write('\n\nRespond [NO_SPEECH] if only silence.');

    return buffer.toString();
  }

  void dispose() {
    _client?.close();
    _client = null;
    _apiKey = null;
    _disposed = true;
    debugPrint('[GeminiService] Service disposed');
  }
}
