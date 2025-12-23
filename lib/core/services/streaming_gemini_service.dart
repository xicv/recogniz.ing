import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transcription_result.dart';
import '../interfaces/audio_service_interface.dart';

/// Streaming Gemini service for real-time transcription
/// Supports both chunked processing and live streaming
class StreamingGeminiService implements TranscriptionServiceInterface {
  late final GenerativeModel _model;
  bool _initialized = false;

  // Model name from configuration
  static const String _defaultModelName = 'gemini-3-flash-preview';
  String _modelName = _defaultModelName;

  // Streaming state
  final StreamController<TranscriptionChunk> _chunkController =
      StreamController<TranscriptionChunk>.broadcast();
  final StreamController<String> _textController =
      StreamController<String>.broadcast();
  final StreamController<TranscriptionResult> _resultController =
      StreamController<TranscriptionResult>.broadcast();

  // Buffers for chunked processing
  final List<Uint8List> _audioChunks = [];
  String _currentTranscription = '';
  int _totalTokens = 0;
  DateTime? _sessionStart;

  // Configuration
  final Duration _chunkTimeout = const Duration(seconds: 3);
  final int _maxChunkSize = 1024 * 1024; // 1MB per chunk

  @override
  bool get isInitialized => _initialized;

  /// Get the current model name
  String get modelName => _modelName;

  /// Initialize the Gemini service with streaming configuration
  void initialize(String apiKey, {String? model}) {
    if (model != null) {
      _modelName = model;
    }
    try {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          maxOutputTokens: 8192,
          topP: 0.8,
          topK: 40,
        ),
      );
      _initialized = true;

      debugPrint('[StreamingGeminiService] Initialized with model: $_modelName');
    } catch (e) {
      debugPrint('[StreamingGeminiService] Initialization failed: $e');
      rethrow;
    }
  }

  /// Get stream of transcription chunks as they arrive
  Stream<TranscriptionChunk> get transcriptionChunks => _chunkController.stream;

  /// Get stream of text updates
  Stream<String> get textUpdates => _textController.stream;

  /// Get stream of final results
  Stream<TranscriptionResult> get finalResults => _resultController.stream;

  @override
  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
  }) async {
    if (!_initialized) {
      throw Exception('Gemini service not initialized');
    }

    try {
      final prompt = _buildPrompt(
        vocabulary,
        promptTemplate,
        criticalInstructions,
      );

      // Check if audio is large enough for chunking
      if (audioBytes.length > _maxChunkSize) {
        return await _transcribeLargeAudio(audioBytes, prompt);
      }

      // Standard transcription for smaller audio
      final response = await _model.generateContent([Content.text(prompt)]);

      final result = TranscriptionResult(
        rawText: response.text ?? '',
        processedText: response.text ?? '',
        tokenUsage: _estimateTokens(response.text ?? ''),
      );

      _resultController.add(result);
      return result;
    } catch (e) {
      debugPrint('[StreamingGeminiService] Transcription error: $e');
      rethrow;
    }
  }

  /// Start streaming transcription session
  Future<void> startStreamingSession({
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
  }) async {
    if (!_initialized) {
      throw Exception('Gemini service not initialized');
    }

    _sessionStart = DateTime.now();
    _currentTranscription = '';
    _totalTokens = 0;

    debugPrint('[StreamingGeminiService] Streaming session started');

    // Process accumulated chunks periodically
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_audioChunks.isNotEmpty) {
        _processAccumulatedChunks(vocabulary, promptTemplate, criticalInstructions);
      }
    });
  }

  /// Add audio chunk to streaming session
  void addAudioChunk(Uint8List chunk) {
    _audioChunks.add(chunk);

    // Limit buffer size
    while (_audioChunks.length > 10) {
      _audioChunks.removeAt(0);
    }
  }

  /// End streaming session and get final result
  Future<TranscriptionResult> endStreamingSession() async {
    // Process any remaining chunks
    if (_audioChunks.isNotEmpty) {
      _processAccumulatedChunks('', '', null);
    }

    final result = TranscriptionResult(
      rawText: _currentTranscription,
      processedText: _currentTranscription,
      tokenUsage: _totalTokens,
    );

    _resultController.add(result);
    _cleanupSession();

    debugPrint('[StreamingGeminiService] Streaming session ended');
    return result;
  }

  /// Transcribe audio in real-time using WebSocket-like streaming
  Stream<String> transcribeStream({
    required Stream<Uint8List> audioStream,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
  }) async* {
    if (!_initialized) {
      throw Exception('Gemini service not initialized');
    }

    final buffer = BytesBuilder();
    await for (final chunk in audioStream) {
      buffer.add(chunk);

      // Process when we have enough data
      if (buffer.length >= _maxChunkSize) {
        final audioBytes = buffer.takeBytes();
        yield* _processStreamChunk(audioBytes, vocabulary, promptTemplate, criticalInstructions);
      }
    }

    // Process final chunk
    if (buffer.isNotEmpty) {
      final audioBytes = buffer.toBytes();
      yield* _processStreamChunk(audioBytes, vocabulary, promptTemplate, criticalInstructions);
    }
  }

  /// Process accumulated audio chunks
  Future<void> _processAccumulatedChunks(
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
  ) async {
    if (_audioChunks.isEmpty) return;

    // Combine chunks
    final combinedBytes = BytesBuilder();
    for (final chunk in _audioChunks) {
      combinedBytes.add(chunk);
    }
    final audioBytes = combinedBytes.toBytes();
    _audioChunks.clear();

    try {
      final prompt = _buildStreamingPrompt(vocabulary, promptTemplate, criticalInstructions, _currentTranscription);

      // Quick transcription
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      if (text.isNotEmpty) {
        // Calculate new content
        String newText = text;
        if (_currentTranscription.isNotEmpty && text.startsWith(_currentTranscription)) {
          newText = text.substring(_currentTranscription.length);
        }

        _currentTranscription = text;

        // Emit chunk
        final chunk = TranscriptionChunk(
          text: newText,
          timestamp: DateTime.now(),
          confidence: 0.9, // TODO: Calculate actual confidence
          isPartial: true,
        );

        _chunkController.add(chunk);
        _textController.add(_currentTranscription);
      }
    } catch (e) {
      debugPrint('[StreamingGeminiService] Chunk processing error: $e');
    }
  }

  /// Process stream chunk with partial results
  Stream<String> _processStreamChunk(
    Uint8List audioBytes,
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
  ) async* {
    try {
      final prompt = _buildPrompt(vocabulary, promptTemplate, criticalInstructions);

      // Use Gemini's streaming capability
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text ?? '';
      if (text.isNotEmpty) {
        yield text;
        _currentTranscription += text;
        _textController.add(_currentTranscription);
      }
    } catch (e) {
      debugPrint('[StreamingGeminiService] Stream processing error: $e');
    }
  }

  /// Transcribe large audio by splitting into chunks
  Future<TranscriptionResult> _transcribeLargeAudio(
    Uint8List audioBytes,
    String prompt,
  ) async {
    final chunks = _splitAudio(audioBytes);
    final results = <String>[];

    for (int i = 0; i < chunks.length; i++) {
      debugPrint('[StreamingGeminiService] Processing chunk ${i + 1}/${chunks.length}');

      final chunkPrompt = _buildChunkPrompt(prompt, results.join('\n'), i, chunks.length);
      final response = await _model.generateContent([Content.text(chunkPrompt)]);

      final text = response.text ?? '';
      if (text.isNotEmpty) {
        results.add(text);

        // Emit progress
        final progress = (i + 1) / chunks.length;
        _chunkController.add(TranscriptionChunk(
          text: text,
          timestamp: DateTime.now(),
          confidence: 0.9,
          isPartial: false,
          progress: progress,
        ));
      }
    }

    final fullTranscription = results.join(' ');
    _totalTokens += _estimateTokens(fullTranscription);

    return TranscriptionResult(
      rawText: fullTranscription,
      processedText: fullTranscription,
      tokenUsage: _totalTokens,
    );
  }

  /// Split large audio into manageable chunks
  List<Uint8List> _splitAudio(Uint8List audioBytes) {
    final chunks = <Uint8List>[];
    final chunkSize = _maxChunkSize;
    const headerSize = 44; // WAV header

    for (int i = 0; i < audioBytes.length; i += chunkSize) {
      final start = (i == 0) ? 0 : i;
      final end = (i + chunkSize < audioBytes.length) ? i + chunkSize : audioBytes.length;

      if (i == 0) {
        // First chunk includes header
        chunks.add(audioBytes.sublist(0, end));
      } else {
        // Subsequent chunks might need header manipulation
        final chunkData = audioBytes.sublist(start, end);
        chunks.add(chunkData);
      }
    }

    return chunks;
  }

  /// Build transcription prompt
  String _buildPrompt(
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
  ) {
    var prompt = criticalInstructions ?? '''
Transcribe the audio accurately.

CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear
- If there is only silence or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT use the vocabulary below to generate fake transcriptions
''';

    if (vocabulary.isNotEmpty) {
      prompt += '''

Reference vocabulary for technical terms (use ONLY if you actually hear these words spoken):
$vocabulary

Remember: Only transcribe what is actually spoken.''';
    }

    return prompt;
  }

  /// Build prompt for streaming with context
  String _buildStreamingPrompt(
    String vocabulary,
    String promptTemplate,
    String? criticalInstructions,
    String previousText,
  ) {
    var prompt = criticalInstructions ?? '''
Continue transcribing the audio chunk.

Previous transcription:
$previousText

CRITICAL INSTRUCTIONS:
- Only transcribe new speech in this audio chunk
- If there is no new speech, respond with exactly: [CONTINUE]
- Do NOT repeat what was already transcribed
''';

    if (vocabulary.isNotEmpty) {
      prompt += '''

Reference vocabulary: $vocabulary''';
    }

    return prompt;
  }

  /// Build prompt for chunk processing
  String _buildChunkPrompt(String basePrompt, String previousText, int chunkIndex, int totalChunks) {
    return '''
$basePrompt

Context: This is chunk $chunkIndex of $totalChunks.
Previous transcription:
${previousText.isNotEmpty ? previousText : '[START]'}

Please continue the transcription from where it left off.''';
  }

  /// Estimate token usage
  int _estimateTokens(String text) {
    // Rough estimation: ~4 characters per token
    return (text.length / 4).round();
  }

  /// Clean up session state
  void _cleanupSession() {
    _audioChunks.clear();
    _currentTranscription = '';
    _totalTokens = 0;
    _sessionStart = null;
  }

  /// Validate API key
  Future<(bool isValid, String? error)> validateApiKey(String apiKey) async {
    try {
      final model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
      );
      final response = await model.generateContent([Content.text('Say "OK"')]);

      if (response.text != null && response.text!.isNotEmpty) {
        return (true, null);
      }
      return (false, 'No response from API');
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('403') || errorStr.contains('API_KEY_INVALID')) {
        return (false, 'Invalid API Key');
      }
      if (errorStr.contains('404')) {
        return (false, 'Model not found');
      }
      if (errorStr.contains('429')) {
        return (false, 'Rate limited');
      }
      return (false, errorStr.length > 100 ? errorStr.substring(0, 100) : errorStr);
    }
  }

  void dispose() {
    _chunkController.close();
    _textController.close();
    _resultController.close();
    _cleanupSession();
    debugPrint('[StreamingGeminiService] Disposed');
  }
}

/// Transcription chunk with metadata
class TranscriptionChunk {
  final String text;
  final DateTime timestamp;
  final double confidence;
  final bool isPartial;
  final double? progress; // For chunked processing

  const TranscriptionChunk({
    required this.text,
    required this.timestamp,
    required this.confidence,
    required this.isPartial,
    this.progress,
  });
}