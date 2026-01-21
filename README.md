# Recogniz.ing

**AI-powered voice typing that adapts to your workflow.** Privacy-first, cross-platform, and powered by Google Gemini 3 Flash.

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
   - **Generous free tier**: Gemini 3 Flash offers free requests that cover daily personal use for most users
   - Paid tier only ~$0.075 per million characters when needed (very affordable)

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
flutter run -d web        # Web browser (limited)
```

### Using the Makefile

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
3. Enter your **Gemini API Key** (or add multiple keys for automatic failover)
4. (Optional) Customize prompts and vocabulary
5. Return to **Dashboard** to see your free tier quota
6. Tap the **microphone button** or use global hotkey (Cmd+Shift+Space / Ctrl+Shift+Space)
7. Tap again to stop and transcribe

---

## Features

### 🎤 Smart Voice Recording
- **Silero VAD** (~95% accuracy) ML-based voice activity detection
- **Graceful fallback** to amplitude-based VAD (~75% accuracy) when ML unavailable
- Real-time speech probability feedback with visual state indicators
- **Global hotkeys** (Cmd+Shift+Space / Ctrl+Shift+Space) with system tray integration
- RMS-based audio validation filters non-speech before API calls
- Background audio analysis in isolates for smooth UI performance
- **Smart audio format selection**: Auto/Compact/Full modes based on recording duration

### 🤖 Gemini 3 Flash Transcription
- Powered by **Google Gemini 3 Flash** (gemini-3-flash-preview) - Google's fastest AI model
- **Generous free tier** covers daily personal use for most users—no payment required
- **Token-efficient prompts** with 67% reduction in overhead
- **Auto-retry mechanism** handles transient API errors automatically
- **Multi-language support** with auto-detection (20+ languages including Chinese, Japanese, Korean)
- **SHA-256 cache key generation** for accurate transcription caching
- Support for up to ~3.5 hours of audio per request (100MB inline limit)

### 🎛️ Customization
- **6 pre-configured prompts**: Clean, Formal, Bullets, Email, Meeting Notes, Social Media
- **6 vocabulary sets**: General, Technology, Business, Medical, Legal, Finance
- **Custom vocabulary** support for industry-specific terms
- **Custom prompt creation** with template variables
- **Language selection** or auto-detection for transcriptions
- **Audio format preference**: Auto (smart), Compact (AAC), or Full (PCM)

### 📊 Dashboard & Analytics
- **Free tier quota tracking** with visual progress indicator
- **Multi-API key management** with automatic failover on rate limits
- Per-key usage statistics and daily averages
- Days until exhaustion projection
- Real-time transcription history with search functionality
- Favorites filter to quickly access starred transcriptions
- Usage statistics tracking (transcriptions, tokens, duration, words)
- Editable transcriptions with auto-save
- Copy to clipboard with one-click
- Detailed transcription metadata (duration, tokens, detected language)

### 🔒 Privacy & Security
- **Privacy-first design**: All data stored locally on your device
- **No account required**: Use the app immediately after setup
- **No telemetry or analytics**: No user data collected or sent to our servers
- **Audio only sent to API**: Recordings sent only to Google for transcription, not stored
- **Local-only storage**: Transcriptions, settings, and audio files never leave your device

### 🔧 Audio Format Options
- **Smart mode**: Automatically chooses format based on recording duration
  - < 2 minutes: AAC (compressed, fast)
  - 2-5 minutes: AAC with warning about potential truncation
  - 5+ minutes: PCM (uncompressed, reliable)
- **Compact mode**: Always AAC format (smaller files, may lose 0.5-2s at end)
- **Full mode**: Always PCM format (larger files, no audio loss)
- **Audio diagnostic** to detect truncation issues
- **Auto-retry** for transient API empty responses

### 🌍 Multi-Language Support
- **20+ languages** supported including Chinese, Japanese, Korean, Spanish, French, German, and more
- **Automatic language detection** with native display names
- **Code-switching support** preserves mixed-language speech
- **Language preference** setting or auto-detect by default

### 🎨 Modern UI/UX
- Material Design 3 with dynamic theming and expressive components
- Collapsible left drawer navigation (replaces bottom tabs)
- Smooth animations with scroll-reveal effects
- Responsive design adapting to all screen sizes
- Light/Dark theme with system preference detection
- WCAG AAA compliant with 7:1 minimum contrast ratio
- Keyboard shortcuts: Cmd/Ctrl+1-5 for navigation, Cmd/Ctrl+S to save edits

---

## Architecture

### Clean Architecture Overview

```
lib/
├── core/                    # Business logic and infrastructure
│   ├── constants/          # App-wide constants and UI dimensions
│   ├── config/             # Type-safe configuration classes
│   ├── error/              # Enhanced error handling system
│   ├── interfaces/         # Service interfaces for testing (VadServiceInterface, etc.)
│   ├── models/             # Data models with Hive serialization
│   ├── providers/          # Riverpod state providers
│   ├── services/           # External service integrations (Gemini, VAD, Audio, etc.)
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
- Riverpod for reactive state management
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
