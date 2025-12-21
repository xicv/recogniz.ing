# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered voice typing application built with Flutter, supporting desktop (macOS, Windows, Linux), iOS, and Android platforms. The app provides real-time voice activity detection, transcription using AI service providers (like Gemini API), and customized output through user-defined vocabulary and prompts.

Core features:
- Voice recording with activity detection
- AI-powered transcription with customizable vocabulary
- Custom prompt management for tailored output
- Dashboard with usage statistics and transcription history
- Global hotkey support for quick activation (Cmd+Shift+Space / Ctrl+Shift+Space)
- System tray integration for desktop platforms
- Cross-platform support with Material Design 3

## Development Commands

The project includes a comprehensive Makefile with 40+ commands for streamlined development.

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

### Version Management
```bash
# Show current version
make version

# Bump semantic versions (automatically updates pubspec.yaml)
make bump-patch        # 1.0.0 → 1.0.1
make bump-minor        # 1.0.0 → 1.1.0
make bump-major        # 1.0.0 → 2.0.0
make bump-prerelease PRE=alpha  # 1.0.0 → 1.0.0-alpha

# Create complete release (bump patch + deploy)
make release
```

### Build & Deployment
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

# Deploy to landing page
make deploy-all       # Build and deploy all platforms
make deploy-macos     # Deploy macOS only
make deploy-windows   # Deploy Windows only
make deploy-linux     # Deploy Linux only
make deploy-android   # Deploy Android only
make deploy-web       # Deploy Web only

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

### Code Signing (macOS)
```bash
# Set up code signing configuration
make codesign-setup

# Build and sign macOS app
make sign-macos

# Build, sign, and notarize for distribution
make notarize-macos

# Create signed DMG for distribution
make distribute-macos
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

## Project Architecture

### Core Architecture
The app follows a Clean Architecture pattern with clear separation of concerns:

1. **Core Layer** (`lib/core/`)
   - **Models**: Data structures with Hive serialization (`Transcription`, `AppSettings`, `CustomPrompt`, `VocabularySet`)
   - **Services**: Business logic and external integrations (`AudioService`, `GeminiService`, `StorageService`, `TrayService`, `HotkeyService`, `VersionService`)
   - **Providers**: Riverpod state management organized by domain
   - **Interfaces**: Service interfaces for dependency injection and testing
   - **Use Cases**: Complex business logic orchestration (e.g., `VoiceRecordingUseCase`)
   - **Config**: Type-safe configuration classes loaded from external JSON
   - **Error**: Enhanced error handling system with categorization and metadata
   - **Constants**: App-wide constants and UI configuration

2. **Features Layer** (`lib/features/`)
   - **Dashboard**: Statistics display, transcription history, and search functionality
   - **Settings**: API key management, vocabulary/prompts configuration, hotkey setup
   - **Recording**: Recording overlay and voice activity detection UI
   - **Transcriptions**: Transcription management and editing

3. **Shared Widget Layer** (`lib/widgets/`)
   - **Shared Components**: Comprehensive reusable UI widgets for consistency
   - `app_bars.dart`, `app_buttons.dart`, `app_cards.dart`, `app_chips.dart`
   - `app_dialogs.dart`, `app_inputs.dart`, `app_lists.dart`
   - `loading_indicators.dart`, `global_loading_overlay.dart`
   - `widgets.dart` - Barrel export for easy imports

4. **Data Flow**
   - State management uses Riverpod with providers for services, settings, and UI state
   - Hive for local persistence with type adapters for models
   - Global providers handle cross-feature state like recording state and navigation
   - Use cases orchestrate complex workflows across multiple services

5. **Error Handling System** (`lib/core/error/`)
   - `AppException` base class for all custom exceptions
   - `ErrorHandler` service for centralized error processing
   - Categorized error types: `AudioError`, `ApiError`, `StorageError`, etc.
   - Error metadata includes retry timing, action hints, and severity levels
   - Global error state management through `errorProvider`

6. **Configuration System** (`config/`)
   - External JSON configuration for themes, prompts, vocabulary, and app settings
   - Runtime loading of configurations without code changes
   - Type-safe config classes in `lib/core/config/`

### Key Services Integration

**AudioService** (`lib/core/services/audio_service.dart`):
- Manages voice recording using the `record` package
- Handles microphone permissions and recording lifecycle
- Returns audio data as bytes for AI processing
- Pre-validates audio with RMS-based amplitude detection

**GeminiService** (`lib/core/services/gemini_service.dart`):
- Integrates with Google Gemini API for transcription
- Applies custom vocabulary and prompt templates
- Manages API initialization and token usage tracking
- Implements retry logic with exponential backoff

**StorageService** (`lib/core/services/storage_service.dart`):
- Centralized Hive database operations
- Manages settings, transcriptions, prompts, and vocabulary
- Provides default data initialization from JSON configs

**VersionService** (`lib/core/services/version_service.dart`):
- Handles semantic version parsing and management
- Provides dynamic version reading from package_info_plus
- Includes utilities for version comparison and manipulation

**AudioAnalyzer** (`lib/core/services/audio_analyzer.dart`):
- RMS-based amplitude detection for speech validation
- Pre-validation of audio to filter non-speech content
- Configurable sensitivity thresholds for voice activity detection
- Processes audio in isolates for smooth UI performance

### State Management Pattern
- Uses Riverpod with `StateNotifierProvider` for complex state
- `Provider` for services and derived state
- `StateProvider` for simple UI state
- Providers are organized by feature and imported centrally:
  - `lib/core/providers/core_providers.dart` - Global app providers
  - `lib/core/providers/app_providers.dart` - Application-wide state
  - Feature-specific providers:
    - `recording_providers.dart` - Voice recording state
    - `transcription_providers.dart` - Transcription management
    - `settings_providers.dart` - App settings and configuration
    - `vocabulary_providers.dart` - Custom vocabulary management
    - `prompt_providers.dart` - AI prompt templates
    - `ui_providers.dart` - UI state management
    - `loading_providers.dart` - Global loading indicators
  - `lib/features/app_shell.dart` - Main provider aggregation for features

### Interface-Based Design
Services implement interfaces for testability:
- `AudioService` implements `IAudioService`
- Enables easy mocking for unit tests
- Follows dependency injection pattern

### Use Case Pattern
Complex workflows are encapsulated in use cases in `lib/core/use_cases/`:
- `VoiceRecordingUseCase` coordinates audio recording, validation, and transcription
- Orchestrates multiple services while maintaining clean separation
- Encapsulates business rules and validation logic
- Use cases are injected into providers or widgets through dependency injection
- Each use case handles a specific business workflow with clear inputs and outputs

### Platform-Specific Features
- Global hotkeys only work on desktop platforms
- System tray integration for macOS/Windows/Linux
- Platform-specific permission handling for microphone access
- Method channels for window management (macOS show/hide)
- Keyboard shortcuts: Cmd/Ctrl+S to save edited transcriptions

## Important Development Notes

### Flutter SDK Requirements
- Requires Flutter SDK 3.3.0 or higher
- Tested and works with Flutter 3.38.5 (latest stable)
- Dart SDK constraint: '>=3.3.0 <4.0.0'

### Dependency Override for win32
Critical for Flutter 3.24+ compatibility:
```yaml
dependency_overrides:
  win32: ^5.15.0  # Required to avoid UnmodifiableUint8ListView errors
```

### Pub Cache Issues
If pub get is extremely slow (>5 minutes):
1. Cancel and use Chinese mirror: `export PUB_HOSTED_URL=https://pub.flutter-io.cn`
2. Or clear cache: `dart pub cache clean` then `flutter pub get`

### Hive Integration
- All models use `@HiveType` annotations with unique type IDs
- Run `build_runner` after modifying model classes
- Hive boxes are initialized in `StorageService.initialize()`

### Recording Flow
1. User triggers recording via FAB or global hotkey
2. `AudioService` handles microphone permissions and recording
3. `AudioAnalyzer` validates audio contains speech before processing
4. On stop, audio is sent to `GeminiService` with user's vocabulary/prompts
5. Result is saved via `StorageService` and optionally copied to clipboard
6. UI updates through state providers with success/error notifications

### Error Handling
- Enhanced error system with `EnhancedErrorHandler` for categorization
- Errors are displayed through `lastErrorProvider` with SnackBar notifications
- Service-level errors are logged to console for debugging
- Recording gracefully handles permission denial and API failures
- Error metadata includes retry timing, action hints, and severity levels

### Testing Considerations
Test structure:
- `test/unit/` - Unit tests for services, providers, and use cases
- `test/debug/` - Debug tests and integration tests
- `test/widget_test.dart` - Widget tests for UI components

Mock services using interfaces for unit tests:
- Test Hive operations with in-memory databases using `Hive.initFlutter(null)`
- Platform-specific features need conditional testing or mocks using `kIsWeb` or `Platform.isX`
- Use `VoiceRecordingUseCase` for testing complex workflows
- Provider tests use `ProviderContainer` for state management testing

Example test run:
```bash
make test              # Run all tests
make test-single TEST=test/unit/audio_service_test.dart  # Run specific test
make test-coverage     # Run tests with coverage report
```

### Version Management
- Current version: 1.0.2 (uses semantic versioning MAJOR.MINOR.PATCH without build numbers)
- Version management tools: Dart script, shell script, and Makefile targets
- Dynamic version display in settings (no hardcoded versions)
- Automated deployment system integrates with version management
- Version bumping: `make bump-patch|minor|major` to update pubspec.yaml automatically

### Key Dependencies
- **flutter_riverpod**: State management with code-generation support
- **hive_flutter**: Local persistence with type adapters
- **record**: Audio recording with permission handling
- **google_generative_ai**: Gemini API integration
- **hotkey_manager**: Global hotkey support (desktop only)
- **tray_manager**: System tray integration (desktop only)
- **package_info_plus**: Dynamic version reading
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
- Keyboard shortcuts: Cmd/Ctrl+S to save edited transcriptions

### Mobile Considerations
- Permission handling for microphone access
- No global hotkey support on mobile platforms
- Background recording limitations on iOS

### Code Signing (macOS)
- Uses Developer ID Application certificate for distribution
- Supports notarization for Gatekeeper compliance
- Configure in `scripts/codesign-config.sh` with your Apple Developer credentials

## Configuration System

The app uses external JSON configurations for easy customization:

```bash
config/
├── themes/           # Dark/light theme configurations
├── prompts/          # Pre-configured AI prompt templates
├── vocabulary/       # Industry-specific vocabulary sets
└── app_config.json   # Global app settings
```

Type-safe config classes in `lib/core/config/` load these at runtime:
- `AppConfig` - Global settings and feature flags
- `ApiConfig` - API endpoints and timeouts
- `AudioConfig` - Recording parameters and thresholds
- `ThemeConfig` - Color schemes and UI constants

Edit JSON files directly to customize without code changes. Configurations are loaded at runtime.

## Landing Page Development

The project includes a Vue 3 + Vite landing page in the `landing/` directory:

### Development Commands
```bash
# Navigate to landing page directory
cd landing

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

### Tech Stack
- **Vue 3.5+** with Composition API and `<script setup>`
- **Vite 6.0+** for ultra-fast development and building
- **Tailwind CSS 3.4** for utility-first styling
- **TypeScript** for type safety
- **Lucide Icons** for beautiful, minimal icons

### Download Management
The landing page includes automated download management:
- Apps are built to `landing/public/downloads/vX.X.X/` by Makefile
- `manifest.json` tracks current version and download paths
- Downloads page dynamically loads version information
- Supports all platforms: macOS, Windows, Linux, Android, Web