# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered voice typing application built with Flutter, supporting desktop (macOS, Windows, Linux), iOS, and Android platforms. The app provides real-time voice activity detection, transcription using AI service providers (like Gemini API), and customized output through user-defined vocabulary and prompts.

Core features:
- Voice recording with activity detection
- AI-powered transcription with customizable vocabulary
- Custom prompt management for tailored output
- Dashboard with usage statistics and transcription history
- Global hotkey support for quick activation
- System tray integration for desktop platforms
- Cross-platform support with Material Design 3

## Development Commands

### Flutter Basics
```bash
# Install dependencies
flutter pub get

# Run the app (development)
flutter run

# Run on specific platforms
flutter run -d macos
flutter run -d ios
flutter run -d android
flutter run -d windows
flutter run -d linux
flutter run -d web

# Build for release
flutter build macos
flutter build ios
flutter build apk
flutter build windows
flutter build linux
flutter build web
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Format code
flutter format .

# Upgrade dependencies
flutter pub upgrade

# Generate Hive type adapters (when model files change)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Project Architecture

### Core Architecture
The app follows a layered architecture with clear separation of concerns:

1. **Core Layer** (`lib/core/`)
   - **Models**: Data structures with Hive serialization (`Transcription`, `AppSettings`, `CustomPrompt`, `VocabularySet`)
   - **Services**: Business logic and external integrations (`AudioService`, `GeminiService`, `StorageService`, `TrayService`, `HotkeyService`)
   - **Providers**: Riverpod state management for global application state
   - **Theme**: Material Design 3 theming system

2. **Features Layer** (`lib/features/`)
   - **Dashboard**: Statistics display, transcription history, and search functionality
   - **Settings**: API key management, vocabulary/prompts configuration, hotkey setup
   - **Recording**: Recording overlay and voice activity detection UI

3. **Data Flow**
   - State management uses Riverpod with providers for services, settings, and UI state
   - Hive for local persistence with type adapters for models
   - Global providers handle cross-feature state like recording state and navigation

### Key Services Integration

**AudioService** (`lib/core/services/audio_service.dart`):
- Manages voice recording using the `record` package
- Handles microphone permissions and recording lifecycle
- Returns audio data as bytes for AI processing

**GeminiService** (`lib/core/services/gemini_service.dart`):
- Integrates with Google Gemini API for transcription
- Applies custom vocabulary and prompt templates
- Manages API initialization and token usage tracking

**StorageService** (`lib/core/services/storage_service.dart`):
- Centralized Hive database operations
- Manages settings, transcriptions, prompts, and vocabulary
- Provides default data initialization

**TrayService** (`lib/core/services/tray_service.dart`):
- Desktop system tray integration with customizable actions
- Updates tray icon based on recording state
- Handles global hotkey-triggered recording

### State Management Pattern
- Uses Riverpod with `StateNotifierProvider` for complex state
- `Provider` for services and derived state
- `StateProvider` for simple UI state
- Providers are organized by feature and imported centrally in `app_providers.dart`

### Platform-Specific Features
- Global hotkeys only work on desktop platforms
- System tray integration for macOS/Windows/Linux
- Platform-specific permission handling for microphone access
- Method channels for window management (macOS show/hide)

## Important Development Notes

### Hive Integration
- All models use `@HiveType` annotations with unique type IDs
- Run `build_runner` after modifying model classes
- Hive boxes are initialized in `StorageService.initialize()`

### Recording Flow
1. User triggers recording via FAB or global hotkey
2. `AudioService` handles microphone permissions and recording
3. On stop, audio is sent to `GeminiService` with user's vocabulary/prompts
4. Result is saved via `StorageService` and optionally copied to clipboard
5. UI updates through state providers with success/error notifications

### Error Handling
- Errors are displayed through `lastErrorProvider` with SnackBar notifications
- Service-level errors are logged to console for debugging
- Recording gracefully handles permission denial and API failures

### Testing Considerations
- Mock services for unit tests (AudioService, GeminiService)
- Test Hive operations with in-memory databases
- Platform-specific features need conditional testing or mocks