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

- **Voice Recording** with smart activity detection
- **AI-Powered Transcription** using Gemini 1.5 Flash
- **Custom Prompts** for different output formats
- **Industry Vocabulary** sets (Medical, Legal, Finance, Tech)
- **Global Hotkeys** on desktop platforms
- **System Tray Integration** for quick access
- **Dark/Light Themes** with Material Design 3
- **Search & Edit** transcription history
- **Cross-Platform** support

## 🏗️ Project Structure

```
lib/
├── core/                 # Business logic and shared utilities
│   ├── config/          # Configuration loaders
│   ├── models/          # Data models with Hive adapters
│   ├── services/        # Business services (Audio, Gemini, Storage)
│   ├── theme/           # Material Design 3 theming
│   └── providers/       # Riverpod global providers
├── features/            # Feature-based UI modules
│   ├── dashboard/       # Main dashboard and stats
│   ├── recording/       # Recording overlay and VAD
│   └── settings/        # App configuration
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
