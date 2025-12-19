# Recogniz.ing Landing Page

A modern, minimalist landing page for the Recogniz.ing AI voice typing application.

## About Recogniz.ing

Recogniz.ing is an AI-powered voice typing application built with Flutter that:
- Transcribes voice recordings in real-time using Google's Gemini AI
- Supports cross-platform deployment (macOS, Windows, Linux, iOS, Android, Web)
- Features smart voice activity detection and audio analysis
- Offers customizable prompts and vocabulary for specialized domains
- Provides Material Design 3 UI with dark/light theme support

## Tech Stack

- **Vue 3.5+** with Composition API and `<script setup>`
- **Vite 7.0** for ultra-fast development and building
- **Tailwind CSS 3.4** for utility-first styling
- **TypeScript** for type safety
- **Lucide Icons** for beautiful, minimal icons

## Features

- ✨ Minimalist, clean design with beautiful typography
- 📱 Fully responsive design
- 🚀 Lightning fast loading with Vite 7
- 🎨 Smooth animations and transitions
- ♿ Accessibility-first approach
- 🔍 SEO optimized meta tags
- 📦 PWA ready with service worker
- 🔗 Links to app downloads and documentation
- 📦 **Download Management**: Automated platform-specific downloads with semantic versioning
- 📋 **Version Manifest**: JSON-based download system with version tracking (manifest.json)
- 🔄 **CI/CD Integration**: Automated build and deployment pipeline with Makefile support
- 🔐 **Code Signing**: macOS builds support code signing and notarization
- 📱 **Cross-Platform Downloads**: Support for macOS, Windows, Linux, Android, and Web platforms

## Getting Started

### Prerequisites
- Node.js 18+ (required for Vite 7)
- npm or pnpm

### Installation

```bash
# Clone the repository
git clone [repository-url]
cd landing

# Install dependencies
npm install

# Start development server
npm run dev
```

### Build for Production

```bash
# Build the project
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
landing/
├── public/              # Static assets
│   └── downloads/       # Platform-specific app downloads
│       └── manifest.json # Version manifest for downloads
├── src/
│   ├── App.vue          # Main component
│   ├── main.ts          # Entry point
│   └── style.css        # Global styles
├── index.html           # HTML template
├── downloads.html       # Standalone download page
├── tailwind.config.js
├── vite.config.ts
└── package.json
```

### Download System

The landing page includes an automated download management system:
- Apps are built and placed in versioned directories (`public/downloads/vX.X.X/`)
- Each platform has its own folder (macos, windows, linux, android, web)
- `manifest.json` tracks current version and download paths
- Downloads page dynamically loads version information from manifest
- Supports semantic versioning (MAJOR.MINOR.PATCH) without build numbers
- Automated through Makefile targets (`make deploy-all`, `make release`)
- Version bumping tools available (Dart script, shell script, Makefile)

#### Build Artifacts
- **macOS**: Signed .app bundle and .dmg installer (with code signing support)
- **Windows**: Portable executable in .zip archive
- **Linux**: Tar.gz archive for distribution
- **Android**: Both APK and AAB formats for flexibility
- **Web**: Complete web build in .zip archive

## Design Principles

1. **Minimalism** - Clean layout with ample white space
2. **Clarity** - Clear typography hierarchy
3. **Performance** - Optimized for fast loading
4. **Accessibility** - Semantic HTML and ARIA labels
5. **Mobile-first** - Responsive design approach

## Customization

- Colors and fonts are configured in `tailwind.config.js`
- Adjust content in `src/App.vue`
- Meta tags in `index.html`

## License

MIT License - feel free to use this as a template for your own projects.