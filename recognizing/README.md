# Recogniz.ing

AI-powered voice typing application with real-time transcription powered by Google's Gemini AI.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20Android%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-4285F4?style=for-the-badge)

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd recognizing

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run on your preferred platform
flutter run -d macos    # macOS (Recommended)
flutter run -d ios       # iOS Simulator
flutter run -d android   # Android
flutter run -d web       # Web
```

## 📋 Requirements

- Flutter SDK 3.2.0 or higher
- Dart 3.0 or higher
- Gemini API Key from [Google AI Studio](https://makersuite.google.com/app/apikey)

## 🎯 Key Features

### Core Functionality
- **Voice Recording** with smart activity detection and RMS-based audio analysis
- **AI-Powered Transcription** using Gemini 3 Flash (latest model)
- **Real-time Processing** with customizable prompts and vocabulary
- **Audio Duration Tracking** for accurate usage statistics
- **Smart Retry Mechanism** with automatic error recovery

### User Experience
- **Enhanced Error Handling** with Lucide icons and rich metadata
- **Color-coded Error Messages** for quick identification
- **Actionable Error Hints** with direct navigation to settings
- **Retry Countdown Timers** for quota exceeded scenarios
- **Visual Feedback** with recording overlay and audio indicators

### Customization
- **Editable Critical Instructions** to fine-tune AI behavior with presets
- **6 Pre-configured Prompts**: Clean, Formal, Bullet Points, Email, Meeting Notes, Social
- **6 Industry Vocabulary Sets**: General, Technology, Business, Medical, Legal, Finance
- **Visual Vocabulary Display** with expandable tiles showing actual words
- **Custom Prompt Creation** with template variables

### Platform Features
- **Global Hotkeys** on desktop (Ctrl+Shift+R)
- **System Tray Integration** for quick access
- **Dark/Light Themes** with Material Design 3
- **Cross-Platform Support**: macOS, Windows, Linux, iOS, Android, Web
- **Auto-copy to Clipboard** for transcriptions
- **Search & Edit** transcription history with inline editing

## 🏗️ Project Structure

```
lib/
├── core/                 # Business logic and shared utilities
│   ├── constants/       # App-wide constants and configuration
│   ├── error/           # Enhanced error handling with metadata
│   ├── models/          # Data models with Hive adapters
│   ├── services/        # Business services (Audio, Gemini, Storage, Tray, Hotkey)
│   ├── theme/           # Material Design 3 theming
│   ├── use_cases/       # Business logic orchestration
│   └── providers/       # Riverpod state management
│       ├── app_providers.dart      # Main aggregation
│       ├── service_providers.dart  # Service instances
│       ├── settings_providers.dart # App settings
│       ├── transcription_providers.dart
│       ├── prompt_providers.dart
│       ├── vocabulary_providers.dart
│       ├── ui_providers.dart
│       └── loading_providers.dart
├── features/            # Feature-based UI modules
│   ├── dashboard/       # Main dashboard and statistics
│   │   └── widgets/
│   │       └── simplified_stats_card.dart
│   ├── recording/       # Recording overlay and VAD
│   └── settings/        # App configuration
├── widgets/             # Shared UI components
│   ├── shared/          # Reusable widgets
│   │   ├── app_bars.dart
│   │   ├── app_buttons.dart
│   │   ├── app_cards.dart
│   │   ├── app_dialogs.dart
│   │   ├── app_inputs.dart
│   │   └── app_lists.dart
│   └── global_loading_overlay.dart
├── config/              # JSON configuration files
│   ├── prompts/         # Default prompt templates
│   ├── vocabulary/      # Industry vocabularies
│   └── themes/          # Color schemes
└── main.dart            # App entry point
```

## ⚙️ Configuration

The app uses JSON configuration files located in `config/`:

- `themes/` - Color schemes and UI constants
- `prompts/` - Default prompt templates
- `vocabulary/` - Industry-specific vocabularies
- `app_config.json` - Global app settings

## 🧪 Development

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
flutter format .

# Build for production
flutter build macos --release
flutter build ios --release
flutter build apk --release
flutter build web --release
```

## 🔧 Development Commands

### Hot Reload
```bash
flutter run --hot
```

### Build Runner
After modifying model files:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Clean Build
```bash
flutter clean
flutter pub get
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| macOS | ✅ Full | Global hotkeys, system tray |
| iOS | ✅ Full | Optimized for iPhone/iPad |
| Android | ✅ Full | Material Design 3 |
| Windows | ✅ Full | Global hotkeys, system tray |
| Linux | ✅ Full | Global hotkeys, system tray |
| Web | ✅ Partial | No audio recording (browser limits) |

## 🐛 Troubleshooting

### Build Issues
- Run `flutter clean && flutter pub get`
- Ensure you're on Flutter 3.2.0+
- Check platform-specific dependencies

### Runtime Issues
- Verify microphone permissions
- Check Gemini API key validity
- Ensure network connectivity

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod State Management](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
- [Google Gemini API](https://ai.google.dev/docs)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆕 Latest Updates (v2.0)

### ⚡ Performance Improvements
- **Single API Call Mode**: 50% faster transcription by combining analysis and processing
- **Background Audio Processing**: Smooth UI with isolated audio analysis
- **Optimized Retry Logic**: Intelligent retry policies with circuit breaker pattern

### 🎨 Enhanced UI/UX
- **Theme-Consistent Components**: All widgets now use Material Design 3 colors
- **Improved Dark Mode**: Better contrast and visual hierarchy
- **Standardized Component Library**: Reusable widgets with consistent styling
- **Fixed Password Fields**: Proper state management and better UX

### 🔧 Better Error Handling
- **Categorized Error Messages**: Network, API, Permission, Audio errors with specific guidance
- **Actionable Recovery Options**: One-click fixes for common issues
- **Error Severity Levels**: Critical errors shown as dialogs, others as snackbars
- **Technical Details View**: Expandable error details for debugging (debug mode)

### 📦 Component Library Standardization
- **Removed Global Context Issues**: Fixed memory leaks and context passing problems
- **Improved Input Components**: Better validation, theming, and accessibility
- **Enhanced Cards and Lists**: Consistent styling across the app
- **Better Loading States**: More informative loading indicators

### 🏗️ Architecture Improvements
- **Cleaner Error System**: EnhancedErrorHandler with better categorization
- **Improved State Management**: Fixed provider dependencies and data flow
- **Better Service Layer**: Optimized Gemini and Audio services
- **Enhanced Use Cases**: More robust business logic handling

## 🆕 v1.2.0 (Previous)

### Major Fixes
- **Transcription History**: Fixed issue where transcriptions weren't appearing in recent history
- **Prompt Processing**: Resolved AI confusion between prompt IDs and actual prompt templates
- **Audio Duration**: Now correctly captures and displays recording duration
- **State Management**: Improved provider usage for better UI updates

### Enhanced Error Handling
- **Lucide Icons**: Replaced all emojis with professional Lucide icons
- **Rich Error Metadata**: Added retry timing, action hints, and error categorization
- **Smart Retry**: Automatic retry mechanism with countdown timers
- **Color Coding**: Visual differentiation of error types
- **Better UX**: Direct navigation to Settings for API key issues

### Architecture Improvements
- **Use Cases Layer**: Added RecordingUseCase for better business logic separation
- **Shared Widgets**: Created comprehensive widget library for code reuse
- **Provider Organization**: Better structured Riverpod providers
- **Error System**: Complete error handling overhaul with metadata

### v1.1.0
- **Editable Critical Instructions**: Customize AI behavior directly in settings with built-in safety warnings
- **Vocabulary Word Preview**: Expand vocabulary sets to see all words in an elegant chip layout
- **Audio Analysis Improvements**: Fixed RMS calculation bug for accurate speech detection

### v1.0.0
- **Initial Release**: Core voice typing with Material Design 3
- **Platform Support**: Cross-platform deployment with desktop features
- **Configuration System**: JSON-based prompts and vocabulary management
