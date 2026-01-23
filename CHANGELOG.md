# Recogniz.ing Changelog

AI-powered voice typing with real-time transcription powered by Google's Gemini AI.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2024-11-01

### Added

- **Voice Recording** - Smart voice activity detection (VAD) with configurable sensitivity and RMS-based audio analysis.
- **AI Transcription** - Powered by Google Gemini 3.0 Flash with intelligent noise filtering and silence detection.
- **Custom Prompts** - 6 pre-configured prompts (Clean, Formal, Bullets, Email, Meeting Notes, Social Media) with custom prompt creation.
- **Vocabulary Sets** - 6 industry vocabulary sets (General, Technology, Business, Medical, Legal, Finance).
- **Dashboard** - Real-time transcription history with search, usage statistics, and inline editing.
- **Global Hotkeys** - Desktop global hotkey support (Cmd+Shift+Space / Ctrl+Shift+Space) with system tray integration.
- **Themes** - Material Design 3 UI with dark/light theme support and system preference detection.

---

## [1.0.2] - 2024-12-15

### Added

- **Version Management** - Comprehensive semantic versioning system with automated tools (Dart script, shell script, Makefile targets).
- **Keyboard Shortcuts** - Added Cmd/Ctrl+S keyboard shortcut for saving edited transcriptions.
- **Deployment System** - Automated build and deployment pipeline for all platforms to landing page.
- **Code Signing** - macOS code signing and notarization support for distribution.
- **Landing Page** - New landing page with download management system and version tracking.

### Fixed

- **Settings Navigation** - Fixed menu bar Settings navigation to open correct Settings tab.

---

## [1.0.3] - 2025-12-21

### Added

- **Windows Release** - Initial Windows release with native installer support. Download as recognizing-{version}-windows.zip

### Changed

- **Platform Icons** - Updated landing page platform icons - iMac for macOS, Apple logo for iOS for better visual representation.
- **Performance** - Enhanced stability and performance improvements across all platforms.

### Fixed

- **macOS Gatekeeper** - Fixed macOS Gatekeeper verification issues with improved app signing and notarization.
- **Build System** - Fixed make quick-run command to properly clean build directory and prevent code signing errors.

---

## [1.0.4] - 2025-12-23

### Added

- **Changelog System** - New structured changelog with JSON format for landing page display and Markdown for GitHub. Includes beautiful Vue component with filtering and search.
- **Deployment Architecture** - Simplified single-repository deployment using GitHub Actions. Release workflow automatically commits downloads to landing folder and triggers GitHub Pages deployment.

### Changed

- **Repository Structure** - Consolidated to xicv/recogniz.ing as the single source of truth. Both Flutter app and Vue landing page now in one repository.
- **Documentation** - Updated README.md files with latest deployment architecture, added CLAUDE.md section for landing page deployment.

### Removed

- **Outdated Files** - Removed outdated DEPLOYMENT.md and Flutter-generated recognizing/README.md files.

---

## [1.0.5] - 2025-12-29

### Added

- **Favorites Filter** - New filter option to quickly access starred transcriptions. Toggle between All and Favorites with a single click in the transcriptions view.

### Changed

- **VAD Overlay UI** - Improved VAD recording overlay with static processing indicator (no flashing animations). Removed 'Speech Detection' and 'Audio Quality' status labels for cleaner interface.

### Fixed

- **Code Quality** - Fixed all static analysis warnings. Zero errors, zero warnings across entire codebase. Removed unused imports and variables.
- **Hive Schema** - Fixed Hive schema compatibility by making isFavorite field nullable for backward compatibility with existing user data.

### Removed

- **Auto-Stop After Silence** - Removed auto-stop after silence feature for simplified manual recording control. Users now have full control over when to stop recording.

---

## [1.0.8] - 2025-12-29

### Added

- **Platform Releases** - macOS and Windows installers now available for download.

### Fixed

- **CI/CD Fix** - Fixed detached HEAD error when pushing landing downloads to repository.

---

## [1.0.9] - 2025-12-31

### Changed

- **App Logo Redesign** - Complete logo redesign featuring vertical sound-wave bars that transform into horizontal text lines. Uses brand color progression (cyan → indigo → emerald) to visually represent the transcription flow.
- **Platform Icons** - Updated all platform icons (Android, iOS, macOS, Windows, Web) and landing page favicons with the new modern design.

---

## [1.10.0] - 2025-12-31

### Added

- **Transcription Status Tracking** - Added TranscriptionStatus enum with states: pending, processing, completed, failed. Each transcription now tracks its lifecycle from initial recording through API processing to final result.
- **Audio Backup for Retry** - Original audio files are now backed up to local storage, enabling retry functionality for failed transcriptions without requiring users to re-record.
- **Error Tracking** - Added errorMessage field and retryCount to track transcription failures and retry attempts.
- **Completion Timestamp** - Added completedAt field to track when transcription processing finished, enabling better analytics and user insights.

---

## [1.11.0] - 2025-12-31

### Changed

- **App Logo Redesign** - Complete logo redesign featuring a bold geometric 'R' letter in white on a blue-to-teal-to-emerald gradient background. The red recording dot is positioned at the end of the R's right leg, creating a clear visual metaphor for the app's voice recording functionality.
- **Color Scheme Update** - Updated from cyan-indigo-emerald to a more professional deep blue (#1E40AF) → cyan/teal (#0891B2) → emerald (#10B981) gradient that conveys trust, reliability, and accuracy.
- **Platform Icons** - Regenerated all platform icons (Android, iOS, macOS, Windows, Web) and landing page assets with the new modern design following 2025 minimalist trends.

### Removed

- **Unused Logo Files** - Removed redundant assets/logo/ folder. Consolidated all icon assets to assets/icons/ as single source of truth.

---

## [1.12.0] - 2026-01-12

### Added

- **Multi-Language Transcription** - Added automatic language detection for transcriptions. The app now detects the language spoken automatically and transcribes in the original language without translation. Supports code-switching (e.g., mixed Chinese-English speech).
- **Language Selector** - Added transcription language selector in Settings with 20+ supported languages including English, Chinese, Japanese, Korean, Spanish, French, German, Italian, Portuguese, Russian, Arabic, Hindi, Thai, Vietnamese, Indonesian, Malay, Tagalog, Dutch, Polish, Turkish, and Ukrainian.
- **Detected Language Display** - Added detected language badge on transcription cards showing the language of each transcription. Displays native language names for better user recognition.
- **System Instructions** - Added system instruction support to GeminiService for consistent multi-language behavior across all API calls. Instructions now tell Gemini to NEVER translate and to preserve code-switching exactly as spoken.
- **Language Constants** - Added TranscriptionLanguages helper class with language code normalization for handling various locale code formats (e.g., zh-CN, zh-TW, en-US, en-GB).
- **Transcription Language Setting** - Added transcriptionLanguage field to AppSettings with auto-detect as default. Allows users to optionally specify a target output language.

### Changed

- **GeminiService Interface** - Updated TranscriptionServiceInterface to accept optional targetLanguage parameter for future translation capabilities.

### Fixed

- **Hive Backward Compatibility** - Added defaultValue to HiveField annotations for new fields to ensure backward compatibility with existing user data.

### Removed

- **About Section from Settings** - Removed the About section from Settings page for a cleaner, more focused UI.

---

## [1.12.1] - 2026-01-13

### Added

- **Automated Release Workflow** - The make release command now automatically commits changes, creates git tags, and pushes to trigger GitHub Actions builds. Run make release and the entire process is automated.
- **Landing Version Sync** - landing/package.json version is now automatically synchronized with pubspec.yaml during version bumps.
- **Release Notes from CHANGELOG.json** - GitHub Actions now generates release notes from CHANGELOG.json data, showing highlights and categorized changes instead of git log.

### Changed

- **Features Page** - Updated features page to highlight Multi-Language Transcription as a core feature with 20+ supported languages.

### Fixed

- **Changelog Version Order** - Fixed bug where new versions were appended to the end of the versions array instead of being inserted at the beginning. The landing changelog now correctly shows the newest version first.

### Removed

- **Duplicate Version Script** - Removed scripts/version-bump.sh as it duplicated functionality from version_manager.dart.

---

## [1.13.0] - 2026-01-15

### Added

- **Silero VAD Integration** - Integrated Silero VAD (ML-based voice activity detection) with ~95% accuracy for speech detection. Uses ONNX Runtime for native performance with FFI bindings to vad package v0.0.7.
- **Graceful VAD Fallback** - Implemented facade pattern with automatic fallback from Silero VAD to amplitude-based VAD (~75% accuracy) when ML model is unavailable. Ensures functionality across all platforms.
- **VadServiceInterface** - Created abstraction layer for VAD implementations enabling runtime switching between Silero and amplitude-based detection methods.

### Changed

- **Single-Call Transcription** - Eliminated two-call transcription pattern. Now uses single optimized API call combining all transcription requirements, reducing API calls by 50% and latency by ~50%.
- **Token-Efficient Prompts** - Condensed prompt templates from ~120 tokens to ~40 tokens, removing verbose instructions and redundant 'CLEAN VERSION:' markers across all 6 default prompts.
- **Cache Key Optimization** - Optimized cache key generation from O(n) full audio iteration to O(1) sampling using first/last 100 bytes. Dramatically improves performance for cached requests.
- **Audio Configuration** - Standardized audio encoding to 16kHz sample rate with AAC at 64kbps for optimal speech recognition quality and file size.
- **Audio MIME Type** - Fixed audio MIME type from audio/mp4 to audio/aac for better API compatibility.
- **Storage Pagination** - Optimized storage list operations using sublist instead of removeRange for O(1) pagination performance.
- **Documentation** - Updated README.md with VAD features, performance optimizations, and accurate technical specifications.

---

## [1.13.1] - 2026-01-15

### Added

- **Silero VAD Integration** - Integrated Silero VAD (ML-based voice activity detection) with ~95% accuracy for speech detection. Uses ONNX Runtime for native performance with FFI bindings to vad package v0.0.7.
- **Graceful VAD Fallback** - Implemented facade pattern with automatic fallback from Silero VAD to amplitude-based VAD (~75% accuracy) when ML model is unavailable. Ensures functionality across all platforms.
- **VadServiceInterface** - Created abstraction layer for VAD implementations enabling runtime switching between Silero and amplitude-based detection methods.

### Changed

- **Single-Call Transcription** - Eliminated two-call transcription pattern. Now uses single optimized API call combining all transcription requirements, reducing API calls by 50% and latency by ~50%.
- **Token-Efficient Prompts** - Condensed prompt templates from ~120 tokens to ~40 tokens, removing verbose instructions and redundant 'CLEAN VERSION:' markers across all 6 default prompts.
- **Cache Key Optimization** - Optimized cache key generation from O(n) full audio iteration to O(1) sampling using first/last 100 bytes. Dramatically improves performance for cached requests.
- **Audio Configuration** - Standardized audio encoding to 16kHz sample rate with AAC at 64kbps for optimal speech recognition quality and file size.
- **Audio MIME Type** - Fixed audio MIME type from audio/mp4 to audio/aac for better API compatibility.
- **Storage Pagination** - Optimized storage list operations using sublist instead of removeRange for O(1) pagination performance.
- **Documentation** - Updated README.md with VAD features, performance optimizations, and accurate technical specifications.

---

## [1.13.2] - 2026-01-16

### Changed

- **Notification Appearance** - Ensured all SnackBars use behavior: SnackBarBehavior.floating with consistent Dismiss button styling (white text color) across all pages.

### Fixed

- **SnackBar Duration and Action Consistency** - Standardized all SnackBar instances to use Duration(seconds: 4) with a Dismiss button for consistent auto-dismiss behavior. Notifications in transcriptions, dashboard, dictionaries, and prompts pages all follow the same pattern.
- **Path Package Dependency** - Fixed path package indentation in pubspec.yaml dev_dependencies to resolve CI workflow failures.

---

## [1.14.0] - 2026-01-21

### Added

- **PCM Audio Format Support** - Added support for uncompressed PCM (16-bit) audio recording format. This eliminates AAC encoder buffering issues that caused audio truncation at the end of recordings. Results in 4x larger files (3.36 MB/min vs 840 KB/min) but guarantees all audio is captured.
- **Audio Diagnostic Service** - New AudioDiagnosticService detects audio truncation by comparing timer duration with actual file duration. Provides quick file-size-based checks and full audio-duration-based diagnostics with detailed assessment messages.
- **Reliable Recording Mode** - Added useReliableFormat flag to AudioCompressionService. When enabled (default), uses uncompressed PCM format for maximum reliability. Can be toggled for compressed AAC format when file size is more important than complete audio capture.

### Changed

- **Gemini SDK Migration** - Migrated from deprecated google_generative_ai package to googleai_dart v2.1.0. The new SDK provides better type safety, improved error handling, and active maintenance.
- **Audio Format Handling** - Enhanced audio service to properly handle both compressed AAC/M4A and uncompressed WAV/PCM formats. Each format path optimized for its specific characteristics.
- **Dependency Updates** - Updated dependencies: flutter_riverpod 3.2.0, path_provider 2.1.5, google_fonts 6.3.0, infinite_scroll_pagination 4.1.0, build_runner 2.4.13. Added just_audio 0.9.46 for audio duration verification.

---

## [1.15.0] - 2026-01-21

### Added

- **Smart Audio Format Selection** - Added intelligent audio format selection based on recording duration and user preference. Auto mode uses AAC for short recordings (< 2 min), AAC with warning for medium recordings (2-5 min), and PCM for long recordings (5+ min).
- **Audio Compression Preference Setting** - Added AudioCompressionPreference enum with three options: Auto (smart selection), Always Compressed (AAC only), and Uncompressed (PCM only). Preference stored in AppSettings with Hive persistence.
- **Audio Format Settings UI** - Added SegmentedButton UI in Settings page for audio format selection. Shows format descriptions: 'Smart format based on recording length' for Auto, 'Smaller files, may lose 0.5-2s at end' for Compact, and 'Larger files, no audio loss' for Full.

### Changed

- **AudioCompressionService Enhancement** - Added getConfigForPreference() method that returns RecordConfig with optional warning message. Duration-based thresholds: < 2 min = AAC (fast, small), 2-5 min = AAC with warning, 5+ min = PCM (reliable).

---

## [1.15.1] - 2026-01-21

### Added

- **Multi-API Key Management** - Added support for managing multiple Gemini API keys with add, edit, delete, and select functionality. Users can now add backup keys for automatic failover when hitting rate limits (HTTP 429).
- **Automatic Rate Limit Failover** - GeminiService now automatically switches to another available API key when receiving a 429 rate limit error. Tries up to 3 keys with exponential backoff before giving up.
- **Free Tier Quota Tracking** - Dashboard now shows free tier quota usage with a circular progress indicator. Displays percentage used, remaining requests, and status (Good, Near Limit, Exhausted).
- **Usage Projections** - Projects days until free tier exhaustion based on current daily usage. Helps users understand when they might need to upgrade or add more keys.
- **Per-Key Usage Statistics** - Track usage statistics per API key including transcriptions, words, duration, and daily averages. Data stored locally using Hive with DailyUsage model for 90-day history.
- **ApiKeyInfo Model** - New Hive model with typeId: 13 for storing API key metadata including id, name, masked key, creation timestamp, rate limit timestamp, and selected status.
- **ApiKeyUsageStats Model** - New Hive model with typeId: 16 for tracking per-key usage statistics. Includes total transcriptions, tokens, duration, words, first/last used timestamps, daily usage array, and total estimated cost.
- **DailyUsage Model** - Hive model with typeId: 15 for tracking daily usage breakdown with transcription count, tokens, duration minutes, words, and date.

### Changed

- **Dashboard Data Display** - Changed from showing dollar costs (confusing for free tier) to showing percentage of free tier quota used. Stats grid now shows 'Daily Average' transcriptions instead of duplicate 'Free Tier Today'.
- **Dashboard Spacing System** - Implemented DashboardSpacing constant class with 8-point grid values: 16px card padding, 20px horizontal margin, 24px vertical margin, 16px grid gap, 16px border radius, 40px icon containers.
- **AppSettings Multi-Key Support** - Extended AppSettings with apiKeys list (HiveField 14) and selectedApiKeyId (HiveField 15). Maintains backward compatibility with legacy geminiApiKey field.

---

## [1.15.2] - 2026-01-23

### Changed

- **macOS Entitlements** - Updated Release.entitlements and DebugProfile.entitlements with additional entitlements: com.apple.security.device.camera (required by AVFoundation), com.apple.security.cs.disable-library-validation (allows loading system Audio Units), and com.apple.security.app-sandbox set to false for direct distribution.

### Fixed

- **macOS Release Build Audio Recording** - Fixed audio recording failure in macOS release builds by disabling App Sandbox for direct GitHub distribution. The sandbox was blocking AVFoundation from loading system Audio Units required for audio encoding. This fix enables proper audio recording in release mode while maintaining compatibility with direct distribution (non-App Store).
- **App Quit Crash (Cmd+Q)** - Fixed 'quit unexpectedly' dialog when pressing Cmd+Q. Added proper app lifecycle handling with didChangeAppLifecycleState to ensure async resources (TrayService, HotkeyService) are properly disposed before app termination. Previously, async dispose methods were being called synchronously without waiting.

---

## [1.15.3] - 2026-01-23

### Changed

- **Reactive Gemini Service Initialization** - Made geminiServiceProvider reactive to API key changes by adding ref.listen() callbacks. The service now automatically reinitializes when: (1) the effective API key changes in settings, or (2) the selected API key changes in the multi-key system. This ensures transcription always uses the correct API key.

### Fixed

- **API Key State Refresh Race Condition** - Fixed a race condition where entering an API key for the first time wouldn't refresh the app state. The async _loadSettings() method was overwriting user changes before they were persisted. Added _hasPendingUserUpdate flag to SettingsNotifier to prevent overwrites during user actions.
- **Multi-API Keys State Synchronization** - Fixed create/update/delete/select API key operations not triggering app state changes. Applied the same race condition protection to ApiKeysNotifier, ensuring all CRUD operations properly refresh the UI and reinitialize the Gemini service when needed.

---

