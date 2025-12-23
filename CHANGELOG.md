# Changelog

All notable changes to Recogniz.ing will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.4] - 2025-12-23

### Added

- **Changelog System** - New structured changelog with JSON format for landing page display and Markdown for GitHub. Includes beautiful Vue component with filtering and search.
- **Deployment Architecture** - Simplified single-repository deployment using GitHub Actions. Release workflow automatically commits downloads to landing folder and triggers GitHub Pages deployment.

### Changed

- **Repository Structure** - Consolidated to `xicv/recogniz.ing` as the single source of truth. Both Flutter app and Vue landing page now in one repository.
- **Documentation** - Updated README.md files with latest deployment architecture, added CLAUDE.md section for landing page deployment.

### Removed

- Outdated `DEPLOYMENT.md` file (information now in `landing/DEPLOYMENT.md`)
- Flutter-generated `recognizing/README.md` (duplicate of main README)

---

## [1.0.3] - 2025-12-21

### Fixed

- **macOS Gatekeeper** - Fixed macOS Gatekeeper verification issues with improved app signing and notarization.
- **Build System** - Fixed `make quick-run` command to properly clean build directory and prevent code signing errors.

### Added

- **Windows Release** - Initial Windows release with native installer support. Download as `recognizing-{version}-windows.zip`

### Changed

- **Platform Icons** - Updated landing page platform icons: iMac for macOS, Apple logo for iOS for better visual representation.
- **Performance** - Enhanced stability and performance improvements across all platforms.

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

## [1.0.0] - 2024-11-01

### Added

- **Voice Recording** - Smart voice activity detection (VAD) with configurable sensitivity and RMS-based audio analysis.
- **AI Transcription** - Powered by Google Gemini 1.5 Flash with intelligent noise filtering and silence detection.
- **Custom Prompts** - 6 pre-configured prompts (Clean, Formal, Bullets, Email, Meeting Notes, Social Media) with custom prompt creation.
- **Vocabulary Sets** - 6 industry vocabulary sets (General, Technology, Business, Medical, Legal, Finance).
- **Dashboard** - Real-time transcription history with search, usage statistics, and inline editing.
- **Global Hotkeys** - Desktop global hotkey support (Cmd+Shift+Space / Ctrl+Shift+Space) with system tray integration.
- **Themes** - Material Design 3 UI with dark/light theme support and system preference detection.
- **Cross-Platform** - Support for macOS, Windows, Linux, iOS, Android, and Web.
