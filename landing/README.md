# Recogniz.ing Landing Page

A modern, minimalist landing page for the Recogniz.ing AI voice typing application.

**Live Site**: https://recogniz.ing/
**Repository**: https://github.com/xicv/recogniz.ing

---

## About Recogniz.ing

Recogniz.ing is an AI-powered voice typing application built with Flutter that:
- Transcribes voice recordings using Google Gemini 3 Flash
- Supports cross-platform deployment (macOS, Windows, Linux, iOS, Android, Web)
- Features ML-based voice activity detection (Silero VAD) and audio analysis
- Offers customizable prompts and vocabulary for specialized domains
- Provides Material Design 3 UI with dark/light theme support
- Manages multiple API keys with smart failover and per-key usage tracking

---

## Tech Stack

- **Vue 3.5** with Composition API and `<script setup>` syntax
- **Vite 7.3** for ultra-fast development and optimized builds
- **Tailwind CSS 4.1** for utility-first styling
- **TypeScript 5.8** for type safety
- **Vue Router 5.0** for SPA navigation
- **vite-plugin-pwa 1.2** for Progressive Web App capabilities
- **Lucide Vue Next** for modern icons

---

## Design

- Teal-centric color scheme matching the app icon gradient (deep navy → teal → emerald)
- Dark/light theme with system preference detection
- Fully responsive with mobile-first approach
- WCAG accessible with semantic HTML and focus management
- SEO optimized with structured data, Open Graph, and Twitter Cards

---

## Getting Started

```bash
cd landing
npm install
npm run dev       # Start development server
npm run build     # Build for production
npm run preview   # Preview production build
```

---

## Project Structure

```
landing/
├── public/                  # Static assets
│   ├── downloads/
│   │   └── manifest.json   # Version manifest
│   ├── .nojekyll           # Required for GitHub Pages + Vite
│   ├── app-icon.svg        # Full icon with effects
│   ├── logo.svg            # Logo (same as app-icon)
│   ├── pwa-icon.svg        # PWA icon (simplified)
│   └── masked-icon.svg     # Maskable PWA icon (full-bleed)
├── src/
│   ├── App.vue             # Root component
│   ├── main.ts             # Entry point
│   ├── style.css           # Global styles (accent: teal-500)
│   ├── version.ts          # Version constants
│   ├── router/             # Vue Router configuration
│   ├── composables/        # Shared logic (dark mode, scroll animations)
│   ├── views/              # Page components
│   │   ├── HomeView.vue
│   │   ├── DownloadsView.vue
│   │   ├── FeaturesView.vue
│   │   └── ChangelogView.vue
│   └── components/
│       ├── layout/         # AppHeader, AppFooter, MainLayout
│       └── ui/             # AppPreview
├── index.html              # HTML template with SEO meta tags
├── vite.config.ts          # Vite configuration + PWA plugin
└── package.json
```

---

## Deployment

Part of a single-repository architecture with the Flutter app.

### Automated Flow

1. **Tag Push** → `release-matrix.yml` builds all platform binaries
2. **Manifest Update** → `manifest.json` updated with version info
3. **Landing Deploy** → `landing-deploy.yml` deploys to GitHub Pages

### GitHub Pages Settings

- **Source**: GitHub Actions (not "Deploy from a branch")
- **Custom Domain**: `recogniz.ing`
- **Important**: `.nojekyll` in `public/` is required for Vite builds

---

## License

MIT License
