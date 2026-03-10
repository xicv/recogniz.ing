# Transcription Pipeline Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reduce transcription upload size (~50%) and latency through FLAC recording, streaming API, dynamic MIME type, and parallel audio persistence.

**Architecture:** Four independent, incremental improvements. Each is independently testable and shippable. No architectural changes to the existing retry/failover/caching/UI system. The streaming API change is internal to `GeminiService` — the `TranscriptionServiceInterface` returns the same `Future<TranscriptionResult>`.

**Tech Stack:** Flutter/Dart, `record` ^6.2.0 (`AudioEncoder.flac`), `googleai_dart` ^3.3.0 (`streamGenerateContent`), Riverpod

---

### Task 1: Add FLAC to AudioFormat and RecordConfig

**Files:**
- Modify: `lib/core/services/audio_compression_service.dart`

**Context:** The `AudioFormat` enum currently has `aacLc` and `pcm16bits`. The `getVoiceOptimizedConfig()` method returns PCM when `useReliable = true` (the default). We need to add FLAC and make it the new reliable default.

**Step 1: Add FLAC to AudioFormat enum**

In `lib/core/services/audio_compression_service.dart`, add `flac` to the `AudioFormat` enum after `pcm16bits`:

```dart
enum AudioFormat {
  /// AAC-LC compressed format (default compressed option, smaller files)
  aacLc,

  /// Uncompressed PCM format (largest files, no truncation risk)
  pcm16bits,

  /// FLAC lossless format (~50% smaller than PCM, no truncation risk)
  ///
  /// Recommended default: lossless compression with no encoder buffering issues.
  /// Supported on all platforms (macOS, Windows, Linux, iOS, Android).
  /// Format: FLAC (.flac)
  /// Size: ~0.8-1.0 MB/minute (at 16kHz, mono)
  /// Truncation Risk: NONE
  flac,
}
```

**Step 2: Add FLAC RecordConfig to getConfigForFormat**

Add the FLAC case to `getConfigForFormat()`:

```dart
static RecordConfig getConfigForFormat(AudioFormat format) {
  switch (format) {
    case AudioFormat.pcm16bits:
      return const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      );
    case AudioFormat.flac:
      return const RecordConfig(
        encoder: AudioEncoder.flac,
        sampleRate: 16000,
        numChannels: 1,
      );
    case AudioFormat.aacLc:
      return const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        bitRate: 64000,
        numChannels: 1,
      );
  }
}
```

**Step 3: Update getVoiceOptimizedConfig to use FLAC as reliable default**

Change the reliable format from PCM to FLAC in `getVoiceOptimizedConfig()`:

```dart
if (useReliable) {
  // Use FLAC for reliable recording: lossless, ~50% smaller than PCM, no truncation
  return const RecordConfig(
    encoder: AudioEncoder.flac,
    sampleRate: 16000,
    numChannels: 1,
  );
}
```

**Step 4: Update getReliableConfig**

```dart
static RecordConfig getReliableConfig() {
  return const RecordConfig(
    encoder: AudioEncoder.flac, // Lossless, no encoder buffering, ~50% smaller than PCM
    sampleRate: 16000,
    numChannels: 1,
  );
}
```

**Step 5: Update auto-mode in getConfigForPreference**

For the auto mode in `getConfigForPreference`, the 5+ minute case should use FLAC instead of PCM:

```dart
case AudioCompressionPreference.auto:
  if (durationSeconds < 120) {
    return (
      getConfigForFormat(AudioFormat.aacLc),
      false,
      null,
    );
  } else if (durationSeconds < 300) {
    return (
      getConfigForFormat(AudioFormat.aacLc),
      true,
      'Recording is ${_formatDuration(durationSeconds)}. AAC format may lose 0.5-2 seconds '
          'at the end. Consider using "Uncompressed" preference for better reliability.',
    );
  } else {
    return (
      getConfigForFormat(AudioFormat.flac), // FLAC instead of PCM
      false,
      null,
    );
  }
```

**Step 6: Run analyzer**

Run: `flutter analyze lib/core/services/audio_compression_service.dart`
Expected: No issues

**Step 7: Commit**

```bash
git add lib/core/services/audio_compression_service.dart
git commit -m "feat: add FLAC as default reliable recording format

FLAC is lossless (~50% smaller than PCM), has no encoder truncation
bug (unlike AAC), and is natively supported by the record package."
```

---

### Task 2: Update AudioService for FLAC file handling

**Files:**
- Modify: `lib/core/services/audio_service.dart`

**Context:** `AudioService.startRecording()` currently uses `.wav` extension for PCM and `.m4a` for AAC. The `stopRecording()` method classifies files as `isCompressedFormat` or `isPcmFormat` to decide processing. FLAC needs its own classification.

**Step 1: Update file extension logic in startRecording**

In `startRecording()`, update the file extension determination (around line 107-108):

```dart
final String fileExtension;
if (recordConfig.encoder == AudioEncoder.pcm16bits) {
  fileExtension = 'wav';
} else if (recordConfig.encoder == AudioEncoder.flac) {
  fileExtension = 'flac';
} else {
  fileExtension = 'm4a';
}
_currentRecordingPath = '${dir.path}/recording_$uuid.$fileExtension';
```

**Step 2: Update debug logging for format display**

Update the debug logging in `startRecording()` (around line 111-119):

```dart
if (kDebugMode) {
  debugPrint('[AudioService] Recording to: $_currentRecordingPath');
  final formatName = switch (recordConfig.encoder) {
    AudioEncoder.pcm16bits => 'PCM (uncompressed)',
    AudioEncoder.flac => 'FLAC (lossless compressed)',
    _ => 'AAC (lossy compressed)',
  };
  debugPrint('[AudioService] Format: $formatName');
}
```

**Step 3: Update format classification in stopRecording**

In `stopRecording()`, update the format classification (around line 261-263). FLAC should be treated like a compressed format for the processing pipeline — it doesn't need PCM audio processing or re-compression:

```dart
final isCompressedFormat = effectivePath.endsWith('.m4a') ||
    effectivePath.endsWith('.aac') ||
    effectivePath.endsWith('.flac');
final isPcmFormat = effectivePath.endsWith('.wav') || effectivePath.endsWith('.pcm');
final needsProcessing = !isCompressedFormat && !isPcmFormat;
```

**Step 4: Update format name in analysis bypass**

In `stopRecording()`, update the format name determination (around line 365):

```dart
final String formatName;
if (effectivePath.endsWith('.flac')) {
  formatName = 'FLAC';
} else if (isCompressedFormat) {
  formatName = 'AAC';
} else {
  formatName = 'PCM';
}
analysis = AudioAnalysisResult(
  containsSpeech: true,
  reason: '$formatName format - validation bypassed',
  averageAmplitude: 0.1,
  maxAmplitude: 0.2,
  speechRatio: 0.5,
);
```

**Step 5: Run analyzer**

Run: `flutter analyze lib/core/services/audio_service.dart`
Expected: No issues

**Step 6: Commit**

```bash
git add lib/core/services/audio_service.dart
git commit -m "feat: handle FLAC file extension and format classification in AudioService"
```

---

### Task 3: Add mimeType to RecordingResult and TranscriptionServiceInterface

**Files:**
- Modify: `lib/core/interfaces/audio_service_interface.dart`
- Modify: `lib/core/services/audio_service.dart` (RecordingResult class)

**Context:** The `TranscriptionServiceInterface` currently has no `mimeType` parameter. `GeminiService` hardcodes `'audio/wav'`. We need to thread the correct MIME type from recording through to the API call.

**Step 1: Add mimeType to RecordingResultInterface**

In `lib/core/interfaces/audio_service_interface.dart`, add `mimeType` to the interface:

```dart
abstract class RecordingResultInterface {
  String get path;
  List<int> get bytes;
  double get durationSeconds;
  AudioAnalysisResult? get analysis;
  String get mimeType;
}
```

**Step 2: Add mimeType to TranscriptionServiceInterface**

```dart
abstract class TranscriptionServiceInterface {
  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioBytes,
    required String vocabulary,
    required String promptTemplate,
    String? criticalInstructions,
    String? targetLanguage,
    String mimeType = 'audio/wav',
  });
}
```

**Step 3: Implement mimeType in RecordingResult**

In `lib/core/services/audio_service.dart`, add `mimeType` to the `RecordingResult` class:

```dart
class RecordingResult implements RecordingResultInterface {
  final String _path;
  final List<int> _bytes;
  final double _durationSeconds;
  final AudioAnalysisResult? _analysis;

  RecordingResult({
    required String path,
    required List<int> bytes,
    required double durationSeconds,
    AudioAnalysisResult? analysis,
  })  : _path = path,
        _bytes = bytes,
        _durationSeconds = durationSeconds,
        _analysis = analysis;

  bool get containsSpeech => _analysis?.containsSpeech ?? true;

  @override
  String get path => _path;

  @override
  List<int> get bytes => _bytes;

  @override
  double get durationSeconds => _durationSeconds;

  @override
  AudioAnalysisResult? get analysis => _analysis;

  @override
  String get mimeType {
    if (_path.endsWith('.flac')) return 'audio/flac';
    if (_path.endsWith('.m4a') || _path.endsWith('.aac')) return 'audio/aac';
    return 'audio/wav';
  }
}
```

**Step 4: Run analyzer**

Run: `flutter analyze lib/core/interfaces/audio_service_interface.dart lib/core/services/audio_service.dart`
Expected: No issues

**Step 5: Commit**

```bash
git add lib/core/interfaces/audio_service_interface.dart lib/core/services/audio_service.dart
git commit -m "feat: add mimeType to RecordingResult and TranscriptionServiceInterface"
```

---

### Task 4: Pass mimeType through VoiceRecordingUseCase to GeminiService

**Files:**
- Modify: `lib/core/use_cases/voice_recording_use_case.dart`
- Modify: `lib/core/services/gemini_service.dart`

**Context:** The use case calls `_transcriptionService.transcribeAudio(audioBytes: ...)` without a MIME type. `GeminiService._combinedTranscription` hardcodes `Blob.fromBytes('audio/wav', audioBytes)`. We need to thread `mimeType` through.

**Step 1: Add mimeType parameter to _callTranscriptionAPI**

In `lib/core/use_cases/voice_recording_use_case.dart`, add `mimeType` to `_callTranscriptionAPI`:

```dart
Future<void> _callTranscriptionAPI({
  required String transcriptionId,
  required Uint8List audioBytes,
  required String audioPath,
  required double audioDurationSeconds,
  String mimeType = 'audio/wav',
}) async {
```

**Step 2: Pass mimeType to transcribeAudio**

In `_callTranscriptionAPI`, add `mimeType` to the `transcribeAudio` call:

```dart
final result = await _transcriptionService.transcribeAudio(
  audioBytes: audioBytes,
  vocabulary: vocabulary?.words.join(', ') ?? '',
  promptTemplate:
      prompt?.promptTemplate ?? AppConstants.defaultPromptTemplate,
  criticalInstructions: settings.effectiveCriticalInstructions,
  mimeType: mimeType,
);
```

**Step 3: Pass mimeType from stopRecording through _processAudioWithRetry**

Update `_processAudioWithRetry` signature and the call from `stopRecording`:

In `stopRecording()`, update the call (around line 106):

```dart
await _processAudioWithRetry(
  recordingResult.bytes,
  recordingResult.path,
  recordingResult.durationSeconds,
  recordingResult.mimeType,
);
```

Update `_processAudioWithRetry` signature:

```dart
Future<void> _processAudioWithRetry(List<int> audioData, String audioPath,
    double audioDurationSeconds, String mimeType) async {
```

And pass it to `_callTranscriptionAPI`:

```dart
await _callTranscriptionAPI(
  transcriptionId: transcriptionId,
  audioBytes: Uint8List.fromList(audioData),
  audioPath: audioPath,
  audioDurationSeconds: audioDurationSeconds,
  mimeType: mimeType,
);
```

**Step 4: Handle retry path (mimeType from file extension)**

In `retryTranscription`, derive mimeType from the stored path:

```dart
// Derive MIME type from stored audio path
final retryMimeType = failedTranscription.audioBackupPath!.endsWith('.flac')
    ? 'audio/flac'
    : failedTranscription.audioBackupPath!.endsWith('.m4a')
        ? 'audio/aac'
        : 'audio/wav';

await _callTranscriptionAPI(
  transcriptionId: failedTranscription.id,
  audioBytes: audioBytes,
  audioPath: failedTranscription.audioBackupPath!,
  audioDurationSeconds: failedTranscription.audioDurationSeconds,
  mimeType: retryMimeType,
);
```

**Step 5: Update GeminiService to use dynamic mimeType**

In `lib/core/services/gemini_service.dart`, add `mimeType` parameter to `transcribeAudio`:

```dart
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
```

Pass it through to `_transcribeWithAutoSwitch` and `_combinedTranscription`:

Add `mimeType` parameter to `_transcribeWithAutoSwitch`:

```dart
Future<TranscriptionResult> _transcribeWithAutoSwitch(
  Uint8List audioBytes,
  String vocabulary,
  String promptTemplate,
  String? criticalInstructions,
  String cacheKey,
  String mimeType,
) async {
```

And to `_combinedTranscription`:

```dart
Future<TranscriptionResult> _combinedTranscription(
  Uint8List audioBytes,
  String vocabulary,
  String promptTemplate,
  String? criticalInstructions,
  String cacheKey,
  String mimeType,
) async {
```

**Step 6: Use dynamic mimeType in Blob creation**

In `_combinedTranscription`, replace the hardcoded MIME type (around line 464):

```dart
final audioBlob = Blob.fromBytes(mimeType, audioBytes);
```

**Step 7: Run analyzer**

Run: `flutter analyze lib/core/use_cases/voice_recording_use_case.dart lib/core/services/gemini_service.dart`
Expected: No issues

**Step 8: Commit**

```bash
git add lib/core/use_cases/voice_recording_use_case.dart lib/core/services/gemini_service.dart
git commit -m "feat: pass dynamic MIME type through pipeline to Gemini API

Supports audio/flac, audio/aac, and audio/wav based on actual
recording format instead of hardcoding audio/wav."
```

---

### Task 5: Switch to streaming API (streamGenerateContent)

**Files:**
- Modify: `lib/core/services/gemini_service.dart`

**Context:** `_combinedTranscription` currently uses `_client!.models.generateContent()` which blocks until the full response is ready. `googleai_dart` ^3.3.0 provides `streamGenerateContent()` which returns `Stream<GenerateContentResponse>` with the same request format. Each chunk has `.text` and the final chunk has `usageMetadata`.

**Step 1: Replace generateContent with streamGenerateContent in _combinedTranscription**

Replace the API call and response handling inside the `while (emptyRetryCount <= maxEmptyRetries)` loop in `_combinedTranscription`. The current code (lines ~490-496):

```dart
// Old code:
final response = await _executeWithRetry(
  () => _client!.models.generateContent(
    model: _modelName,
    request: request,
  ),
  operationName: 'combined-transcription',
);

final resultText = _extractTextFromResponse(response) ?? '';
```

Replace with:

```dart
// Stream response for faster perceived latency
final resultBuffer = StringBuffer();
int? tokenUsage;

await _executeWithRetry(
  () async {
    resultBuffer.clear();
    tokenUsage = null;

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
        tokenUsage = chunk.usageMetadata!.totalTokenCount;
      }
    }
  },
  operationName: 'combined-transcription',
);

final resultText = resultBuffer.toString();
```

**Step 2: Update the code below the API call**

The lines after the API call need minor adjustment. Replace:

```dart
debugPrint('[GeminiService] Combined transcription complete');

// Handle empty response with automatic retry
if (resultText.isEmpty) {
  // ... existing empty retry logic stays the same
}

// Single output format: the refined transcription is both raw and processed
final transcriptionText = resultText.trim();

if (transcriptionText == '[NO_SPEECH]') {
  throw Exception('No speech detected in audio');
}

// Get token usage from response metadata
final tokenUsage = response.usageMetadata?.totalTokenCount ??
    (resultText.length / 4).round();
```

With:

```dart
debugPrint('[GeminiService] Combined transcription complete (streamed)');

// Handle empty response with automatic retry
if (resultText.isEmpty) {
  // ... existing empty retry logic stays the same
}

// Single output format: the refined transcription is both raw and processed
final transcriptionText = resultText.trim();

if (transcriptionText == '[NO_SPEECH]') {
  throw Exception('No speech detected in audio');
}

// Token usage from stream metadata, fallback to estimate
final finalTokenUsage = tokenUsage ?? (resultText.length / 4).round();
```

And update the `_createResult` call to use `finalTokenUsage`:

```dart
return _createResult(
  cacheKey: cacheKey,
  rawText: transcriptionText,
  processedText: transcriptionText,
  tokenUsage: finalTokenUsage,
);
```

**Step 3: Remove _extractTextFromResponse usage from _combinedTranscription**

The `_extractTextFromResponse` helper is no longer used in `_combinedTranscription` (streaming uses `.text` extension directly). Keep the method since it's still used by `validateApiKey`.

**Step 4: Run analyzer**

Run: `flutter analyze lib/core/services/gemini_service.dart`
Expected: No issues

**Step 5: Commit**

```bash
git add lib/core/services/gemini_service.dart
git commit -m "perf: switch to streaming API (streamGenerateContent)

Uses SSE streaming internally for faster response delivery.
No UI changes - text is still accumulated and returned as a
complete TranscriptionResult."
```

---

### Task 6: Parallelize audio persistence with API call

**Files:**
- Modify: `lib/core/use_cases/voice_recording_use_case.dart`

**Context:** In `_processAudioWithRetry`, the audio is saved to persistent storage via `AudioStorageService.saveAudioBytes()` before the API call begins. These are independent operations — the API call doesn't need the persistent path. We can run them in parallel.

**Step 1: Move audio save into _callTranscriptionAPI and run in parallel**

Currently `_processAudioWithRetry` creates a pending transcription with `audioBackupPath: audioPath` where `audioPath` is from the temp recording. The persistent save happens separately in `AudioService.stopRecording()`.

Looking at the flow more carefully: the `audioPath` passed to `_processAudioWithRetry` is already the persistent path (set in `AudioService.stopRecording()` line 413: `path: persistentAudioPath ?? effectivePath`). So the save already happened before we get here.

The actual optimization is in `AudioService.stopRecording()` where `AudioStorageService.saveAudioBytes()` runs at line 383 before the method returns. This is already on the critical path before the API call starts.

**Revised approach:** Fire the persistent save as a non-blocking operation and return the result immediately with the temp path, letting the save complete in the background.

In `lib/core/services/audio_service.dart`, in `stopRecording()`, replace the sequential save (lines 379-396):

```dart
// Save audio to persistent storage for retry capability (non-blocking)
String? persistentAudioPath;
final saveFuture = () async {
  try {
    await AudioStorageService.initialize();
    persistentAudioPath = await AudioStorageService.saveAudioBytes(
      finalBytes,
    );
    if (kDebugMode) {
      debugPrint(
          '[AudioService] Audio saved to persistent storage: $persistentAudioPath');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
          '[AudioService] Failed to save audio to persistent storage: $e');
    }
  }
}();

// Wait for save to complete before returning
// This ensures the persistent path is available for retry
await saveFuture;
```

Actually, this doesn't change anything — we still await. The real optimization is to NOT await the save and instead use a callback or complete it later. But since the persistent path is needed for the pending transcription's `audioBackupPath`, we need it before the API call.

**Better approach:** Keep the current flow but make the temp file deletion non-blocking:

In `stopRecording()`, replace the temp file deletion (lines 398-410) with a non-blocking version:

```dart
// Delete the temporary file in the background (non-blocking)
if (effectivePath != persistentAudioPath) {
  () async {
    try {
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          debugPrint('[AudioService] Temporary file deleted');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AudioService] Failed to delete temp file: $e');
      }
    }
  }(); // Fire and forget
}
```

This saves the file deletion time (~50-100ms) from the critical path.

**Step 2: Run analyzer**

Run: `flutter analyze lib/core/services/audio_service.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/core/services/audio_service.dart
git commit -m "perf: non-blocking temp file cleanup after recording

Fire-and-forget temp file deletion to reduce time on critical path
before API call begins."
```

---

### Task 7: Manual testing and verification

**Step 1: Build and run**

```bash
cd /Users/xicao/Library/CloudStorage/Dropbox/Projects/recogniz.ing
flutter run -d macos
```

**Step 2: Test FLAC recording**

1. Open Settings, ensure audio compression is set to "Uncompressed" (which now uses FLAC)
2. Record a short voice clip (~5 seconds)
3. Check debug console for:
   - `[AudioService] Format: FLAC (lossless compressed)`
   - `[AudioService] Recording to: .../recording_xxx.flac`
   - `[AudioService] FLAC format validation passed`
4. Verify transcription completes successfully

**Step 3: Test streaming**

1. Record another voice clip
2. Check debug console for:
   - `[GeminiService] Combined transcription complete (streamed)`
3. Verify the transcription result appears correctly

**Step 4: Test AAC mode still works**

1. Switch audio compression to "Always Compressed" in Settings
2. Record a voice clip
3. Check debug console shows AAC format
4. Verify transcription completes

**Step 5: Test retry**

1. Enable airplane mode or use an invalid API key temporarily
2. Record a voice clip — should fail with error
3. Restore connectivity / fix API key
4. Retry the failed transcription
5. Verify retry works with correct MIME type

**Step 6: Run flutter analyze**

```bash
flutter analyze
```
Expected: No issues

**Step 7: Run tests**

```bash
flutter test
```
Expected: All tests pass

**Step 8: Final commit (if any fixups needed)**

```bash
git add -A
git commit -m "fix: address issues found during manual testing"
```
