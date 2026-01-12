# Recogniz.ing

AI-powered voice typing application built with Flutter, featuring modern Material Design 3, enhanced performance optimizations, and comprehensive error handling.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue.svg)](https://flutter.dev)

**Repository**: https://github.com/xicv/recogniz.ing
**Landing Page**: https://recogniz.ing/

---

## Quick Start

### Prerequisites

1. **Flutter SDK** (3.24.0 or higher recommended)
   ```bash
   flutter doctor
   ```

2. **Gemini API Key** - Get your free API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

### Installation & Running

```bash
# Clone the repository
git clone https://github.com/xicv/recogniz.ing.git
cd recogniz.ing

# Install dependencies
flutter pub get

# Run on macOS (recommended)
flutter run -d macos

# Or run on other platforms
flutter run -d ios        # iOS Simulator
flutter run -d android    # Android device/emulator
flutter run -d windows    # Windows
flutter run -d linux      # Linux
flutter run -d web        # Web browser
```

### Using the Makefile

The project includes a comprehensive Makefile for common tasks:

```bash
# Dependencies & Development
make get              # Install Flutter dependencies
make run-macos        # Run on macOS
make dev              # get + analyze + format + test
make quick-run        # get + run-macos (quick start)

# Version Management
make version          # Show current version
make sync-version     # Sync pubspec.yaml from CHANGELOG.json (SSOT)
make changelog        # Generate CHANGELOG.md from CHANGELOG.json
make verify-changelog # Verify changelogs are in sync
make bump-patch       # Bump patch version
make bump-patch-entry # Bump patch + add changelog entry template
make release          # Bump patch + deploy all platforms
```

---

## First Time Setup

1. Launch the app
2. Go to **Settings** tab
3. Enter your **Gemini API Key**
4. (Optional) Customize prompts and vocabulary
5. Return to **Dashboard**
6. Tap the **microphone button** or use global hotkey (Cmd+Shift+Space) to start recording
7. Tap again to stop and transcribe

---

## Features

### 🎤 Voice Recording
- Smart voice activity detection (VAD) with real-time feedback
- Visual recording feedback with timer, waveform, and state indicators
- Clean, static processing indicator (no flashing animations)
- Desktop global hotkey support (Cmd+Shift+Space on macOS, Ctrl+Shift+Space on Windows/Linux)
- System tray integration for desktop platforms
- RMS-based amplitude detection with optimized thresholds
- Pre-validation to filter non-speech audio before API calls (reduces costs)
- Background audio analysis in isolates for smooth UI performance

### 🤖 AI-Powered Transcription
- Powered by Google's Gemini 3.0 Flash model
- Intelligent noise filtering and silence detection
- Real-time transcription with customizable processing
- Automatic retry mechanism with exponential backoff
- Editable critical instructions for fine-tuning AI behavior
- Built-in instruction presets (Strict, Balanced, Lenient)
- Smart retry logic with circuit breaker pattern

### 📊 Dashboard & Analytics
- Real-time transcription history with search functionality
- Favorites filter to quickly access starred transcriptions
- Usage statistics tracking (transcriptions, tokens, duration)
- Editable transcriptions with auto-save
- Copy to clipboard with one-click
- Detailed transcription metadata (duration, tokens used, creation time)

### ⚙️ Customization
- 6 pre-configured prompts for different use cases
- Custom vocabulary sets for technical terms
- Theme switching (Light/Dark mode)
- Global hotkey customization
- Auto-copy to clipboard option
- Show notifications toggle
- Start at login (desktop platforms)

### 📝 Smart Prompts System
- Clean Transcription, Formal Writing, Bullet Points, Email Draft, Meeting Notes, Social Media Post
- Custom prompt creation with template variables
- Prompt categories for easy organization
- Editable critical instructions

### 📚 Enhanced Vocabulary Management
- 6 Pre-configured Vocabulary Sets: General, Technology, Business, Medical, Legal, Finance
- Dynamic vocabulary loading from JSON configuration
- Multi-word phrase recognition
- Visual vocabulary preview with expandable tiles

### 🎨 Modern UI/UX
- Material Design 3 with expressive shapes and colors
- Collapsible left drawer navigation (replaces bottom tabs)
- Smooth 250ms animations with easeOutCubic easing
- Responsive design adapting to all screen sizes
- Clean, minimal interface with thoughtful micro-interactions
- Dark/Light theme support with system preference detection
- Consistent border radius system (8, 12, 16, 20px)
- Typography hierarchy with refined font weights (w500 for labels, w600 for headlines)
- Hover effects on cards with subtle shadows
- Empty states with gradient icon backgrounds
- WCAG AAA compliant with 7:1 minimum contrast ratio

---

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
│   ├── app_shell.dart      # Main app container with navigation
│   ├── dashboard/          # Statistics and transcription history
│   ├── dictionaries/       # Vocabulary management
│   ├── prompts/            # AI prompt templates
│   ├── recording/          # Voice recording UI with VAD
│   ├── settings/           # Settings management
│   └── transcriptions/     # Transcription cards and display
└── widgets/                # Reusable UI components
    ├── navigation/         # Navigation drawer
    └── shared/             # Cross-feature components
```

**Note**: The Flutter project root IS the repository root (`/recogniz.ing/`), not a subdirectory. All Flutter commands run from the root.

### State Management
- Uses Riverpod for reactive state management
- Providers organized by feature for better maintainability
- Clean separation between UI and business logic

---

## Landing Page Deployment

The repository includes a Vue 3 + Vite + TailwindCSS landing page that deploys to GitHub Pages.

### Deployment Architecture

```
xicv/recogniz.ing (Single Repository)
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates GitHub Releases
│   ├── build-windows.yml          # Windows-specific builds
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
└── landing/                        # Vue 3 + Vite + TailwindCSS landing page
    ├── src/
    ├── public/downloads/
    │   └── manifest.json           # Version manifest (only tracked file)
    ├── public/.nojekyll            # Required for GitHub Pages + Vite
    └── package.json
```

**Tech Stack**: Vue 3.5, Vite 6.0, TailwindCSS 3.4, TypeScript 5.5, PWA (vite-plugin-pwa 0.21)

### Automated Release Flow

1. **Tag Push**: Push a version tag (`v1.0.8`) → triggers `release-all-platforms.yml`
2. **Parallel Builds**: GitHub Actions builds all platforms simultaneously
3. **GitHub Release**: Creates release with artifacts attached
4. **Update Manifest**: Updates `landing/public/downloads/manifest.json`
5. **Deploy Landing**: Commit triggers `landing-deploy.yml` → deploys to https://recogniz.ing/

> **Note**: Build artifacts are stored in **GitHub Releases**, not in the repository.

### Landing Page Development

```bash
cd landing
npm install
npm run dev     # Start dev server
npm run build   # Build for production
```

---

## Changelog Management

The project uses a single-source-of-truth changelog system where `CHANGELOG.json` is the authoritative source and `CHANGELOG.md` is auto-generated.

### Changelog Workflow

```bash
# 1. Bump version with entry template
make bump-patch-entry

# 2. Edit CHANGELOG.json with actual changes
#    - Update highlights
#    - Add/modify change entries (categories: added, changed, fixed, removed, security)

# 3. Generate Markdown from JSON
make changelog

# 4. Commit both files together
git add CHANGELOG.json CHANGELOG.md pubspec.yaml
git commit -m "chore: bump version to X.Y.Z and update changelog"
```

### Version Manager Commands

```bash
dart scripts/version_manager.dart --help               # Show all options
dart scripts/version_manager.dart --current            # Show current version
dart scripts/version_manager.dart --sync-from-changelog # Sync pubspec.yaml from CHANGELOG.json
dart scripts/version_manager.dart --changelog          # Generate CHANGELOG.md
dart scripts/version_manager.dart --verify-changelog   # Check if files are in sync
dart scripts/version_manager.dart --bump patch --add-entry  # Bump + add template
```

### Why JSON as Source of Truth?

1. **Programmatic Access**: JSON is easier to parse and render in UI components
2. **Validation**: Schema can be validated, reducing errors
3. **Automation**: CI/CD can easily read and process changelog data
4. **Single Source**: Edit one file, generate the other automatically

---

## Development

### Code Quality

```bash
make analyze          # flutter analyze
make format           # flutter format .
make test             # Run all tests
make test-coverage    # Run tests with coverage
make test-single TEST=test/widget_test.dart  # Run specific test
```

### Code Generation

```bash
make generate         # build_runner with delete-conflicting-outputs
# Run after modifying any model files with @HiveType annotations
```

### Build & Deploy

```bash
make build-macos      # Build macOS release
make deploy-all       # Build and deploy all platforms to landing page
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Cmd+Shift+Space** (macOS) / **Ctrl+Shift+Space** (Win/Lin) | Start/Stop recording |
| **Cmd/Ctrl+S** | Save edited transcription |
| **Cmd/Ctrl+1-5** | Navigate to Transcriptions, Dashboard, Dictionaries, Prompts, Settings |

---

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
- Ensure audio was captured (check recording duration)
- Verify vocabulary doesn't interfere with common words
- Check network connection to Gemini API

---

## License

MIT License

---

## Changelog

For detailed version history and release notes, see [CHANGELOG.md](CHANGELOG.md).

**Quick links:**
- [v1.12.0](CHANGELOG.md#1110---2025-12-31) - Complete app logo redesign with bold 'R' and red recording dot
- [v1.10.0](CHANGELOG.md#1100---2025-12-31) - Transcription status tracking with retry functionality
- [v1.0.9](CHANGELOG.md#109---2025-12-31) - App logo redesign with modern voice-to-text metaphor
- [v1.0.8](CHANGELOG.md#108---2025-12-29) - Platform releases and CI/CD fixes
- [v1.0.5](CHANGELOG.md#105---2025-12-29) - Favorites filter and UI improvements
- [v1.0.4](CHANGELOG.md#104---2025-12-23) - Changelog system and deployment architecture
