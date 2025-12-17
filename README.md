# Recogniz.ing

AI-powered voice typing application built with Flutter.

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

**macOS:**
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

## First Time Setup

1. Launch the app
2. Go to **Settings** tab
3. Enter your **Gemini API Key**
4. (Optional) Customize prompts and vocabulary
5. Return to **Dashboard**
6. Tap the **microphone button** to start recording
7. Tap again to stop and transcribe

## Features

- 🎤 Voice recording with one-tap control
- 🤖 AI-powered transcription via Gemini
- 📝 Custom prompts for different output formats
- 📚 Custom vocabulary for accurate transcription
- 📊 Usage statistics dashboard
- 🔍 Search through transcription history
- 📋 Auto-copy results to clipboard
- 🌙 Dark/Light theme support

## Troubleshooting

### "Microphone permission denied"
- macOS: System Preferences → Security & Privacy → Privacy → Microphone
- iOS: Settings → Recogniz.ing → Microphone
- Android: Settings → Apps → Recogniz.ing → Permissions

### "API key invalid"
- Ensure you copied the full API key from Google AI Studio
- Check that your API key has Gemini API access enabled

## License

MIT License
