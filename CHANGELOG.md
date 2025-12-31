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

