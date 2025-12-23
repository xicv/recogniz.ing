# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

- **Repository**: `xicv/recogniz.ing` (https://github.com/xicv/recogniz.ing)
- **Landing Page**: https://recogniz.ing/ (deployed via GitHub Pages)
- **Single Repository**: Both Flutter app and Vue 3 landing page are in the same repository

## Project Overview

This is an AI-powered voice typing application built with Flutter, supporting desktop (macOS, Windows, Linux), iOS, and Android platforms. The app provides real-time voice activity detection, transcription using Google Gemini API, and customized output through user-defined vocabulary and prompts.

Core features:
- Voice recording with RMS-based amplitude validation
- AI-powered transcription with customizable vocabulary and prompts
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
make bump-patch        # 1.0.0 → 1.0.1
make bump-minor        # 1.0.0 → 1.1.0
make bump-major        # 1.0.0 → 2.0.0
make release           # Bump patch + deploy all platforms
```

### Code Quality
```bash
make analyze          # flutter analyze
make format           # flutter format .
make test             # Run all tests
make test-coverage    # Run tests with coverage
make test-single TEST=test/widget_test.dart  # Run specific test
```

### Code Generation
```bash
make generate         # build_runner with delete-conflicting-outputs
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
  - `GeminiService`: Google Gemini API integration with retry logic
  - `StorageService`: Centralized Hive database operations
  - `TrayService`: Desktop system tray integration
  - `HotkeyService`: Global hotkey management
  - `AudioAnalyzer`: RMS-based speech validation in isolates
- **Use Cases**: Complex business workflows
  - `VoiceRecordingUseCase`: Coordinates recording → validation → transcription pipeline
- **Interfaces**: Service contracts defined in `audio_service_interface.dart`
  - `AudioServiceInterface`: Recording operations
  - `TranscriptionServiceInterface`: AI transcription
  - `StorageServiceInterface`: Data persistence (includes async methods)
  - `NotificationServiceInterface`: UI notifications
- **Providers**: Riverpod state management organized by domain
  - `recording_providers.dart`: Recording state and use case providers
  - Import from specific provider files, not the deprecated barrel export

**Features Layer** (`lib/features/`)
- **AppShell**: Main container with collapsible drawer navigation and keyboard shortcuts
- **Transcriptions**: Modern card-based display with hover effects and inline editing
- **Dashboard**: Statistics and transcription history
- **Settings**: API key management, vocabulary/prompts configuration
- **Dictionaries**: Custom vocabulary management
- **Prompts**: AI prompt template management

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
2. `AudioAnalyzer` validates speech content in background isolate
3. Valid audio sent to `GeminiService` with user vocabulary/prompts
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
- SDK: '>=3.3.0 <4.0.0' (supports Flutter 3.38+)
- Critical dependency override: `win32: ^5.15.0` for Flutter 3.24+ compatibility

### Testing
- Primary test file: `test/widget_test.dart`
- Use interfaces for mocking services
- Test Hive with `Hive.initFlutter(null)` for in-memory databases
- Platform-specific code requires conditional testing with `kIsWeb` or `Platform.isX`

### UI Components
- Modern transcription cards in `TranscriptionCard` widget with hover animations
- Shared widgets in `lib/widgets/shared/` (app_bars.dart, app_cards.dart, etc.)
- Design tokens in `UIConstants` class for consistent spacing/sizing
- Material Design 3 with dynamic theming

## Recent Major Changes (v1.0.2+)

1. **Navigation Architecture**: Moved from bottom tabs to collapsible left drawer
2. **UI Enhancements**: Modern transcription cards with hover effects and keyboard shortcuts
3. **Architecture Fixes**:
   - Removed duplicate app shell implementations
   - Fixed VoiceRecordingUseCase tight coupling by using async interface methods
   - Updated StorageServiceInterface to include `getPrompt()` and `getVocabulary()`
4. **Keyboard Navigation**: Added shortcuts for all main pages (Ctrl/Cmd+1-5)
5. **Type Safety**: Fixed RecordingResult type usage (use RecordingResultInterface)

## Common Pitfalls

- **Provider Naming**: Use singular for services (`settingsProvider`), plural for state notifiers (`promptsProvider`)
- **Model Property Names**: `CustomPrompt.promptTemplate` (not `template`)
- **Navigation Indices**: Settings is index 4 in 5-page navigation
- **Hive Type IDs**: Must be unique across all models (check existing IDs before adding new)
- **Static vs Async**: Use async interface methods in use cases, not static StorageService methods
- **Type Imports**: Import from `audio_service_interface.dart` for all service interfaces

## Landing Page Deployment

The repository includes a Vue 3 + Vite landing page in the `landing/` folder, deployed to GitHub Pages at https://recogniz.ing/

### Architecture

```
xicv/recogniz.ing (Single Repository)
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates releases
│   ├── release.yml                 # Alternative release workflow
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
└── landing/                        # Vue 3 + Vite landing page
    ├── src/
    ├── public/downloads/           # App download artifacts (Git LFS)
    │   └── manifest.json           # Version manifest for downloads
    └── package.json
```

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