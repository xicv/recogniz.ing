<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useScrollAnimations } from '@/composables/useScrollAnimations'
import { getVersion, getDownloadUrl } from '@/version'

// Initialize scroll animations
useScrollAnimations()

interface Platform {
  name: string
  icon: string
  version: string
  releaseDate: string
  downloadUrl: string
  changelog: string[]
  requirements?: string
  color?: string
  viewBox?: string
  bg?: string
}

// Platform base data (static parts)
const platformBaseData: Omit<Platform, 'version' | 'downloadUrl'>[] = [
  {
    name: 'Android',
    icon: 'M6.382 3.968A8.962 8.962 0 0 1 12 2c2.125 0 4.078.736 5.618 1.968l1.453-1.453 1.414 1.414-1.453 1.453A8.962 8.962 0 0 1 21 11v1H3v-1c0-2.125.736-4.078 1.968-5.618L3.515 3.93l1.414-1.414 1.453 1.453zM3 14h18v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7zm6-5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm6 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2z',
    releaseDate: '2025-12-31',
    changelog: [
      'Standalone APK - no Google Play required',
      'Works on Android 8.0+ (API 26)',
      'Optimized for both phones and tablets'
    ],
    requirements: 'Android 8.0+ (API 26)',
    color: 'emerald'
  },
  {
    name: 'macOS',
    icon: 'M15.11 2.68 C16.03 1.59 16.68 0.11 16.51 0 C15.19 0.05 13.60 0.85 12.64 1.94 C11.79 2.89 11.04 4.39 11.24 5.85 C12.71 5.96 14.20 5.13 15.11 2.68 M17.54 10.82 C17.58 14.56 20.99 15.82 21.03 15.84 C21.00 15.92 20.49 17.66 19.24 19.45 C18.16 20.97 17.02 22.46 15.19 22.49 C13.40 22.52 12.84 21.50 10.83 21.50 C8.84 21.50 8.22 22.49 6.51 22.49 C4.77 22.55 3.46 20.84 2.36 19.46 C0.09 16.42 -1.66 10.88 0.63 7.08 C1.80 5.17 3.85 4 5.99 3.97 C7.70 3.94 9.31 5.06 10.35 5.06 C11.39 5.06 13.31 3.86 15.36 4.06 C16.23 4.09 18.63 4.39 20.20 6.51 C20.09 6.58 17.34 8.12 17.37 11.18 C17.40 14.25 20.81 15.30 20.85 15.32 C20.82 15.39 20.31 17.13 19.06 18.92 C17.98 20.44 16.84 21.93 15.01 21.96 C13.22 21.99 12.66 20.97 10.65 20.97 C8.66 20.97 8.04 21.96 6.33 21.96 C4.59 22.02 3.28 20.31 2.18 18.93 C-0.09 15.89 -1.84 10.35 0.45 6.55 C1.62 4.64 3.67 3.47 5.81 3.44 C7.52 3.41 9.13 4.53 10.17 4.53 C11.21 4.53 13.13 3.33 15.18 3.53 C16.05 3.56 18.45 3.86 20.02 5.98 C19.91 6.05 17.16 7.59 17.19 10.65',
    releaseDate: '2025-12-31',
    changelog: [
      'User preferences with persistent desktop settings',
      'Desktop-specific features: auto-start, minimize to tray',
      'VAD modal UI fixes and audio processing improvements'
    ],
    requirements: 'macOS 10.15 or later',
    color: 'slate',
    bg: 'bg-slate-100 dark:bg-slate-700'
  },
  {
    name: 'Windows',
    icon: 'M3 12V6.7L9 5.4v6.5L3 12M20 3v8.8L10 11.9V5.2L20 3M3 13l6 .1V19.9L3 18.7V13m17 .3V22L10 20.1v-7',
    releaseDate: '2025-12-31',
    changelog: [
      'Native installer with automatic updates',
      'System tray and global hotkeys support',
      'Same features as macOS version'
    ],
    requirements: 'Windows 10 or later',
    color: 'sky'
  },
  {
    name: 'Linux',
    icon: 'M4 17h16a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2zM8 7h8v2H8V7zm0 4h8v2H8v-2z',
    releaseDate: '2025-12-31',
    changelog: [
      'Portable AppImage format',
      'Same features as macOS and Windows',
      'Tested on Ubuntu 18.04+'
    ],
    requirements: 'Ubuntu 18.04 or later',
    color: 'amber'
  }
]

// Computed platforms with dynamic version and download URLs
const platforms = computed<Platform[]>(() => {
  const currentVersion = getVersion()
  return platformBaseData.map((platform) => {
    let downloadUrl = '#'
    let ext = 'zip'

    if (platform.name === 'Android') {
      ext = 'apk'
    } else if (platform.name === 'Windows') {
      ext = 'exe'
    }

    // Android is "coming soon", others are available
    if (platform.name !== 'Android') {
      downloadUrl = getDownloadUrl(platform.name.toLowerCase(), ext)
    }

    return {
      ...platform,
      version: currentVersion,
      downloadUrl
    }
  })
})

const selectedPlatform = ref<Platform | null>(null)

const downloadPlatform = (platform: Platform) => {
  selectedPlatform.value = platform
  // Only download if the platform is available (not "#")
  if (platform.downloadUrl !== '#') {
    window.open(platform.downloadUrl, '_blank')
  }
}

// Color mapping for platforms
const platformColors = {
  emerald: {
    bg: 'bg-emerald-100 dark:bg-emerald-900/50',
    text: 'text-emerald-600 dark:text-emerald-400',
    border: 'border-emerald-200 dark:border-emerald-800'
  },
  slate: {
    bg: 'bg-slate-100 dark:bg-slate-800',
    text: 'text-slate-600 dark:text-slate-400',
    border: 'border-slate-200 dark:border-slate-700'
  },
  sky: {
    bg: 'bg-sky-100 dark:bg-sky-900/50',
    text: 'text-sky-600 dark:text-sky-400',
    border: 'border-sky-200 dark:border-sky-800'
  },
  amber: {
    bg: 'bg-amber-100 dark:bg-amber-900/50',
    text: 'text-amber-600 dark:text-amber-400',
    border: 'border-amber-200 dark:border-amber-800'
  }
}

const getPlatformColor = (color?: string) => {
  return platformColors[color || 'slate'] || platformColors.slate
}
</script>

<template>
  <div>
    <!-- Hero Section -->
    <section
      class="pt-24 sm:pt-32 pb-16 lg:pb-24 section-padding bg-gradient-to-br from-slate-50 to-white dark:from-slate-900 dark:to-[#0a0a0a] transition-colors duration-300"
    >
      <div class="container-custom text-center">
        <div class="max-w-4xl mx-auto">
          <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-6 scroll-reveal-scale bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
            DOWNLOAD
          </span>
          <h1
            class="text-4xl sm:text-5xl lg:text-6xl font-semibold mb-6 tracking-tight text-slate-950 dark:text-slate-50 transition-colors duration-300 scroll-reveal"
            style="font-size: clamp(2.5rem, 2rem + 2.5vw, 4.5rem); line-height: 1.1;"
          >
            Download
            <span class="gradient-text-accent">Recogniz.ing</span>
          </h1>
          <p
            class="text-lg sm:text-xl mb-8 text-slate-600 dark:text-slate-400 transition-colors duration-300 scroll-reveal"
          >
            Free AI-powered voice typing. Available for all platforms.
          </p>
        </div>
      </div>
    </section>

    <!-- Platform Downloads -->
    <section class="py-16 lg:py-24 section-padding relative overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-slate-50/50 to-transparent dark:via-slate-900/30 pointer-events-none" />

      <div class="container-custom relative z-10">
        <div class="max-w-6xl mx-auto">
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            <div
              v-for="platform in platforms"
              :key="platform.name"
              class="group rounded-3xl border bg-white dark:bg-slate-800 transition-all duration-300 overflow-hidden scroll-reveal hover:shadow-2xl hover:-translate-y-2 platform-card-enhanced"
              :class="getPlatformColor(platform.color).border"
            >
              <!-- Platform Icon - Enhanced with glow -->
              <div
                class="p-6 sm:p-8 text-center border-b border-slate-100 dark:border-slate-700 transition-colors duration-300 relative"
              >
                <!-- Glow effect on hover -->
                <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none">
                  <div class="absolute inset-0 bg-gradient-to-br from-sky-500/5 to-violet-500/5" />
                </div>

                <div class="w-16 h-16 mx-auto mb-4 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg relative"
                  :class="platform.bg || getPlatformColor(platform.color).bg"
                >
                  <svg
                    :viewBox="platform.viewBox || '0 0 24 24'"
                    fill="currentColor"
                    class="w-8 h-8 transition-colors duration-300 relative z-10"
                    :class="getPlatformColor(platform.color).text"
                  >
                    <path :d="platform.icon"/>
                  </svg>
                </div>
                <h3
                  class="text-xl sm:text-2xl font-semibold mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-sky-600 dark:group-hover:text-sky-400"
                >
                  {{ platform.name }}
                </h3>
                <p
                  class="text-sm text-slate-500 dark:text-slate-400 transition-colors duration-300"
                >
                  v{{ platform.version }}
                </p>
                <span
                  v-if="platform.downloadUrl === '#'"
                  class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium mt-3 bg-slate-100 text-slate-500 dark:bg-slate-700 dark:text-slate-400"
                >
                  Coming Soon
                </span>
                <span
                  v-else
                  class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium mt-3 bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-400 shadow-sm"
                >
                  <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                  </svg>
                  Available Now
                </span>
              </div>

              <!-- Download Button - Enhanced -->
              <div class="p-6 sm:p-8">
                <button
                  @click="downloadPlatform(platform)"
                  :disabled="platform.downloadUrl === '#'"
                  class="w-full px-6 py-4 rounded-xl font-medium transition-all duration-300 mb-4 text-white flex items-center justify-center gap-2.5 min-h-[52px] sm:min-h-[48px] group/btn relative overflow-hidden"
                  :class="[
                    platform.downloadUrl === '#'
                      ? 'bg-slate-200 text-slate-400 cursor-not-allowed'
                      : 'bg-slate-900 hover:bg-slate-800 dark:bg-gradient-to-r dark:from-sky-500 dark:to-cyan-500 dark:hover:from-sky-400 dark:hover:to-cyan-400 hover:scale-105 hover:shadow-xl'
                  ]"
                >
                  <svg v-if="platform.downloadUrl !== '#'" class="w-5 h-5 transition-transform group-hover/btn:translate-y-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                  </svg>
                  {{ platform.downloadUrl === '#' ? 'Coming Soon' : 'Download' }}
                </button>

                <!-- Requirements -->
                <div
                  class="text-sm text-slate-600 dark:text-slate-400 text-center transition-colors duration-300"
                >
                  {{ platform.requirements }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Installation Instructions - Enhanced -->
    <section
      class="py-16 lg:py-24 section-padding bg-slate-50 dark:bg-slate-900/30 transition-colors duration-300 relative overflow-hidden"
    >
      <!-- Decorative background -->
      <div class="absolute top-0 right-0 w-96 h-96 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full blur-3xl pointer-events-none" />

      <div class="container-custom relative z-10">
        <div class="max-w-4xl mx-auto">
          <div class="text-center mb-12 scroll-reveal">
            <span class="inline-block px-4 py-1.5 rounded-full text-xs font-semibold mb-4 bg-slate-100/80 backdrop-blur text-slate-600 border border-slate-200 dark:bg-slate-800/80 dark:border-slate-700 dark:text-slate-400">
              INSTALLATION
            </span>
            <h2
              class="text-3xl sm:text-4xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
            >
              Installation Instructions
            </h2>
            <p class="text-lg text-slate-600 dark:text-slate-400">
              Get up and running in just a few minutes
            </p>
          </div>

          <!-- Step Cards - Enhanced -->
          <div class="space-y-6">
            <!-- Step 1: API Key -->
            <div class="card shimmer scroll-reveal group">
              <div class="flex items-start gap-6">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-sky-500 to-cyan-500 flex items-center justify-center text-white font-bold text-lg shadow-lg group-hover:scale-110 transition-transform">
                  1
                </div>
                <div class="flex-1">
                  <h3
                    class="text-xl font-semibold mb-2 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-sky-600 dark:group-hover:text-sky-400"
                  >
                    Get Your Free API Key
                  </h3>
                  <p
                    class="mb-4 text-slate-600 dark:text-slate-400 transition-colors duration-300"
                  >
                    Get your free Gemini API key from Google AI Studio. The app will not work without an API key.
                  </p>
                  <a
                    href="https://aistudio.google.com/app/apikey"
                    target="_blank"
                    rel="noopener"
                    class="inline-flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all bg-slate-900 text-white hover:bg-slate-800 dark:bg-gradient-to-r dark:from-sky-500 dark:to-cyan-500 dark:hover:from-sky-400 dark:hover:to-cyan-400 hover:shadow-lg min-h-[48px] group/btn"
                  >
                    <svg class="w-5 h-5 transition-transform group-hover/btn:translate-y-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                    </svg>
                    Get API Key
                  </a>
                </div>
              </div>
            </div>

            <!-- Step 2: Download & Install - Enhanced -->
            <div class="card shimmer scroll-reveal group">
              <div class="flex items-start gap-6">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-violet-500 to-purple-500 flex items-center justify-center text-white font-bold text-lg shadow-lg group-hover:scale-110 transition-transform">
                  2
                </div>
                <div class="flex-1">
                  <h3
                    class="text-xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-violet-600 dark:group-hover:text-violet-400"
                  >
                    Download & Install
                  </h3>

                  <!-- Installation details by platform - Enhanced cards -->
                  <div class="grid sm:grid-cols-2 gap-4">
                    <!-- Android -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 group-hover:border-emerald-300 dark:group-hover:border-emerald-700 transition-colors">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-emerald-500" fill="currentColor">
                          <path d="M6.382 3.968A8.962 8.962 0 0 1 12 2c2.125 0 4.078.736 5.618 1.968l1.453-1.453 1.414 1.414-1.453 1.453A8.962 8.962 0 0 1 21 11v1H3v-1c0-2.125.736-4.078 1.968-5.618L3.515 3.93l1.414-1.414 1.453 1.453zM3 14h18v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7z"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">Android</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1.5 list-decimal list-inside">
                        <li>Download the APK file</li>
                        <li>Enable "Install from unknown sources"</li>
                        <li>Open the APK and tap "Install"</li>
                      </ol>
                    </div>

                    <!-- macOS -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 group-hover:border-slate-400 dark:group-hover:border-slate-600 transition-colors">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-slate-500" fill="currentColor">
                          <path d="M18.7 19.5c-.8 1.2-1.7 2.5-3 2.5-1.3 0-1.8-.8-3.3-.8-1.5 0-2 .8-3.3.8-1.3 0-2.3-1.3-3.1-2.5C4.2 17 2.9 12.5 4.7 9.4c.9-1.5 2.4-2.5 4.1-2.5 1.3 0 2.5.9 3.3.9.8 0 2.3-1.1 3.8-.9.6.03 2.5.3 3.6 2-.1.06-2.2 1.3-2.1 3.8.03 3 2.6 4 2.7 4-.03.07-.4 1.4-1.4 2.8M13 3.5c.7-.8 1.9-1.5 2.9-1.5.1 1.2-.3 2.4-1 3.2-.7.8-1.8 1.5-2.9 1.4-.1-1.1.4-2.4 1.1-3.1z"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">macOS</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1.5 list-decimal list-inside">
                        <li>Download and unzip the file</li>
                        <li>Drag to Applications folder</li>
                        <li>Right-click → Open (if blocked)</li>
                      </ol>
                    </div>

                    <!-- Windows -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 group-hover:border-sky-300 dark:group-hover:border-sky-700 transition-colors">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-sky-500" fill="currentColor">
                          <path d="M3 12V6.7L9 5.4v6.5L3 12M20 3v8.8L10 11.9V5.2L20 3M3 13l6 .1V19.9L3 18.7V13m17 .3V22L10 20.1v-7"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">Windows</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1.5 list-decimal list-inside">
                        <li>Download the .exe installer</li>
                        <li>Run as Administrator</li>
                        <li>Follow the wizard</li>
                      </ol>
                    </div>

                    <!-- Linux -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 group-hover:border-amber-300 dark:group-hover:border-amber-700 transition-colors">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-amber-500" fill="currentColor">
                          <path d="M12 2C6.477 2 2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.879V14.89h-2.896v-2.896h2.896V9.466c0-2.889 1.723-4.486 4.351-4.486 1.263 0 2.533.102 2.533.102v2.72h-1.425c-1.406 0-1.843.872-1.843 1.767v2.012h3.289l-.528 2.896h-2.761v6.989C18.343 21.128 22 16.991 22 12c0-5.523-4.477-10-10-10z"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">Linux</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1.5 list-decimal list-inside">
                        <li>Download the .AppImage</li>
                        <li>Make executable: <code class="text-xs px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-900 font-mono">chmod +x</code></li>
                        <li>Run the AppImage</li>
                      </ol>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Step 3: Setup - Enhanced -->
            <div class="card shimmer scroll-reveal group">
              <div class="flex items-start gap-6">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-500 flex items-center justify-center text-white font-bold text-lg shadow-lg group-hover:scale-110 transition-transform">
                  3
                </div>
                <div class="flex-1">
                  <h3
                    class="text-xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-emerald-600 dark:group-hover:text-emerald-400"
                  >
                    Setup & Start Recording
                  </h3>
                  <div class="grid sm:grid-cols-2 gap-4">
                    <div class="flex items-start gap-3 group">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5 group-hover:scale-110 transition-transform">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Launch the app</span>
                    </div>
                    <div class="flex items-start gap-3 group">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5 group-hover:scale-110 transition-transform">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Go to Settings tab</span>
                    </div>
                    <div class="flex items-start gap-3 group">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5 group-hover:scale-110 transition-transform">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Enter your Gemini API key</span>
                    </div>
                    <div class="flex items-start gap-3 group">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5 group-hover:scale-110 transition-transform">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Start recording!</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Changelog -->
    <section class="py-16 lg:py-24 section-padding">
      <div class="container-custom">
        <div class="max-w-4xl mx-auto">
          <div class="text-center mb-12 scroll-reveal">
            <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
              CHANGELOG
            </span>
            <h2
              class="text-3xl sm:text-4xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
            >
              What's New
            </h2>
            <p class="text-lg text-slate-600 dark:text-slate-400">
              Track the latest features and improvements
            </p>
          </div>

          <!-- Version cards -->
          <div class="space-y-6">
            <!-- v1.13.0 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-sky-500 to-cyan-500 flex items-center justify-center">
                    <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    </svg>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.13.0
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      January 15, 2026
                    </p>
                  </div>
                </div>
                <span class="px-3 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-400">
                  Latest
                </span>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-emerald-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  ML-based Voice Activity Detection with Silero VAD (~95% accuracy)
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-emerald-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  50% reduction in API calls through optimized single-call transcription
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-emerald-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Token-efficient prompts reducing overhead by ~67%
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-emerald-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Support for up to 3.5 hours of audio per request (100MB inline limit)
                </li>
              </ul>
            </div>

            <!-- v1.12.1 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                    <span class="text-xl font-bold text-slate-500 dark:text-slate-400">1.12.1</span>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.12.1
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      January 13, 2026
                    </p>
                  </div>
                </div>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Automated version bump and release workflow
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Landing page version now syncs automatically with app version
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  GitHub release notes now use CHANGELOG.json data
                </li>
              </ul>
            </div>

            <!-- v1.12.0 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                    <span class="text-xl font-bold text-slate-500 dark:text-slate-400">1.12.0</span>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.12.0
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      January 12, 2026
                    </p>
                  </div>
                </div>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Multi-language transcription support with automatic language detection
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Language selector in Settings with 20+ supported languages
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Detected language display on transcription cards
                </li>
              </ul>
            </div>

            <!-- v1.11.0 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                    <span class="text-xl font-bold text-slate-500 dark:text-slate-400">1.11.0</span>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.11.0
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      December 31, 2025
                    </p>
                  </div>
                </div>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Complete app logo redesign with bold 'R' for Recogniz.ing
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Red recording dot positioned at end of R's right leg for clear visual metaphor
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  New blue-to-teal-to-emerald gradient conveying trust and reliability
                </li>
              </ul>
            </div>

            <!-- v1.10.0 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                    <span class="text-xl font-bold text-slate-500 dark:text-slate-400">1.10.0</span>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.10.0
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      December 31, 2025
                    </p>
                  </div>
                </div>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Transcription status tracking with pending, processing, completed, failed states
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Audio backup functionality for retrying failed transcriptions
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Enhanced error tracking with retry count and completion timestamps
                </li>
              </ul>
            </div>

            <!-- v1.0.4 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                    <span class="text-xl font-bold text-slate-500 dark:text-slate-400">1.0.4</span>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.0.4
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      December 23, 2025
                    </p>
                  </div>
                </div>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  User preferences with persistent desktop settings
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Desktop-specific features: auto-start, minimize to tray
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  VAD modal UI fixes and audio processing improvements
                </li>
              </ul>
            </div>

            <!-- v1.0.3 -->
            <div class="card scroll-reveal">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-14 h-14 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                    <span class="text-xl font-bold text-slate-500 dark:text-slate-400">1.0.3</span>
                  </div>
                  <div>
                    <h3
                      class="text-2xl font-semibold text-slate-950 dark:text-slate-50 transition-colors duration-300"
                    >
                      Version 1.0.3
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      December 21, 2025
                    </p>
                  </div>
                </div>
              </div>
              <ul class="space-y-3">
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Fixed macOS Gatekeeper verification issues
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Improved app signing and security
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-slate-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  Initial Windows release with native installer
                </li>
              </ul>
            </div>
          </div>

          <!-- View all changelogs link -->
          <div class="text-center mt-12">
            <RouterLink
              to="/changelog"
              class="inline-flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all border border-slate-200 hover:border-slate-300 text-slate-700 dark:border-slate-700 dark:text-slate-300 dark:hover:border-slate-600 min-h-[48px]"
            >
              View Full Changelog
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"/>
              </svg>
            </RouterLink>
          </div>
        </div>
      </div>
    </section>

    <!-- Support Section -->
    <section
      class="py-16 lg:py-24 section-padding bg-slate-50 dark:bg-slate-900/30 transition-colors duration-300"
    >
      <div class="container-custom text-center">
        <div class="max-w-3xl mx-auto">
          <h2
            class="text-3xl sm:text-4xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
          >
            Need Help?
          </h2>
          <p
            class="text-lg mb-8 text-slate-600 dark:text-slate-400 transition-colors duration-300"
          >
            Check our documentation or report issues on GitHub
          </p>
          <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
            <a
              href="https://github.com/xicv/recogniz.ing"
              target="_blank"
              rel="noopener"
              class="inline-flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all bg-slate-900 text-white hover:bg-slate-800 dark:bg-sky-500 dark:hover:bg-sky-400 min-h-[48px]"
            >
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.911 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
              View on GitHub
            </a>
            <a
              href="https://github.com/xicv/recogniz.ing/issues"
              target="_blank"
              rel="noopener"
              class="inline-flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all border border-slate-200 hover:border-slate-300 text-slate-700 dark:border-slate-700 dark:text-slate-300 dark:hover:border-slate-600 min-h-[48px]"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              Report Issue
            </a>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.scroll-reveal {
  opacity: 0;
  transform: translateY(30px);
  transition: opacity 0.8s var(--ease-out-expo),
              transform 0.8s var(--ease-out-expo);
}

.scroll-reveal.visible {
  opacity: 1;
  transform: translateY(0);
}

.scroll-reveal-scale {
  opacity: 0;
  transform: scale(0.9);
  transition: opacity 0.6s var(--ease-spring),
              transform 0.6s var(--ease-spring);
}

.scroll-reveal-scale.visible {
  opacity: 1;
  transform: scale(1);
}

/* Tabular numbers */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .scroll-reveal,
  .scroll-reveal-scale {
    opacity: 1;
    transform: none;
    transition: none;
  }
}
</style>
