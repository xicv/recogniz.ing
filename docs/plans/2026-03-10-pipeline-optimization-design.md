# Transcription Pipeline Optimization Design

**Goal:** Reduce transcription latency and upload size through 4 independent, low-risk improvements to the audio recording and API call pipeline.

**Approach:** Incremental optimization — each change is independently shippable and testable. No architectural changes to the existing retry/failover/caching system.

---

## Research Summary

Three areas were researched before designing:

1. **Gemini API**: `streamGenerateContent` available in `googleai_dart` ^3.3.0 via SSE. 32 tokens/second for audio regardless of format. Gemini downsamples to 16kHz mono internally.
2. **Current Pipeline**: 8 sequential stages; main bottleneck is API network call (2-60s+). Local processing is ~1-2s. Single-call transcription+refinement is already optimal.
3. **Audio Encoding**: FLAC is lossless, ~50% smaller than WAV, natively supported by both the `record` package (`AudioEncoder.flac`) and Gemini API (`audio/flac`).

## Changes

### 1. FLAC Recording (Default Format)

**What:** Replace PCM16bits as the default reliable format with FLAC.

**Why:** FLAC is lossless (identical quality to PCM), ~50% smaller uploads, no encoder truncation bug (unlike AAC), and Gemini natively supports `audio/flac`. The `record` package has `AudioEncoder.flac` on all platforms.

**Files:**
- `lib/core/services/audio_compression_service.dart` — Add `flac` to `AudioFormat` enum, add FLAC `RecordConfig`, make FLAC the new default for `useReliableFormat = true`
- `lib/core/services/audio_service.dart` — Update file extension logic (`.flac`), update format classification
- `lib/core/services/gemini_service.dart` — Dynamic MIME type (`audio/flac` vs `audio/wav`)

**Preserved:** AAC option remains for "Always Compressed" users. PCM remains as fallback.

### 2. Streaming API Response

**What:** Replace `generateContent()` with `streamGenerateContent()` in `_combinedTranscription`.

**Why:** First tokens arrive in ~1-2s instead of waiting for full response (2-60s+). Reduces total wall-clock time even with "instant save on completion" UX (no UI changes needed).

**How:** `streamGenerateContent` returns `Stream<GenerateContentResponse>`. We `await for` chunks, concatenating `chunk.text`. Token usage from final chunk's `usageMetadata`. Same request format, same response type per chunk.

**Files:**
- `lib/core/services/gemini_service.dart` — Modify `_combinedTranscription` to use streaming

**Preserved:** `TranscriptionServiceInterface`, `VoiceRecordingUseCase`, all UI code, retry logic, cache logic, rate limit switching.

### 3. Dynamic MIME Type

**What:** Replace hardcoded `'audio/wav'` with dynamic MIME type based on actual audio format.

**How:** Add optional `mimeType` parameter to `transcribeAudio`. `RecordingResult` provides MIME type based on file extension. Passed through `VoiceRecordingUseCase` to `GeminiService`.

**Files:**
- `lib/core/interfaces/audio_service_interface.dart` — Add `mimeType` to `TranscriptionServiceInterface.transcribeAudio`
- `lib/core/services/gemini_service.dart` — Use passed MIME type
- `lib/core/services/audio_service.dart` — Add `mimeType` getter to `RecordingResult`
- `lib/core/use_cases/voice_recording_use_case.dart` — Pass MIME type through

### 4. Parallel Audio Persistence

**What:** Run `AudioStorageService.saveAudioBytes()` in parallel with the API call instead of sequentially before it.

**Why:** Saves ~100-200ms. The save result (persistent path) is only needed for retry, not the API call.

**Files:**
- `lib/core/use_cases/voice_recording_use_case.dart` — Restructure `_processAudioWithRetry` to parallelize

**Risk:** Very low. If save fails, transcription still works — retry just won't be available (same as current fallback).

## UX Decision

**Streaming UX: Instant save on completion.** The UI shows "Processing..." spinner during streaming. Transcription card appears only when fully complete. No UI changes needed.

## What's NOT Changing

- Single API call architecture (already optimal)
- AAC compression option (kept for users who want smallest files)
- Retry/failover/caching system
- Audio validation pipeline (silence/noise detection)
- Default model (`gemini-3-flash-preview`) — model changes deferred to separate effort
- `RecordingState` enum and provider states
- Transcription data model / Hive serialization

## Risk Assessment

| Change | Risk | Mitigation |
|--------|------|------------|
| FLAC recording | Low | Lossless = zero quality diff from PCM. Fallback to PCM if encoder fails. |
| Streaming API | Low | Same request/response types. Retry logic wraps entire stream. |
| Dynamic MIME | Trivial | Simple string mapping. Default falls back to `audio/wav`. |
| Parallel persistence | Very low | Fire-and-forget pattern; failure doesn't block transcription. |

## Expected Impact

| Metric | Before | After |
|--------|--------|-------|
| Upload size (1 min audio) | ~1.92 MB (WAV) | ~0.8-1.0 MB (FLAC) |
| Perceived latency | Full response wait (2-60s) | First token ~1-2s (still waits for completion) |
| API calls per transcription | 1 | 1 (unchanged) |
| Audio persistence overhead | Sequential (~100-200ms) | Parallel (~0ms on critical path) |
