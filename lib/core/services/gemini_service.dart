import 'dart:async';
import 'dart:math';

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

/// Callback for when rate limit is hit
typedef RateLimitCallback = void Function(String apiKey);

/// Callback to get next available API key
typedef NextApiKeyCallback = String? Function(String currentApiKey);

class GeminiService implements TranscriptionServiceInterface {
  GoogleAIClient? _client;
  bool _disposed = false;

  // Model name from configuration
  static const String _defaultModelName = 'gemini-3-flash-preview';
  String _modelName = _defaultModelName;

  // API key
  String? _apiKey;

  // Callback when rate limit is hit
  RateLimitCallback? _onRateLimit;

  // Callback to get next available API key for auto-switching
  NextApiKeyCallback? _getNextApiKey;

  // Request timeout for large audio files (5 minutes for files up to 100MB)
  static const Duration _requestTimeout = Duration(minutes: 5);

  // Simple LRU cache for transcription results
  final Map<String, TranscriptionResult> _cache = {};
  static const int _maxCacheSize = 50;

  bool get isInitialized => _client != null && _apiKey != null;

  /// Get the current model name
  String get modelName => _modelName;

  /// Initialize the service with API key and optional model name
  void initialize(
    String apiKey, {
    String? model,
    String? systemInstruction,
    RateLimitCallback? onRateLimit,
    NextApiKeyCallback? getNextApiKey,
  }) {
    if (_disposed) {
      debugPrint('[GeminiService] Service was disposed, creating new client');
      _disposed = false;
    }

    if (model != null) {
      _modelName = model;
    }

    _apiKey = apiKey;
    _onRateLimit = onRateLimit;
    _getNextApiKey = getNextApiKey;

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

  /// Update the API key (for auto-switching)
  void updateApiKey(String newApiKey) {
    if (newApiKey == _apiKey) return;

    _apiKey = newApiKey;
    debugPrint('[GeminiService] Switching to new API key');

    _client = GoogleAIClient(
      config: GoogleAIConfig(
        authProvider: ApiKeyProvider(newApiKey),
        timeout: _requestTimeout,
      ),
    );
  }

  /// Build system instruction for speech transcription
  ///
  /// Consolidates all transcription rules into one place:
  /// - Conservative correction philosophy (phonetic plausibility)
  /// - Accent awareness for non-native speakers
  /// - Language detection and code-switching
  /// - Filler/artifact removal
  /// - Anti-hallucination guard
  String _buildSystemInstruction() {
    return 'You are a multilingual speech transcription assistant receiving raw audio. '
        'Detect and transcribe in the original language. Never translate. '
        'Preserve code-switching as spoken (e.g., "这个feature很酷").'
        '\n\n'
        'CORRECTION PHILOSOPHY: '
        'Most audio is transcribed correctly. Fix only what is genuinely wrong. '
        'Every correction must pass two tests: '
        '(1) the replacement sounds similar to the original — phonetically plausible as what was spoken, and '
        '(2) the corrected sentence reads as coherent and meaningful. '
        'If either test fails, keep the original. '
        'Under-correcting is always safer than over-correcting.'
        '\n\n'
        'ACCENT AWARENESS: '
        'The speaker may have a non-native accent. '
        'When a word doesn\'t fit context, consider similar-sounding alternatives the speaker likely intended, '
        'but only substitute if clearly correct.'
        '\n\n'
        'FIX: Misrecognized words that are phonetically close but semantically wrong. '
        'Broken word boundaries (split compounds, merged words). '
        'Grammar and punctuation errors from misrecognition, not speaker style.'
        '\n\n'
        'REMOVE: Filler sounds (um, uh, like, you know, 嗯, 那个, 就是, えーと, あの). '
        'Repeated phrases from audio overlap. '
        'False starts and abandoned thoughts (keep only the final version). '
        'Background noise transcribed as words.'
        '\n\n'
        'PRESERVE: Speaker\'s natural tone, register, and formality level. '
        'All words carrying substantive meaning. '
        'Words that already make sense in context.'
        '\n\n'
        'IMPORTANT: Only transcribe actual speech heard in the audio. '
        'Vocabulary and prompt text provided below are reference only — never transcribe them as if spoken.';
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
    bool isTruncated = false,
  }) {
    final result = TranscriptionResult(
      rawText: rawText,
      processedText: processedText,
      tokenUsage: tokenUsage ?? 0,
      detectedLanguage: detectedLanguage,
      isTruncated: isTruncated,
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
    String mimeType = 'audio/wav',
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

    // Try transcription with auto-switch on rate limit
    return await _transcribeWithAutoSwitch(
      audioBytes,
      vocabulary,
      promptTemplate,
      criticalInstructions,
      cacheKey,
      mimeType,
    );
  }

  /// Transcribe with automatic API key switching on rate limit
  Future<TranscriptionResult> _transcribeWithAutoSwitch(
    Uint8List audioBytes,
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
    String cacheKey,
    String mimeType,
  ) async {
    const maxKeySwitches = 3;
    int attempts = 0;

    while (attempts <= maxKeySwitches) {
      try {
        return await _combinedTranscription(
          audioBytes,
          vocabulary,
          promptTemplate,
          criticalInstructions,
          cacheKey,
          mimeType,
        );
      } catch (e) {
        final errorStr = e.toString().toLowerCase();

        // Check if this is a rate limit error (429)
        final isRateLimit = errorStr.contains('429') ||
            errorStr.contains('resource_exhausted') ||
            errorStr.contains('rate limit');

        if (isRateLimit && _apiKey != null) {
          debugPrint('[GeminiService] Rate limit hit for API key');

          // Notify rate limit callback
          _onRateLimit?.call(_apiKey!);

          // Try to switch to another key
          final nextKey = _getNextApiKey?.call(_apiKey!);
          if (nextKey != null && nextKey != _apiKey) {
            attempts++;
            debugPrint('[GeminiService] Auto-switching to alternative API key (attempt $attempts/$maxKeySwitches)');
            updateApiKey(nextKey);
            // Retry with new key
            continue;
          }
        }

        // If not rate limit, or no more keys to try, rethrow
        rethrow;
      }
    }

    throw Exception('All API keys are rate limited. Please wait or add more keys.');
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
  /// Global attempt cap prevents runaway retries across all retry layers.
  Future<TranscriptionResult> _combinedTranscription(
    Uint8List audioBytes,
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
    String cacheKey,
    String mimeType,
  ) async {
    final combinedPrompt =
        _buildCombinedPrompt(promptTemplate, vocabulary, criticalInstructions);

    debugPrint('[GeminiService] Using combined transcription mode...');

    // Auto-retry for empty responses (known Gemini API transient issue)
    // Capped at 2 retries to limit total API calls (combined with _executeWithRetry
    // and _transcribeWithAutoSwitch, max total attempts is bounded to ~6)
    const maxEmptyRetries = 2;
    int emptyRetryCount = 0;

    while (emptyRetryCount <= maxEmptyRetries) {
      try {
        // Use Blob.fromBytes with dynamic MIME type based on recording format
        final audioBlob = Blob.fromBytes(mimeType, audioBytes);
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

        // Stream response for faster perceived latency
        final resultBuffer = StringBuffer();
        int? streamTokenUsage;
        bool isTruncated = false;

        await _executeWithRetry(
          () async {
            resultBuffer.clear();
            streamTokenUsage = null;
            isTruncated = false;

            final stream = _client!.models.streamGenerateContent(
              model: _modelName,
              request: request,
            );

            await for (final chunk in stream) {
              final chunkText = chunk.text;
              if (chunkText != null) {
                resultBuffer.write(chunkText);
              }
              // Token usage is typically in the final chunk
              if (chunk.usageMetadata?.totalTokenCount != null) {
                streamTokenUsage = chunk.usageMetadata!.totalTokenCount;
              }
              // Check if output was truncated due to maxOutputTokens limit
              final finishReason = chunk.firstCandidate?.finishReason;
              if (finishReason == FinishReason.maxTokens) {
                isTruncated = true;
                debugPrint(
                    '[GeminiService] WARNING: Output truncated (hit maxOutputTokens limit)');
              }
            }
          },
          operationName: 'combined-transcription',
        );

        final resultText = resultBuffer.toString();
        debugPrint('[GeminiService] Combined transcription complete (streamed)');

        // Handle empty response with automatic retry
        if (resultText.isEmpty) {
          if (emptyRetryCount < maxEmptyRetries) {
            emptyRetryCount++;
            debugPrint(
                '[GeminiService] Empty response received (attempt $emptyRetryCount/$maxEmptyRetries), retrying...');
            await Future.delayed(Duration(milliseconds: 500 * emptyRetryCount));
            continue;
          } else {
            // Final retry failed
            debugPrint(
                '[GeminiService] Empty response after $maxEmptyRetries retries');
            throw Exception(
                'Empty transcription received from API after $maxEmptyRetries retries');
          }
        }

        // Single output format: the refined transcription is both raw and processed
        final transcriptionText = resultText.trim();

        if (transcriptionText == '[NO_SPEECH]') {
          throw Exception('No speech detected in audio');
        }

        // Token usage from stream metadata, fallback to estimate
        final finalTokenUsage = streamTokenUsage ?? (resultText.length / 4).round();

        return _createResult(
          cacheKey: cacheKey,
          rawText: transcriptionText,
          processedText: transcriptionText,
          tokenUsage: finalTokenUsage,
          isTruncated: isTruncated,
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
  ///
  /// Assembles user prompt, vocabulary, and critical instructions into
  /// a single user-role message alongside the audio.
  /// The system instruction handles correction philosophy and rules;
  /// this prompt specifies refinement style and context.
  String _buildCombinedPrompt(
      String promptTemplate, String vocabulary, String? criticalInstructions) {
    // Strip the {{text}} placeholder (legacy — audio is the input, not text)
    final cleanedTemplate = promptTemplate
        .replaceAll('\n\n{{text}}', '')
        .replaceAll('{{text}}', '')
        .trim();

    final buffer = StringBuffer('Transcribe the audio.');

    if (cleanedTemplate.isNotEmpty) {
      buffer.write('\n\nRefinement: $cleanedTemplate');
    }

    if (vocabulary.isNotEmpty) {
      buffer.write(
          '\n\nPrefer these terms/spellings if heard: $vocabulary');
    }

    if (criticalInstructions != null &&
        criticalInstructions.trim().isNotEmpty) {
      buffer.write('\n\n$criticalInstructions');
    }

    buffer.write(
        '\n\nOutput ONLY the transcription. '
        'If no speech detected, respond: [NO_SPEECH]');

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
