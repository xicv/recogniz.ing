# Recogniz.ing

AI-powered voice typing application built with Flutter, featuring modern Material Design 3, enhanced performance optimizations, and comprehensive error handling.

## ✨ What's New

### **Latest Version: 1.0.2**
- **📦 Version Management System**: Implemented proper semantic versioning with automated tools
- **⌨️ Keyboard Shortcuts**: Added Cmd/Ctrl+S to save edited transcriptions
- **🔧 Settings Navigation**: Fixed menu bar Settings navigation to open correct tab
- **🏗️ Deployment System**: Automated build and deployment pipeline for all platforms
- **📱 Code Signing**: macOS code signing and notarization support for distribution
- **📋 Landing Page**: New landing page with download management system
- **🎨 Enhanced UI Components**: New modern transcription tiles with improved interactions
- **📊 Simplified Dashboard**: Consolidated stats display with expandable details
- **🧩 Shared Widget Library**: Comprehensive reusable UI components for consistency

### **Previous Improvements (v2.0)**
- **⚡ Performance Optimizations**: Single API call mode reduces transcription time by up to 50%
- **🎨 Enhanced UI/UX**: Theme-consistent components with improved dark mode support
- **🔧 Better Error Handling**: Categorized error messages with actionable recovery options
- **📦 Component Library**: Standardized, reusable UI components for consistency
- **🔐 Improved Security**: Better password field handling and input validation

## Prerequisites

1. **Flutter SDK** (3.24.0 or higher recommended)
   ```bash
   # Check Flutter installation
   flutter doctor
   ```

2. **Gemini API Key**
   - Get your free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

## Setup

### 1. Navigate to Project
```bash
cd /Users/xicao/Library/CloudStorage/Dropbox/Projects/recogniz.ing
```

### 2. Create Flutter Project Structure
```bash
flutter create . --org com.recognizing --project-name recognizing
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App

**macOS (Recommended):**
```bash
flutter run -d macos
```

**iOS Simulator:**
```bash
flutter run -d ios
```

**Android:**
```bash
flutter run -d android
```

**Web:**
```bash
flutter run -d web
```

**Windows:**
```bash
flutter run -d windows
```

**Linux:**
```bash
flutter run -d linux
```

## First Time Setup

1. Launch the app
2. Go to **Settings** tab
3. Enter your **Gemini API Key**
4. (Optional) Customize prompts and vocabulary
5. Return to **Dashboard**
6. Tap the **microphone button** or use global hotkey (Cmd+Shift+Space) to start recording
7. Tap again to stop and transcribe

## Features

### 🎤 **Voice Recording**
- Smart voice activity detection (VAD) with configurable sensitivity
- Visual recording feedback with timer and waveform indicators
- Desktop-only global hotkey support (Cmd+Shift+Space on macOS, Ctrl+Shift+Space on Windows/Linux)
- System tray integration for desktop platforms
- Auto-cancellation of silent recordings
- **Enhanced Audio Analysis**: RMS-based amplitude detection with optimized thresholds
- Pre-validation to filter non-speech audio before API calls (reduces costs)
- **Background Processing**: Audio analysis in isolates for smooth UI performance

### 🤖 **AI-Powered Transcription**
- Powered by Google's Gemini 1.5 Flash model
- Intelligent noise filtering and silence detection
- Real-time transcription with customizable processing
- Automatic retry mechanism with exponential backoff
- **Editable Critical Instructions**: Fine-tune AI behavior with customizable prompts
- Built-in instruction presets (Strict, Balanced, Lenient) for different use cases
- **Single API Call Mode**: Optimized transcription that combines analysis and processing in one call
- **Smart Retry Logic**: Intelligent retry policies with circuit breaker pattern

### 📊 **Dashboard & Analytics**
- Real-time transcription history with search functionality
- Usage statistics tracking (transcriptions, tokens, duration)
- Editable transcriptions with auto-save
- Copy to clipboard with one-click
- Detailed transcription metadata (duration, tokens used, creation time)

### ⚙️ **Customization**
- 6 pre-configured prompts for different use cases
- Custom vocabulary sets for technical terms
- Configurable recording settings (sensitivity, minimum duration)
- Theme switching (Light/Dark mode)
- Global hotkey customization
- Auto-copy to clipboard option

### 📝 **Smart Prompts System**
- **6 Pre-configured Prompts:**
  - Clean Transcription - Removes filler words and fixes grammar
  - Formal Writing - Converts to professional text
  - Bullet Points - Organizes into concise bullets
  - Email Draft - Creates professional emails
  - Meeting Notes - Structures meeting summaries
  - Social Media Post - Optimizes for social platforms
- Custom prompt creation with template variables
- Prompt categories for easy organization
- Editable critical instructions for fine-tuning AI behavior

### 📚 **Enhanced Vocabulary Management**
- **6 Pre-configured Vocabulary Sets:**
  - General - Common tech terms (AI, API, UI/UX, GitHub)
  - Technology - Industry terms (Kubernetes, Docker, AWS, CI/CD)
  - Business - Corporate terminology (ROI, KPI, SaaS, stakeholders)
  - Medical - Healthcare terminology (diagnosis, therapy, radiology)
  - Legal - Legal terms (liability, litigation, jurisprudence)
  - Finance - Financial terms (portfolio, dividend, equity, IPO)
- Dynamic vocabulary loading from JSON configuration
- Multi-word phrase recognition
- **Visual Vocabulary Preview**: Expandable vocabulary tiles showing actual words in chips
- Quick word preview (first 3 words) when collapsed

### 🎨 **Modern UI/UX**
- Material Design 3 with expressive shapes and colors
- Responsive design adapting to all screen sizes
- Improved accessibility with semantic labels and tooltips
- Clean, minimal interface with thoughtful micro-interactions
- Dark/Light theme support with system preference detection

### 📊 **Advanced Dashboard**
- Real-time usage statistics (total recordings, total time)
- Searchable transcription history with highlighting
- Inline transcription editing capabilities with keyboard shortcuts
- Pagination for large transcription sets
- Export and share functionality
- **Simplified Stats Card**: Consolidated metrics display with expandable details
- **Visual Data Representation**: Clean, intuitive data visualization

### ⚡ **Performance & Reliability**
- Optimized for Flutter 3.38+ with clean architecture
- Riverpod state management for efficient re-renders
- Hive local storage for fast data persistence
- Comprehensive error handling with user-friendly messages
- Debug logging for development (auto-disabled in production)

## Configuration System

The app uses a modular JSON configuration system:

```
config/
├── themes/          - Color schemes and UI constants
├── prompts/         - Pre-configured prompt templates
├── vocabulary/      - Industry-specific vocabularies
└── app_config.json  - Global app settings
```

Customize themes, prompts, and vocabulary by editing the JSON files without touching code!

## Architecture

### Clean Architecture Overview
```
lib/
├── core/                    # Business logic and infrastructure
│   ├── constants/          # App-wide constants and UI dimensions
│   ├── config/             # Type-safe configuration classes
│   ├── error/              # Enhanced error handling system
│   ├── interfaces/         # Service interfaces for testing
│   ├── models/             # Data models with Hive serialization
│   ├── providers/          # Riverpod state providers
│   ├── services/           # External service integrations
│   ├── theme/              # Material Design 3 theming
│   ├── use_cases/          # Business use cases
│   └── utils/              # Helper utilities
├── features/               # Feature-based organization
│   ├── dashboard/          # Main dashboard feature
│   │   └── widgets/
│   │       └── simplified_stats_card.dart
│   ├── recording/          # Voice recording UI
│   ├── settings/           # Settings management
│   └── transcriptions/     # Transcription management
│       └── widgets/
│           ├── compact_transcription_tile.dart
│           └── modern_transcription_tile.dart
└── widgets/                # Reusable UI components
    └── shared/             # Cross-feature components
        ├── app_bars.dart
        ├── app_buttons.dart
        ├── app_cards.dart
        ├── app_chips.dart
        ├── app_dialogs.dart
        ├── app_inputs.dart
        ├── app_lists.dart
        └── loading_indicators.dart
```

### Key Services
- **AudioService**: Handles recording with VAD and background processing
- **GeminiService**: Manages AI transcription with optimized API calls
- **StorageService**: Centralized Hive database operations
- **VersionService**: Semantic version management and dynamic version reading
- **TrayService**: Desktop system tray integration
- **HotkeyService**: Global hotkey management
- **AudioAnalyzer**: Pre-validates audio with RMS-based speech detection

### State Management
- Uses Riverpod for reactive state management
- Providers organized by feature for better maintainability
- Clean separation between UI and business logic

## Development

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Format code
flutter format .

# Build for release
flutter build macos
flutter build ios
flutter build apk
flutter build web
```

### Generate Type Adapters
When modifying model files:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Keyboard Shortcuts (Desktop)

- **Cmd+Shift+Space** - Start/Stop recording (macOS)
- **Ctrl+Shift+Space** - Start/Stop recording (Windows/Linux)
- **Cmd/Ctrl+S** - Save edited transcription (when in edit mode)

## Troubleshooting

### "Microphone permission denied"
- **macOS**: System Preferences → Security & Privacy → Privacy → Microphone
- **iOS**: Settings → Recogniz.ing → Microphone
- **Android**: Settings → Apps → Recogniz.ing → Permissions

### "API key invalid"
- Ensure you copied the full API key from Google AI Studio
- Check that your API key has Gemini API access enabled
- Verify network connectivity

### "Global hotkey not working"
- Ensure app has accessibility permissions (macOS)
- Check for conflicting hotkeys in system settings

### "Transcription is empty"
- Ensure audio was captured (check for recording duration)
- Verify vocabulary doesn't interfere with common words
- Check network connection to Gemini API

## Architecture

The app follows Flutter clean architecture principles with layered separation:

### Core Layer (`lib/core/`)
- **Constants**: App-wide constants and configuration values
- **Models**: Data models with Hive serialization
- **Services**: Business logic and external integrations
  - AudioService: Microphone recording and validation
  - GeminiService: AI transcription and processing
  - StorageService: Hive database operations
  - TrayService: System tray integration (desktop)
  - HotkeyService: Global hotkey management
- **Error Handling**: Comprehensive error management with rich metadata
- **Providers**: Riverpod state management organized by domain
  - Service providers, settings providers, UI providers
  - Transcription, prompt, and vocabulary providers

### Use Cases Layer (`lib/core/use_cases/`)
- **RecordingUseCase**: Orchestrates the recording workflow
- Encapsulates business logic and coordinates services

### Features Layer (`lib/features/`)
- **Dashboard**: Statistics display, transcription history, search
- **Settings**: API key management, prompts, vocabulary configuration
- **Recording**: Recording overlay with voice activity detection UI

### Shared Widgets (`lib/widgets/`)
- Reusable UI components for consistency across features
- App bars, buttons, cards, dialogs, inputs, lists

### Configuration Layer (`config/`)
- JSON-based external configuration
- Prompts, vocabulary, themes, app settings
- Runtime loading without code changes

### State Management
- Riverpod with Provider pattern
- StateNotifier for complex state
- Proper separation of UI and business logic

## License

MIT License

## Changelog

### v1.0.2 (Latest)
- **NEW**: Comprehensive version management system with semantic versioning
- **NEW**: Version management tools (Dart script, shell script, Makefile targets)
- **NEW**: Keyboard shortcut (Cmd/Ctrl+S) for saving edited transcriptions
- **FIXED**: Settings menu navigation now opens correct Settings tab
- **NEW**: Automated deployment system with landing page integration
- **NEW**: macOS code signing and notarization support
- **NEW**: Landing page with download management
- **REFACTOR**: Simplified version format (removed unnecessary build numbers)
- **REFACTOR**: All version display now uses clean semantic versions

### v1.2.0
- **FIXED**: Transcriptions now properly appear in recent history
- **FIXED**: Prompt processing no longer confuses AI with IDs vs templates
- **FIXED**: Audio duration is now correctly captured and displayed
- **NEW**: Enhanced error handling with Lucide icons instead of emojis
- **NEW**: Rich error metadata with retry timing and action hints
- **NEW**: Smart retry mechanism with countdown timers
- **NEW**: Color-coded error messages for better UX
- **REFACTOR**: Improved code architecture with use cases layer
- **REFACTOR**: Added comprehensive shared widget components
- **ENHANCED**: Better prompt templates for clearer AI instructions

### v1.1.0
- **NEW**: Editable critical instructions in settings with safety warnings
- **NEW**: Expandable vocabulary tiles showing actual words in chip format
- **FIXED**: Audio analyzer RMS calculation bug causing false negatives
- **IMPROVED**: Lower audio detection thresholds for better speech sensitivity
- **ENHANCED**: Comprehensive debug logging for audio analysis
- **MIGRATION**: Seamless database migration for new features

### v1.0.0
- Initial release with core voice typing functionality
- Material Design 3 UI implementation
- Configuration system for themes, prompts, and vocabulary
- Desktop hotkey and system tray integration
- Advanced audio processing with VAD
- Comprehensive error handling and logging
