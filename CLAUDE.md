# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

- **Repository**: `xicv/recogniz.ing` (https://github.com/xicv/recogniz.ing)
- **Landing Page**: https://recogniz.ing/ (deployed via GitHub Pages)
- **Single Repository**: Both Flutter app and Vue 3 landing page are in the same repository
- **Project Root**: The Flutter project root IS the repository root (`/recogniz.ing/`), not a subdirectory. Run Flutter commands from the root.

## Project Overview

This is an AI-powered voice typing application built with Flutter, supporting desktop (macOS, Windows, Linux), iOS, and Android platforms. The app provides real-time voice activity detection, transcription using Google Gemini API, and customized output through user-defined vocabulary and prompts.

Core features:
- Voice recording with RMS-based amplitude validation
- AI-powered transcription using **Gemini 3.0 Flash** with customizable vocabulary and prompts
- Modern transcription cards with hover effects and keyboard shortcuts
- Dashboard with usage statistics and transcription history
- Global hotkey support (Cmd+Shift+Space / Ctrl+Shift+Space) and app navigation shortcuts (Cmd/Ctrl+1-5)
- System tray integration for desktop platforms
- Collapsible left drawer navigation with 5 pages: Transcriptions (0), Dashboard (1), Dictionaries (2), Prompts (3), Settings (4)
- Cross-platform support with Material Design 3

## Development Commands

The project includes a comprehensive Makefile with 40+ commands:

### Quick Start
```bash
make get              # Install Flutter dependencies
make run-macos        # Run on macOS
make dev              # get + analyze + format + test
make quick-run        # get + run-macos
```

### Version Management
```bash
make version          # Show current version
make sync-version     # Sync pubspec.yaml from CHANGELOG.json (SSOT)
make bump-patch        # 1.0.0 → 1.0.1
make bump-minor        # 1.0.0 → 1.1.0
make bump-major        # 1.0.0 → 2.0.0
make bump-patch-entry  # Bump patch + add changelog entry template
make bump-minor-entry  # Bump minor + add changelog entry template
make bump-major-entry  # Bump major + add changelog entry template
make release           # Bump patch + deploy all platforms
```

### Code Quality
```bash
make analyze          # flutter analyze
make format           # flutter format .
make test             # Run all tests
make test-coverage    # Run tests with coverage
make test-single TEST=test/widget_test.dart  # Run specific test
make test-watch       # Run tests in watch mode
```

### Changelog Management
```bash
make changelog        # Generate CHANGELOG.md from CHANGELOG.json
make verify-changelog # Verify changelogs are in sync
```

### Code Generation
```bash
make generate         # build_runner with delete-conflicting-outputs
make generate-watch   # Run code generator in watch mode (useful during model development)
# IMPORTANT: Run after modifying any model files with @HiveType annotations
```

### Build & Deploy
```bash
make build-macos      # Build macOS release
make deploy-all       # Build and deploy all platforms to landing page
```

## Project Architecture

### Clean Architecture Pattern

**Core Layer** (`lib/core/`)
- **Models**: Data structures with Hive serialization using unique @HiveType IDs
  - `Transcription`: Main transcription model with audio metadata
  - `AppSettings`: User preferences and API configuration
  - `CustomPrompt.promptTemplate`: AI prompt templates (property name is `promptTemplate`, not `template`)
  - `VocabularySet`: Custom word collections for transcription accuracy
- **Services**: Business logic implementing interfaces for testability
  - `AudioService`: Microphone recording with permission handling
  - `GeminiService`: Google Gemini API integration with retry logic (uses `gemini-3-flash-preview`)
  - `StreamingGeminiService`: Real-time streaming transcription support
  - `StorageService`: Centralized Hive database operations
  - `TrayService`: Desktop system tray integration
  - `HotkeyService`: Global hotkey management
  - `AudioAnalyzer`: RMS-based speech validation in isolates
  - `VADService`: Voice activity detection with configurable sensitivity
  - `AnalyticsService`: Usage tracking and statistics
  - `StartAtLoginService`: Desktop auto-start functionality
  - `AudioCompressionService`: Audio compression for storage/transmission
  - `VersionService`: App version information from package_info_plus
- **Use Cases**: Complex business workflows
  - `VoiceRecordingUseCase`: Coordinates recording → validation → transcription pipeline
- **Interfaces**: Service contracts defined in `audio_service_interface.dart`
  - `AudioServiceInterface`: Recording operations
  - `TranscriptionServiceInterface`: AI transcription (implemented by both GeminiService and StreamingGeminiService)
  - `StorageServiceInterface`: Data persistence (includes async methods)
  - `NotificationServiceInterface`: UI notifications
- **Providers**: Riverpod state management organized by domain
  - `app_providers.dart`: App-level providers (currentPage, navigation state)
  - `recording_providers.dart`: Recording state and use case providers
  - `streaming_providers.dart`: Streaming transcription state
  - `service_providers.dart`: All service instance providers
  - `config_providers.dart`: Configuration and settings providers
  - `settings_providers.dart`: Settings state providers
  - `transcription_providers.dart`: Transcription state providers
  - `prompt_providers.dart`: Prompt template providers
  - `vocabulary_providers.dart`: Vocabulary set providers
  - `ui_providers.dart`: UI state (theme, drawer state, etc.)
  - `loading_providers.dart`: Loading state providers
  - Import from specific provider files, not the deprecated barrel export (`providers.dart`)

**Features Layer** (`lib/features/`)
- **app_shell.dart** (single file): Main container with collapsible drawer navigation and keyboard shortcuts
- **dashboard/**: Statistics and transcription history
- **transcriptions/**: Modern card-based display with hover effects and inline editing
- **settings/**: API key management, vocabulary/prompts configuration
- **dictionaries/**: Custom vocabulary management
- **prompts/**: AI prompt template management
- **recording/**: Voice recording UI with VAD overlay

**Navigation Architecture**
- Collapsible left drawer replacing bottom tabs (since v1.0.2)
- `currentPageProvider` manages active page (0-4)
- Keyboard shortcuts: Ctrl/Cmd+1-5 for navigation, Ctrl/Cmd+S to save edits

### State Management
- Riverpod with interface-based dependency injection
- `StateNotifierProvider` for complex state, `Provider` for services
- Providers injected into use cases, not directly into widgets
- Example pattern:
```dart
final voiceRecordingUseCaseProvider = Provider<VoiceRecordingUseCase>((ref) {
  return VoiceRecordingUseCase(
    audioService: ref.watch(audioServiceProvider),
    transcriptionService: ref.watch(transcriptionServiceProvider),
    // ... other dependencies
  );
});
```

### Data Flow
1. Recording triggered → `AudioService` captures audio
2. `AudioAnalyzer` validates speech content in background isolate (RMS-based)
3. Valid audio sent to `GeminiService` (or `StreamingGeminiService` for real-time) with user vocabulary/prompts
4. Result saved via `StorageService` and copied to clipboard if enabled
5. UI updates through Riverpod providers with error handling

## Important Implementation Details

### Hive Integration
- All models require `@HiveType` annotations with unique IDs (0-100 range)
- Run `make generate` after model changes
- Boxes initialized in `StorageService.initialize()`

### Keyboard Shortcuts
- Global recording: Cmd+Shift+Space (macOS), Ctrl+Shift+Space (others)
- Navigation: Ctrl/Cmd+1-5 for drawer items
- Save editing: Ctrl/Cmd+S
- Implemented in `AppShell` using `CallbackShortcuts`

### Error Handling
- Centralized through `EnhancedErrorHandler` in `lib/core/error/`
- Error metadata includes retry timing, action hints, and severity
- Display via `lastErrorProvider` with SnackBar notifications

### Platform Considerations
- Desktop-only features: Global hotkeys, system tray, window management
- Mobile: Permission handling for microphone access
- Web: Limited functionality due to browser audio restrictions

### Flutter Version Requirements
- SDK: '>=3.3.0 <4.0.0' (supports Flutter 3.24+)
- Critical dependency override: `win32: ^5.15.0` for Flutter 3.24+ compatibility

### Testing
- Primary test file: `test/widget_test.dart`
- Use interfaces for mocking services
- Test Hive with `Hive.initFlutter(null)` for in-memory databases
- Platform-specific code requires conditional testing with `kIsWeb` or `Platform.isX`

### UI Components
- Modern transcription cards in `TranscriptionCard` widget with hover animations
- Shared widgets in `lib/widgets/shared/` (app_bars.dart, app_cards.dart, etc.)
- Navigation widgets in `lib/widgets/navigation/` (navigation_drawer.dart)
- Design tokens in `UIConstants` class for consistent spacing/sizing
- Material Design 3 with dynamic theming

## Changelog Management

The project uses a **JSON-first changelog system** where `CHANGELOG.json` is the authoritative source and `CHANGELOG.md` is auto-generated.

### Workflow

```bash
# 1. Bump version and add entry template
make bump-patch-entry  # or bump-minor-entry, bump-major-entry

# 2. Edit CHANGELOG.json with actual changes
#    - Update highlights
#    - Add/modify change entries (categories: added, changed, fixed, removed, security)

# 3. Generate Markdown from JSON
make changelog

# 4. Verify both files are in sync
make verify-changelog

# 5. Commit both files together
git add CHANGELOG.json CHANGELOG.md pubspec.yaml
git commit -m "chore: bump version to X.Y.Z and update changelog"
```

### Version Manager Script

```bash
dart scripts/version_manager.dart --help              # Show all options
dart scripts/version_manager.dart --current           # Show current version
dart scripts/version_manager.dart --changelog         # Generate CHANGELOG.md
dart scripts/version_manager.dart --verify-changelog  # Check if files are in sync
dart scripts/version_manager.dart --bump patch --add-entry  # Bump + add template
```

### Why JSON as Source of Truth?

1. **Programmatic Access**: JSON is easier to parse and render in UI components
2. **Validation**: Schema can be validated, reducing errors
3. **Automation**: CI/CD can easily read and process changelog data
4. **Single Source**: Edit one file, generate the other automatically

## Recent Major Changes (v1.0.4+)

1. **App Logo Redesign (v1.11.0)**: Complete branding overhaul with bold geometric 'R' on blue-teal-emerald gradient, red recording dot positioned at end of R's right leg
2. **Transcription Status Tracking (v1.10.0)**: Added lifecycle states (pending, processing, completed, failed), audio backup for retry functionality, enhanced error tracking with retry count and completion timestamps
3. **Changelog System**: JSON-first changelog with `CHANGELOG.json` as source of truth, `CHANGELOG.md` auto-generated
4. **Navigation Architecture**: Moved from bottom tabs to collapsible left drawer
5. **UI Enhancements**: Modern transcription cards with hover effects and keyboard shortcuts
6. **Gemini Model**: Updated to `gemini-3-flash-preview` for improved transcription
7. **Architecture Fixes**:
   - Removed duplicate app shell implementations
   - Fixed VoiceRecordingUseCase tight coupling by using async interface methods
   - Updated StorageServiceInterface to include `getPrompt()` and `getVocabulary()`
8. **Keyboard Navigation**: Added shortcuts for all main pages (Ctrl/Cmd+1-5)
9. **Type Safety**: Fixed RecordingResult type usage (use RecordingResultInterface)

## Common Pitfalls

- **Project Root**: Flutter commands run from the repository root (`/recogniz.ing/`), not from a subdirectory. The `lib/`, `android/`, `ios/`, etc. folders are at the root level.
- **Provider Naming**: Use singular for services (`settingsProvider`), plural for state notifiers (`promptsProvider`)
- **Model Property Names**: `CustomPrompt.promptTemplate` (not `template`)
- **Navigation Indices**: Settings is index 4 in 5-page navigation
- **Hive Type IDs**: Must be unique across all models (check existing IDs before adding new)
- **Static vs Async**: Use async interface methods in use cases, not static StorageService methods
- **Type Imports**: Import from `audio_service_interface.dart` for all service interfaces

## Landing Page Deployment

The repository includes a Vue 3 + Vite + TailwindCSS landing page in the `landing/` folder, deployed to GitHub Pages at https://recogniz.ing/

### Architecture

```
xicv/recogniz.ing (Single Repository)
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates releases
│   ├── release.yml                 # Alternative release workflow
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
└── landing/                        # Vue 3 + Vite + TailwindCSS landing page
    ├── src/
    ├── public/downloads/           # App download artifacts (Git LFS)
    │   └── manifest.json           # Version manifest for downloads
    ├── public/.nojekyll            # Required for GitHub Pages + Vite
    └── package.json
```

**Tech Stack**: Vue 3, Vite 6, TailwindCSS, TypeScript, PWA (vite-plugin-pwa)

### Automated Deployment Flow

1. **Tag Push**: Push a version tag (`v1.0.4`) → triggers release workflow
2. **Build & Release**: GitHub Actions builds all platforms, creates GitHub Release
3. **Update Downloads**: Workflow commits artifacts to `landing/public/downloads/[version]/` and updates `manifest.json`
4. **Deploy Landing**: Commit triggers `landing-deploy.yml` → builds and deploys to GitHub Pages

### Landing Page Development

```bash
cd landing

# Install dependencies
npm install

# Start dev server (Vite)
npm run dev

# Build for production
npm run build
```

### Download Links Configuration

Download URLs in `landing/src/views/DownloadsView.vue` point to GitHub releases:
```
https://github.com/xicv/recogniz.ing/releases/download/v{VERSION}/recognizing-{VERSION}-{platform}.zip
```

Update this file when adding new versions or platforms.

### GitHub Pages Settings

- Source: **GitHub Actions** (not Deploy from a branch)
- Custom domain: `recogniz.ing`
- Workflow: `.github/workflows/landing-deploy.yml`
- Trigger: Push to `main` with changes to `landing/**` files
- **Important**: `.nojekyll` file in `public/` prevents GitHub Pages from ignoring underscore-prefixed files (required for Vite builds)