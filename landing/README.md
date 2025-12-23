# Recogniz.ing Landing Page

A modern, minimalist landing page for the Recogniz.ing AI voice typing application.

**Live Site**: https://recogniz.ing/
**Repository**: https://github.com/xicv/recogniz.ing

---

## Latest Version: 1.0.3 (December 21, 2025)

### Recent Updates
- **🎨 Updated Platform Icons**: Better visual representation with iMac for macOS and Apple logo for iOS
- **📦 Improved Downloads**: Enhanced download management with version 1.0.3 builds
- **🔐 macOS Security**: Fixed Gatekeeper verification issues
- **🪟 Windows Support**: Initial Windows release with native installer
- **🏗️ Deployment**: Simplified single-repository deployment architecture

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

- **Vue 3.5+** with Composition API and `<script setup>`
- **Vite 7.0** for ultra-fast development and building
- **Tailwind CSS 3.4** for utility-first styling
- **TypeScript** for type safety
- **Vue Router** for SPA navigation
- **Git LFS** for large download file storage

---

## Features

- ✨ Minimalist, clean design with beautiful typography
- 📱 Fully responsive design
- 🚀 Lightning fast loading with Vite 7
- 🎨 Smooth animations and transitions
- ♿ Accessibility-first approach
- 🔍 SEO optimized meta tags
- 🔗 Links to app downloads and documentation
- 📦 **Download Management**: Automated platform-specific downloads with semantic versioning
- 📋 **Version Manifest**: JSON-based download system with version tracking
- 🔄 **CI/CD Integration**: Automated build and deployment via GitHub Actions
- 🔐 **Code Signing**: macOS builds support code signing and notarization

---

## Deployment Architecture

This landing page is part of a single-repository architecture that houses both the Flutter app and the Vue 3 landing page.

### Repository Structure

```
xicv/recogniz.ing (Single Repository)
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates releases
│   ├── release.yml                 # Alternative release workflow
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
├── [Flutter App Source Code]
└── landing/                        # This folder
    ├── src/
    ├── public/downloads/           # App download artifacts (Git LFS)
    │   └── manifest.json           # Version manifest
    └── package.json
```

### Automated Deployment Flow

1. **Tag Push**: Push a version tag (e.g., `v1.0.4`) to main branch
2. **Build & Release**: GitHub Actions builds all platforms and creates a GitHub Release
3. **Update Downloads**: Workflow commits artifacts to `landing/public/downloads/[version]/`
4. **Deploy Landing**: Commit triggers `landing-deploy.yml` → deploys to GitHub Pages

### GitHub Pages Settings

- **Source**: GitHub Actions (not Deploy from a branch)
- **Custom Domain**: `recogniz.ing`
- **Workflow**: `.github/workflows/landing-deploy.yml`

---

## Getting Started

### Prerequisites
- Node.js 20+ (required for Vite 7)
- npm

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
│   ├── downloads/           # Platform-specific app downloads (Git LFS)
│   │   ├── 1.0.3/          # Version-specific downloads
│   │   │   ├── macos/
│   │   │   ├── windows/
│   │   │   ├── linux/
│   │   │   └── android/
│   │   └── manifest.json   # Version manifest for downloads
│   └── assets/             # Images, icons, etc.
├── src/
│   ├── App.vue             # Root component
│   ├── main.ts             # Entry point
│   ├── router/             # Vue Router configuration
│   │   └── index.ts
│   ├── views/              # Page components
│   │   ├── HomeView.vue
│   │   ├── DownloadsView.vue
│   │   └── FeaturesView.vue
│   ├── components/
│   │   └── layout/         # Layout components
│   │       ├── AppHeader.vue
│   │       ├── AppFooter.vue
│   │       └── MainLayout.vue
│   └── style.css           # Global styles
├── index.html              # HTML template
├── vite.config.ts          # Vite configuration
├── tailwind.config.js      # Tailwind CSS configuration
└── package.json
```

---

## Download System

The landing page includes an automated download management system:

### How Downloads Work

1. **Release Builds**: When a version tag is pushed, GitHub Actions builds all platforms
2. **Artifact Storage**: Build artifacts are committed to `landing/public/downloads/[version]/`
3. **Manifest Update**: `manifest.json` is updated with new version info
4. **GitHub Release**: Official release created with all artifacts attached
5. **Download Links**: Landing page displays links to both GitHub Releases and local LFS files

### Download URLs

Download URLs in `src/views/DownloadsView.vue` point to GitHub releases:
```
https://github.com/xicv/recogniz.ing/releases/download/v{VERSION}/recognizing-{VERSION}-{platform}.zip
```

### Supported Platforms

| Platform | File Format | Code Signing |
|----------|-------------|--------------|
| macOS | `.zip` (app bundle) | ✅ Signed & Notarized |
| Windows | `.zip` (portable) | Planned |
| Linux | `.tar.gz` | N/A |
| Android | `.apk`, `.aab` | Planned |
| Web | `.zip` | N/A |

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
