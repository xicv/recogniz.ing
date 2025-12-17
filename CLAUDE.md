# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered voice typing application built with Flutter, supporting desktop (macOS, Windows, Linux), iOS, and Android platforms. The app provides real-time voice activity detection, transcription using AI service providers (like Gemini API), and customized output through user-defined vocabulary and prompts.

Core features:
- Voice activity detection and recording
- AI-powered transcription with customizable vocabulary
- Custom prompt management for tailored output
- Dashboard with usage statistics and transcription history
- Global hotkey support for quick activation
- Cross-platform support (desktop + mobile)

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
```

## Project Architecture

### Current State
The project is in its initial setup phase with a default Flutter counter app template. The actual implementation needs to be built according to the requirements in `specs/requirements.md`.

### Planned Architecture
Based on the requirements document, the app will need:

1. **Main Application Flow**
   - Dashboard page: Statistics, recent transcriptions, search functionality
   - Settings page: API key management, custom vocabulary, custom prompts, global hotkey configuration
   - Voice recording/transcription service triggered by global hotkey

2. **Key Services to Implement**
   - Voice activity detection and recording
   - AI service provider integration (Gemini API and others)
   - Custom vocabulary and prompt management
   - Statistics tracking and persistence
   - Global hotkey system integration
   - Clipboard management
   - Notification system

3. **Data Models**
   - Transcription record (timestamp, content, vocabulary used, prompt used)
   - Custom vocabulary entries
   - Custom prompts
   - Usage statistics (token usage, frequency counts)
   - User settings (API keys, hotkeys, preferences)

4. **Platform-Specific Considerations**
   - Global hotkeys will require platform-specific implementations
   - Voice recording permissions on mobile platforms
   - Background processing capabilities
   - System notifications integration

### Development Notes
- The app uses Material Design 3 (`useMaterial3: true`)
- Dart SDK version: '>=3.3.3 <4.0.0'
- Currently includes only basic Flutter dependencies
- Will need additional packages for voice recording, HTTP requests, local storage, global hotkeys, and platform integration

### File Structure (to be implemented)
```
lib/
├── main.dart
├── models/          # Data models
├── services/        # Voice recording, AI integration, storage
├── screens/         # Dashboard, settings, transcription screens
├── widgets/         # Reusable UI components
├── utils/           # Helpers and utilities
└── platform/        # Platform-specific implementations
```