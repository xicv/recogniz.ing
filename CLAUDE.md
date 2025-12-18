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

The project includes a comprehensive Makefile with 35+ commands for streamlined development.

### Quick Start
```bash
# Install dependencies
make get              # or flutter pub get

# Run on specific platforms
make run-macos        # macOS (recommended)
make run-ios          # iOS Simulator
make run-android      # Android
make run-web          # Web (limited functionality)
make run-windows      # Windows
make run-linux        # Linux

# Full development workflow
make dev              # get + analyze + format + test

# Quick macOS development
make quick-run        # get + run-macos
```

### Build Commands
```bash
# Build for release (defaults to macOS)
make build            # Build for macOS
make build-macos      # macOS release
make build-ios        # iOS release
make build-apk        # Android APK
make build-aab        # Android App Bundle
make build-web        # Web release
make build-windows    # Windows release
make build-linux      # Linux release

# Install macOS release locally
make install-release
```

### Code Quality
```bash
make analyze          # flutter analyze
make format           # flutter format .
make test             # Run all tests
make test-coverage    # Run tests with coverage report
make test-single TEST=test/widget_test.dart  # Run specific test
make test-watch       # Run tests in watch mode
```

### Code Generation
```bash
# Generate Hive adapters and Riverpod generators
make generate         # build_runner with delete-conflicting-outputs
make generate-watch   # Watch mode for development

# IMPORTANT: Run make generate after modifying any model files
```

### Utilities
```bash
make clean            # Clean build artifacts
make clean-all        # Deep clean including generated files
make upgrade          # Upgrade dependencies
make deps-tree        # Show dependency tree
make debug            # Show Flutter doctor and devices
make logs             # Follow Flutter logs
make check-version    # Check Flutter and app versions
make help             # Show all available commands
```

### Manual Flutter Commands (if Makefile unavailable)
```bash
flutter pub get
flutter run -d macos
flutter build macos --release
flutter analyze
flutter test
flutter format .
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

4. **Configuration System** (`config/`)
   - External JSON configuration for themes, prompts, vocabulary, and app settings
   - Runtime loading of configurations without code changes
   - Type-safe config classes in `lib/core/config/`

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

**AudioAnalyzer** (`lib/core/services/audio_analyzer.dart`):
- RMS-based amplitude detection for speech validation
- Pre-validation of audio to filter non-speech content
- Configurable sensitivity thresholds for voice activity detection

### State Management Pattern
- Uses Riverpod with `StateNotifierProvider` for complex state
- `Provider` for services and derived state
- `StateProvider` for simple UI state
- Providers are organized by feature and imported centrally:
  - `lib/core/providers/core_providers.dart` - Global app providers
  - `lib/features/providers/` - Feature-specific providers
  - `lib/features/app_shell.dart` - Main provider aggregation

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

### Key Dependencies
- **flutter_riverpod**: State management with code-generation support
- **hive_flutter**: Local persistence with type adapters
- **record**: Audio recording with permission handling
- **google_generative_ai**: Gemini API integration
- **hotkey_manager**: Global hotkey support (desktop only)
- **tray_manager**: System tray integration (desktop only)
- **super_clipboard**: Enhanced clipboard operations
- **flutter_animate**: UI animations and transitions

## Platform-Specific Notes

### Web Platform Limitations
- Browser audio recording restrictions limit functionality
- No system tray or global hotkey support
- Reduced performance compared to native builds

### Desktop Features
- Global hotkeys:
  - macOS: Cmd+Shift+Space
  - Windows/Linux: Ctrl+Shift+Space
- System tray integration with recording state indicators
- Method channels for window management (macOS show/hide)

### Mobile Considerations
- Permission handling for microphone access
- No global hotkey support on mobile platforms
- Background recording limitations on iOS

## Configuration System

The app uses external JSON configurations for easy customization:

```bash
config/
├── themes/           # Dark/light theme configurations
├── prompts/          # Pre-configured AI prompt templates
├── vocabulary/       # Industry-specific vocabulary sets
└── app_config.json   # Global app settings
```

Edit JSON files directly to customize without code changes. Configurations are loaded at runtime.