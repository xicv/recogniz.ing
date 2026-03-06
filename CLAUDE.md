# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

- **Repository**: `xicv/recogniz.ing` (https://github.com/xicv/recogniz.ing)
- **Landing Page**: https://recogniz.ing/ (deployed via GitHub Pages)
- **Single Repository**: Both Flutter app and Vue 3 landing page are in the same repository
- **Project Root**: The Flutter project root IS the repository root — run Flutter commands from here, not a subdirectory

## Project Overview

AI-powered voice typing application built with Flutter. Supports desktop (macOS, Windows, Linux), iOS, and Android. Real-time voice activity detection, transcription via Google Gemini API, and customized output through user-defined vocabulary and prompts.

**Prerequisites**: Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey).

## Development Commands

### Quick Start
```bash
make get              # Install Flutter dependencies
make run-macos        # Run on macOS
make dev              # get + analyze + format + test
make quick-run        # get + clean build dir + run-macos
```

### Code Quality
```bash
make analyze          # flutter analyze
make format           # flutter format .
make test             # Run all tests
make test-coverage    # Run tests with coverage
make test-single TEST=test/widget_test.dart  # Run specific test
```

### Code Generation (required after model changes)
```bash
make generate         # build_runner with delete-conflicting-outputs
make generate-watch   # Watch mode for ongoing model development
```

### Version & Release
```bash
make version          # Show current version
make bump-patch-entry # Bump patch + add changelog entry template
make changelog        # Generate CHANGELOG.md from CHANGELOG.json
make verify-changelog # Verify changelogs are in sync
make release          # Bump patch, edit changelog, commit, tag, push
```

### Landing Page (in `landing/` directory)
```bash
cd landing && npm install && npm run dev   # Dev server
cd landing && npm run build                # Production build
```

## Architecture

### Clean Architecture Layers

```
lib/
├── core/                    # Business logic and infrastructure
│   ├── config/              # Type-safe configuration (app, prompt, theme, vocabulary)
│   ├── constants/           # App constants, UI constants, language list
│   ├── error/               # CategorizedErrorHandler, ErrorResult, error_provider
│   ├── interfaces/          # Service contracts (AudioServiceInterface, VadServiceInterface, etc.)
│   ├── models/              # Hive-serialized data models
│   ├── providers/           # Riverpod state management (organized by domain)
│   ├── services/            # Business logic implementations
│   ├── theme/               # Material Design 3 theming (AppTheme)
│   ├── use_cases/           # Complex workflows (VoiceRecordingUseCase)
│   └── utils/               # Audio utilities
├── features/                # Feature-based UI organization
│   ├── app_shell.dart       # Main container with drawer nav + keyboard shortcuts
│   ├── dashboard/           # Statistics, transcription history, API quota tracking
│   ├── dictionaries/        # Custom vocabulary management
│   ├── prompts/             # AI prompt template management
│   ├── recording/           # Voice recording UI with VAD overlay
│   ├── settings/            # API key management, preferences
│   └── transcriptions/      # Card-based display with hover effects, inline editing
├── widgets/                 # Reusable components
│   ├── navigation/          # navigation_drawer.dart
│   ├── recording/           # Recording-specific widgets
│   └── shared/              # app_bars, app_cards, etc.
└── main.dart                # App entry point, Hive init, service bootstrap
```

### Key Interfaces (`lib/core/interfaces/`)

All service contracts are defined here — import from these files for type references:

- **`audio_service_interface.dart`**: `AudioServiceInterface`, `TranscriptionServiceInterface`, `StorageServiceInterface`, `NotificationServiceInterface`, `RecordingResultInterface`
- **`vad_service_interface.dart`**: `VadServiceInterface`, `SpeechSegment`

### Models & Hive Type IDs

| Model | TypeId | File |
|-------|--------|------|
| `Transcription` | 0 | `transcription.dart` |
| `CustomPrompt` | 1 | `custom_prompt.dart` |
| `VocabularySet` | 2 | `vocabulary.dart` |
| `AppSettings` | 3 | `app_settings.dart` |
| `AudioCompressionPreference` (enum) | 12 | `app_settings.dart` |
| `ApiKeyInfo` | 13 | `api_key_info.dart` |
| `ApiKeyUsageStats` | 15 | `api_key_usage_stats.dart` |
| `ApiKeyDailyUsage` | 16 | `api_key_usage_stats.dart` |

**New Hive type IDs must be unique** — check this table before adding models. Run `make generate` after any `@HiveType` changes.

### Provider Organization (`lib/core/providers/`)

Import from specific provider files, **not** the deprecated barrel export (`providers.dart`):

| File | Domain |
|------|--------|
| `app_providers.dart` | `currentPageProvider`, `recordingStateProvider`, navigation |
| `recording_providers.dart` | Recording state, `VoiceRecordingUseCase` provider |
| `settings_providers.dart` | `settingsProvider` |
| `transcription_providers.dart` | `transcriptionsProvider` |
| `prompt_providers.dart` | Prompt template state |
| `vocabulary_providers.dart` | Vocabulary set state |
| `api_keys_provider.dart` | Multi-key management, `ApiKeysNotifier` |
| `api_key_usage_provider.dart` | Per-key usage tracking |
| `accessibility_permission_providers.dart` | macOS accessibility permission state |
| `config_providers.dart` | Configuration providers |
| `loading_providers.dart` | Loading state |
| `ui_providers.dart` | Theme, drawer state |

### Services (`lib/core/services/`)

Key services beyond the obvious:

- **`GeminiService`**: Uses `googleai_dart` package (not deprecated `google_generative_ai`). Model: `gemini-3-flash-preview`. Has rate limit callbacks and multi-key failover support.
- **`SileroVadService`** / **`AmplitudeVadService`**: Two VAD implementations — ML-based (primary) and amplitude-based (fallback). Both implement `VadServiceInterface`.
- **`AudioProcessingService`**: Audio processing pipeline
- **`AudioStorageService`**: Audio file persistence for retry functionality
- **`AccessibilityPermissionService`**: macOS-specific accessibility permission prompting for global hotkeys

### State Management Pattern

Riverpod with interface-based dependency injection:
- `StateNotifierProvider` / `Notifier` for complex state
- `Provider` for services
- Providers injected into use cases, not directly into widgets

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
2. `AudioProcessor` validates speech content in background isolate (RMS-based)
3. Valid audio sent to `GeminiService` with user vocabulary/prompts
4. Result saved via `StorageService` and copied to clipboard if enabled
5. UI updates through Riverpod providers

### Navigation

- Collapsible left drawer with 5 pages: Transcriptions (0), Dashboard (1), Dictionaries (2), Prompts (3), Settings (4)
- `currentPageProvider` manages active page
- Keyboard shortcuts: Ctrl/Cmd+1-5 for navigation, Ctrl/Cmd+S to save edits
- Global recording hotkey: Cmd+Shift+Space (macOS) / Ctrl+Shift+Space (others)
- Implemented in `AppShell` using `CallbackShortcuts`

### Multi-API Key System

`AppSettings` supports both legacy single `geminiApiKey` field and new multi-key system via `apiKeys` list of `ApiKeyInfo`. Priority: selected key from multi-key → legacy single key. Keys have rate limit tracking with 24h cooldown and automatic failover.

## Common Pitfalls

- **Project Root**: Flutter commands run from repo root, not a subdirectory
- **Provider Naming**: Singular for services (`settingsProvider`), plural for state notifiers (`promptsProvider`)
- **Model Property Names**: `CustomPrompt.promptTemplate` (not `template`)
- **Navigation Indices**: Transcriptions=0, Dashboard=1, Dictionaries=2, Prompts=3, Settings=4
- **Static vs Async**: Use async interface methods in use cases, not static `StorageService` methods
- **Type Imports**: Import `RecordingResultInterface` from `audio_service_interface.dart`
- **AI Package**: Uses `googleai_dart` (not the deprecated `google_generative_ai`)
- **SDK Constraint**: `>=3.7.0 <4.0.0` (Flutter 3.38+)

## Changelog System

JSON-first: `CHANGELOG.json` is the source of truth, `CHANGELOG.md` is auto-generated.

```bash
make bump-patch-entry          # Bump version + add entry template
# Edit CHANGELOG.json with actual changes
make changelog                 # Generate CHANGELOG.md
make verify-changelog          # Verify sync
git add CHANGELOG.json CHANGELOG.md pubspec.yaml
git commit -m "chore: bump version to X.Y.Z and update changelog"
```

## Error Handling

- `CategorizedErrorHandler` in `lib/core/error/` — categorizes errors with recovery actions
- `ErrorResult` includes retry timing, action hints, and Lucide icon names
- Display via `lastErrorProvider` (in `error_provider.dart`) with SnackBar notifications

## Landing Page

Vue 3 + Vite + TailwindCSS in `landing/`, deployed via GitHub Pages at https://recogniz.ing/

- **Active workflow**: `.github/workflows/landing-deploy.yml` (triggered by pushes to `main` touching `landing/**`)
- **Release workflow**: `.github/workflows/release-matrix.yml` (builds all platforms on tag push)
- **Windows builds**: `.github/workflows/build-windows.yml` (sub-workflow)
- **`.nojekyll`** in `public/` is required for Vite builds on GitHub Pages
- Download URLs point to GitHub releases: `https://github.com/xicv/recogniz.ing/releases/download/v{VERSION}/recognizing-{VERSION}-{platform}.zip`

## Platform Considerations

- **Desktop-only**: Global hotkeys, system tray (`TrayService`), window management, `StartAtLoginService`, accessibility permissions
- **macOS-specific**: `AccessibilityPermissionService` for hotkey permissions, MethodChannel for window control (`com.recognizing.app/window`)
- **Mobile**: Permission handling for microphone access
- **Testing**: Primary test file is `test/widget_test.dart`. Use interfaces for mocking. Platform-specific code needs `kIsWeb` / `Platform.isX` conditionals.
