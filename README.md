# Recogniz.ing

AI-powered voice typing application built with Flutter, featuring modern Material Design 3 and cross-platform support.

## Prerequisites

1. **Flutter SDK** (3.2.0 or higher)
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
- Desktop-only global hotkey support for quick activation
- System tray integration for desktop platforms
- Auto-cancellation of silent recordings
- **Enhanced Audio Analysis**: RMS-based amplitude detection with optimized thresholds
- Pre-validation to filter non-speech audio before API calls (reduces costs)

### 🤖 **AI-Powered Transcription**
- Powered by Google's Gemini 1.5 Flash model
- Intelligent noise filtering and silence detection
- Real-time transcription with customizable processing
- Automatic retry mechanism with exponential backoff
- **Editable Critical Instructions**: Fine-tune AI behavior with customizable prompts
- Built-in instruction presets (Strict, Balanced, Lenient) for different use cases

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
- Inline transcription editing capabilities
- Pagination for large transcription sets
- Export and share functionality

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

The app follows Flutter clean architecture principles:
- **Core Layer**: Services, models, and business logic
- **Features Layer**: UI components organized by feature
- **Configuration Layer**: Externalized settings and constants
- **State Management**: Riverpod with providers and notifiers

## License

MIT License

## Changelog

### v1.1.0 (Latest)
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
