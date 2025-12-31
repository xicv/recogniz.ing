# Recogniz.ing Landing Page

A modern, minimalist landing page for the Recogniz.ing AI voice typing application.

**Live Site**: https://recogniz.ing/
**Repository**: https://github.com/xicv/recogniz.ing

---

## Latest Version: 1.10.0 (December 31, 2025)

### Recent Updates (v1.10.0)
- **📊 Transcription Status Tracking**: New status system with pending, processing, completed, and failed states
- **💾 Audio Backup for Retry**: Original audio files backed up locally for retrying failed transcriptions
- **🔍 Error Tracking**: Enhanced error tracking with retry count and completion timestamps
- **✅ Completion Timestamp**: Track when transcription processing finished for better analytics

### Previous Updates (v1.0.9)
- **🎨 App Logo Redesign**: Modern voice-to-text metaphor with sound-wave-to-text transformation
- **🌈 Brand Color Progression**: Cyan → Indigo → Emerald representing transcription flow

### Earlier Updates (v1.0.8)
- **🔧 CI/CD Fix**: Fixed detached HEAD error when pushing landing downloads
- **🍎🪟 Platform Releases**: macOS and Windows installers available

### Older Updates (v1.0.5)
- **⭐ Favorites Filter**: Quick access to starred transcriptions
- **🎨 Cleaner VAD UI**: Static processing indicator (no flashing)
- **🔧 Simplified Recording**: Removed auto-stop for manual control
- **✅ Code Quality**: Zero static analysis warnings

### Legacy Updates (v1.0.4)
- **📋 Changelog System**: JSON-first with auto-generated Markdown
- **🌐 Cross-platform Downloads**: All platforms with install instructions
- **✨ PWA Support**: Progressive Web App with offline capabilities
- **🔐 macOS Security**: Fixed Gatekeeper verification issues
- **🪟 Windows Support**: Initial Windows release with native installer

---

## About Recogniz.ing

Recogniz.ing is an AI-powered voice typing application built with Flutter that:
- Transcribes voice recordings in real-time using Google's Gemini AI
- Supports cross-platform deployment (macOS, Windows, Linux, iOS, Android, Web)
- Features smart voice activity detection and audio analysis
- Offers customizable prompts and vocabulary for specialized domains
- Provides Material Design 3 UI with dark/light theme support

---

## Tech Stack

- **Vue 3.5** with Composition API and `<script setup>` syntax
- **Vite 6.4** for ultra-fast development and optimized builds
- **Tailwind CSS 3.4** for utility-first styling
- **TypeScript 5.6** for type safety
- **Vue Router 4.5** for SPA navigation
- **vite-plugin-pwa 0.21** for Progressive Web App capabilities
- **Lucide Vue Next** for modern icons

---

## Features

- ✨ Minimalist, clean design with beautiful typography
- 📱 Fully responsive design with mobile-first approach
- 🚀 Lightning fast loading with Vite 6
- 🎨 Smooth animations and transitions
- ♿ Accessibility-first approach with semantic HTML
- 🔍 SEO optimized meta tags
- 🔗 Links to app downloads and documentation
- 📦 **Download Management**: Automated platform-specific downloads with semantic versioning
- 📋 **Version Manifest**: JSON-based download system with version tracking
- 🔄 **CI/CD Integration**: Automated build and deployment via GitHub Actions
- 🔐 **Code Signing**: macOS builds support code signing and notarization
- 📲 **PWA Support**: Install as app on supported devices with offline capabilities

---

## Deployment Architecture

This landing page is part of a single-repository architecture that houses both the Flutter app and the Vue 3 landing page.

### Repository Structure

```
xicv/recogniz.ing (Single Repository)
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates GitHub Releases
│   ├── build-windows.yml          # Windows-specific build
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
├── lib/                           # Flutter app source code
├── android/, ios/, macos/, ...    # Flutter platform folders
├── pubspec.yaml                   # Flutter dependencies
└── landing/                        # This folder
    ├── src/
    ├── public/downloads/
    │   └── manifest.json           # Version manifest (only tracked file)
    ├── public/.nojekyll            # Required for GitHub Pages + Vite
    └── package.json
```

**Note**: The Flutter project root IS the repository root. All Flutter commands (`flutter pub get`, `flutter run`, etc.) are run from `/recogniz.ing/`, not from a subdirectory.

### Automated Deployment Flow

1. **Tag Push**: Push a version tag (e.g., `v1.0.8`) to main branch
2. **Build & Release**: GitHub Actions builds all platforms and creates a GitHub Release
3. **Update Manifest**: Workflow updates `landing/public/downloads/manifest.json` with version info
4. **Deploy Landing**: Commit triggers `landing-deploy.yml` → deploys to GitHub Pages

> **Note**: Build artifacts are stored in **GitHub Releases**, not in the repository. The `downloads/` folder contains only `manifest.json` for version tracking.

### GitHub Pages Settings

- **Source**: GitHub Actions (not Deploy from a branch)
- **Custom Domain**: `recogniz.ing`
- **Workflow**: `.github/workflows/landing-deploy.yml`
- **Important**: `.nojekyll` file in `public/` prevents GitHub Pages from ignoring underscore-prefixed files (required for Vite builds)

---

## Getting Started

### Prerequisites
- Node.js 18+ or 20+ (recommended)
- npm or yarn

### Installation

```bash
# Navigate to landing folder
cd landing

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

---

## Project Structure

```
landing/
├── public/                  # Static assets
│   ├── downloads/
│   │   └── manifest.json   # Version manifest (only tracked file)
│   ├── .nojekyll           # Required for GitHub Pages + Vite
│   └── assets/             # Images, icons, etc.
├── src/
│   ├── App.vue             # Root component
│   ├── main.ts             # Entry point
│   ├── router/             # Vue Router configuration
│   │   └── index.ts
│   ├── composables/        # Vue composables (shared logic)
│   ├── views/              # Page components
│   │   ├── HomeView.vue
│   │   ├── DownloadsView.vue
│   │   ├── FeaturesView.vue
│   │   ├── ChangelogView.vue
│   │   └── ContactView.vue
│   ├── components/
│   │   └── layout/         # Layout components
│   │       ├── AppHeader.vue
│   │       ├── AppFooter.vue
│   │       └── MainLayout.vue
│   └── style.css           # Global styles
├── index.html              # HTML template
├── vite.config.ts          # Vite configuration + PWA plugin
├── tailwind.config.js      # Tailwind CSS configuration
└── package.json
```

---

## Download System

The landing page includes an automated download management system:

### How Downloads Work

1. **Release Builds**: When a version tag is pushed, GitHub Actions builds all platforms
2. **GitHub Release**: Official release created with artifacts attached
3. **Manifest Update**: `manifest.json` is updated with version info
4. **Download Links**: Landing page displays links to GitHub Releases

### Download URLs

Download URLs in `src/views/DownloadsView.vue` point to GitHub Releases:
```
https://github.com/xicv/recogniz.ing/releases/download/v{VERSION}/recognizing-{VERSION}-{platform}.zip
```

### Supported Platforms

| Platform | File Format | Code Signing | Status |
|----------|-------------|--------------|--------|
| macOS | `.zip` (app bundle) | ✅ Signed & Notarized | ✅ Available |
| Windows | `.zip` (portable) | Planned | ✅ Available |
| Linux | `.tar.gz` | N/A | ✅ Available |
| Android | `.apk`, `.aab` | Planned | ✅ Available |
| Web | `.zip` | N/A | ✅ Available |

---

## Design Principles

1. **Minimalism** - Clean layout with ample white space
2. **Clarity** - Clear typography hierarchy
3. **Performance** - Optimized for fast loading
4. **Accessibility** - Semantic HTML and ARIA labels
5. **Mobile-first** - Responsive design approach

---

## Customization

- Colors configured in `tailwind.config.js`
- Content in `src/views/` components
- Meta tags in `index.html`
- Download versions in `src/views/DownloadsView.vue`

---

## License

MIT License
