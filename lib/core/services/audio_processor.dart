import 'dart:isolate';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../interfaces/audio_service_interface.dart';

/// Audio processor that runs analysis in a separate isolate
class AudioProcessor {
  static Isolate? _analysisIsolate;
  static ReceivePort? _receivePort;
  static SendPort? _sendPort;

  /// Initialize the audio analyzer isolate
  static Future<void> initialize() async {
    if (_analysisIsolate != null) return;

    final receivePort = ReceivePort();
    _receivePort = receivePort;

    _analysisIsolate = await Isolate.spawn(
      _analysisWorker,
      receivePort.sendPort,
    );

    // Get the send port from the worker
    final completer = Completer<SendPort>();
    receivePort.listen((message) {
      if (message is SendPort) {
        completer.complete(message);
      }
    });

    _sendPort = await completer.future;
  }

  /// Analyze audio bytes in a background isolate
  static Future<AudioAnalysisResult> analyzeAudio({
    required Uint8List audioBytes,
    required double amplitudeThreshold,
    required double speechRatioThreshold,
    required int sampleRate,
    required int bitDepth,
  }) async {
    ensureInitialized();

    final completer = Completer<AudioAnalysisResult>();
    final responsePort = ReceivePort();

    _sendPort!.send({
      'command': 'analyze',
      'audioBytes': audioBytes,
      'amplitudeThreshold': amplitudeThreshold,
      'speechRatioThreshold': speechRatioThreshold,
      'sampleRate': sampleRate,
      'bitDepth': bitDepth,
      'responsePort': responsePort.sendPort,
    });

    responsePort.listen((result) {
      if (result is Map<String, dynamic>) {
        final analysisResult = AudioAnalysisResult(
          averageAmplitude: result['averageAmplitude'],
          maxAmplitude: result['maxAmplitude'],
          speechRatio: result['speechRatio'],
          containsSpeech: result['containsSpeech'],
          reason: result['reason'],
        );
        completer.complete(analysisResult);
      }
      responsePort.close();
    });

    return completer.future;
  }

  /// Perform streaming audio analysis for immediate feedback
  static Stream<double> analyzeStreaming({
    required Stream<List<int>> audioStream,
    required double amplitudeThreshold,
    int windowSize = 1024,
  }) async* {
    ensureInitialized();

    final buffer = <int>[];

    await for (final chunk in audioStream) {
      buffer.addAll(chunk);

      // Analyze every window
      if (buffer.length >= windowSize * 2) {
        // 16-bit audio
        final windowData = buffer.take(windowSize * 2).toList();

        // Calculate RMS for the window
        final rms = _calculateRMS(windowData);
        yield rms;

        // Remove processed data from buffer
        buffer.removeRange(0, windowSize * 2);
      }
    }
  }

  /// Quick amplitude check for immediate feedback
  static double checkAmplitude(List<int> audioChunk) {
    if (audioChunk.isEmpty) return 0.0;
    return _calculateRMS(audioChunk);
  }

  /// Ensure the analyzer is initialized
  static void ensureInitialized() {
    if (_analysisIsolate == null) {
      throw StateError(
          'AudioProcessor not initialized. Call initialize() first.');
    }
  }

  /// Dispose the audio analyzer
  static void dispose() {
    _analysisIsolate?.kill(priority: Isolate.immediate);
    _analysisIsolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
  }

  /// Calculate RMS (Root Mean Square) amplitude
  static double _calculateRMS(List<int> audioData) {
    if (audioData.isEmpty) return 0.0;

    double sum = 0.0;
    for (int i = 0; i < audioData.length; i += 2) {
      // Combine two bytes into a 16-bit sample
      final sample = audioData[i] | (audioData[i + 1] << 8);
      // Convert to signed 16-bit
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      sum += (signedSample / 32767.0) * (signedSample / 32767.0);
    }

    return sqrt(sum / (audioData.length / 2));
  }

  /// Background worker isolate for audio analysis
  static void _analysisWorker(SendPort mainSendPort) async {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    await for (final message in receivePort) {
      if (message is Map<String, dynamic>) {
        final command = message['command'];

        if (command == 'analyze') {
          final audioBytes = message['audioBytes'] as Uint8List;
          final amplitudeThreshold = message['amplitudeThreshold'] as double;
          final speechRatioThreshold =
              message['speechRatioThreshold'] as double;
          final sampleRate = message['sampleRate'] as int;
          final bitDepth = message['bitDepth'] as int;
          final responsePort = message['responsePort'] as SendPort;

          // Perform analysis
          final result = _performAnalysis(
            audioBytes,
            amplitudeThreshold,
            speechRatioThreshold,
            sampleRate,
            bitDepth,
          );

          responsePort.send(result);
        }
      }
    }
  }

  /// Perform the actual audio analysis
  static Map<String, dynamic> _performAnalysis(
    Uint8List audioBytes,
    double amplitudeThreshold,
    double speechRatioThreshold,
    int sampleRate,
    int bitDepth,
  ) {
    // Calculate RMS amplitude
    double sum = 0.0;
    int samples = 0;

    // Process 16-bit samples
    for (int i = 0; i < audioBytes.length - 1; i += 2) {
      final sample = audioBytes[i] | (audioBytes[i + 1] << 8);
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      final normalized = signedSample / 32767.0;
      sum += normalized * normalized;
      samples++;
    }

    final averageAmplitude = samples > 0 ? sqrt(sum / samples) : 0.0;
    final maxAmplitude = _calculateMaxAmplitude(audioBytes);

    // Estimate speech ratio based on amplitude patterns
    final speechRatio =
        _estimateSpeechRatio(audioBytes, averageAmplitude, sampleRate);

    // Determine if speech is present
    final containsSpeech = _containsSpeech(
      averageAmplitude,
      maxAmplitude,
      speechRatio,
      amplitudeThreshold,
      speechRatioThreshold,
    );

    return {
      'averageAmplitude': averageAmplitude,
      'maxAmplitude': maxAmplitude,
      'speechRatio': speechRatio,
      'containsSpeech': containsSpeech,
      'reason': _getReason(
          averageAmplitude, maxAmplitude, speechRatio, containsSpeech),
    };
  }

  /// Calculate maximum amplitude
  static double _calculateMaxAmplitude(Uint8List audioBytes) {
    double maxAmp = 0.0;

    for (int i = 0; i < audioBytes.length - 1; i += 2) {
      final sample = audioBytes[i] | (audioBytes[i + 1] << 8);
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      final amplitude = (signedSample.abs() / 32767.0).toDouble();
      if (amplitude > maxAmp) {
        maxAmp = amplitude;
      }
    }

    return maxAmp;
  }

  /// Estimate speech ratio based on amplitude variations
  static double _estimateSpeechRatio(
    Uint8List audioBytes,
    double avgAmplitude,
    int sampleRate,
  ) {
    if (audioBytes.length < 1024) return 0.0;

    // Sample the audio at intervals
    const samplesPerSecond = 100;
    final interval = sampleRate ~/ samplesPerSecond;
    const bytesPerSample = 2; // 16-bit
    final step = interval * bytesPerSample;

    int speechSamples = 0;
    int totalSamples = 0;

    for (int i = 0; i < audioBytes.length - step; i += step) {
      double windowSum = 0.0;
      int windowSamples = 0;

      // Calculate average for this window
      for (int j = 0; j < step && i + j < audioBytes.length - 1; j += 2) {
        final sample = audioBytes[i + j] | (audioBytes[i + j + 1] << 8);
        final signedSample = sample > 32767 ? sample - 65536 : sample;
        final normalized = signedSample / 32767.0;
        windowSum += normalized * normalized;
        windowSamples++;
      }

      if (windowSamples > 0) {
        final windowAvg = sqrt(windowSum / windowSamples);
        if (windowAvg > avgAmplitude * 0.5) {
          speechSamples++;
        }
        totalSamples++;
      }
    }

    return totalSamples > 0 ? speechSamples / totalSamples : 0.0;
  }

  /// Determine if audio contains speech
  static bool _containsSpeech(
    double avgAmplitude,
    double maxAmplitude,
    double speechRatio,
    double amplitudeThreshold,
    double speechRatioThreshold,
  ) {
    // Strong signal overrides ratio requirement
    if (avgAmplitude >= amplitudeThreshold * 2.0 || maxAmplitude > 0.9) {
      return true;
    }

    // Both amplitude and ratio must meet thresholds
    return avgAmplitude >= amplitudeThreshold &&
        speechRatio >= speechRatioThreshold;
  }

  /// Generate analysis reason
  static String _getReason(
    double avgAmplitude,
    double maxAmplitude,
    double speechRatio,
    bool containsSpeech,
  ) {
    if (!containsSpeech) {
      if (avgAmplitude < 0.01) {
        return 'No signal detected';
      } else if (speechRatio < 0.05) {
        return 'Insufficient speech activity';
      } else {
        return 'Low amplitude below threshold';
      }
    } else {
      if (maxAmplitude > 0.9) {
        return 'Strong signal detected';
      } else if (speechRatio > 0.3) {
        return 'Speech detected (high activity)';
      } else {
        return 'Speech detected (avg: ${avgAmplitude.toStringAsFixed(3)}, max: ${maxAmplitude.toStringAsFixed(3)}, ratio: ${(speechRatio * 100).toStringAsFixed(1)}%)';
      }
    }
  }
}

/// Audio analysis result
class AudioAnalysisResult implements AudioAnalysis {
  @override
  final bool containsSpeech;
  @override
  final String reason;
  final double averageAmplitude;
  final double maxAmplitude;
  final double speechRatio;

  const AudioAnalysisResult({
    required this.averageAmplitude,
    required this.maxAmplitude,
    required this.speechRatio,
    required this.containsSpeech,
    required this.reason,
  });
}
