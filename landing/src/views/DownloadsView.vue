<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimations } from '@/composables/useScrollAnimations'

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
}

const platforms = ref<Platform[]>([
  {
    name: 'Android',
    icon: 'M6.382 3.968A8.962 8.962 0 0 1 12 2c2.125 0 4.078.736 5.618 1.968l1.453-1.453 1.414 1.414-1.453 1.453A8.962 8.962 0 0 1 21 11v1H3v-1c0-2.125.736-4.078 1.968-5.618L3.515 3.93l1.414-1.414 1.453 1.453zM3 14h18v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7zm6-5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm6 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2z',
    version: '1.0.8',
    releaseDate: '2025-12-29',
    downloadUrl: 'https://github.com/xicv/recogniz.ing/releases/download/v1.0.8/recognizing-1.0.8.apk',
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
    icon: 'M18.7 19.5c-.8 1.2-1.7 2.5-3 2.5-1.3 0-1.8-.8-3.3-.8-1.5 0-2 .8-3.3.8-1.3 0-2.3-1.3-3.1-2.5C4.2 17 2.9 12.5 4.7 9.4c.9-1.5 2.4-2.5 4.1-2.5 1.3 0 2.5.9 3.3.9.8 0 2.3-1.1 3.8-.9.6.03 2.5.3 3.6 2-.1.06-2.2 1.3-2.1 3.8.03 3 2.6 4 2.7 4-.03.07-.4 1.4-1.4 2.8M13 3.5c.7-.8 1.9-1.5 2.9-1.5.1 1.2-.3 2.4-1 3.2-.7.8-1.8 1.5-2.9 1.4-.1-1.1.4-2.4 1.1-3.1z',
    version: '1.0.8',
    releaseDate: '2025-12-29',
    downloadUrl: 'https://github.com/xicv/recogniz.ing/releases/download/v1.0.8/recognizing-1.0.8-macos.zip',
    changelog: [
      'User preferences with persistent desktop settings',
      'Desktop-specific features: auto-start, minimize to tray',
      'VAD modal UI fixes and audio processing improvements'
    ],
    requirements: 'macOS 10.15 or later',
    color: 'slate'
  },
  {
    name: 'Windows',
    icon: 'M3 12V6.7L9 5.4v6.5L3 12M20 3v8.8L10 11.9V5.2L20 3M3 13l6 .1V19.9L3 18.7V13m17 .3V22L10 20.1v-7',
    version: '1.0.8',
    releaseDate: '2025-12-29',
    downloadUrl: 'https://github.com/xicv/recogniz.ing/releases/download/v1.0.8/recognizing-1.0.8-windows.exe',
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
    icon: 'M4.53918 2.40715C4.82145 1.0075 6.06066 0 7.49996 0C8.93926 0 10.1785 1.0075 10.4607 2.40715L10.798 4.07944C10.9743 4.9539 11.3217 5.78562 11.8205 6.52763L12.4009 7.39103C12.7631 7.92978 12.9999 8.5385 13.0979 9.17323C13.6747 9.22167 14.1803 9.58851 14.398 10.1283L14.8897 11.3474C15.1376 11.962 14.9583 12.665 14.4455 13.0887L12.5614 14.6458C12.0128 15.0992 11.2219 15.1193 10.6506 14.6944L9.89192 14.1301C9.88189 14.1227 9.87197 14.1151 9.86216 14.1074C9.48973 14.2075 9.09793 14.261 8.69355 14.261H6.30637C5.90201 14.261 5.51023 14.2076 5.13782 14.1074C5.12802 14.1151 5.11811 14.1227 5.10808 14.1301L4.34942 14.6944C3.77811 15.1193 2.98725 15.0992 2.43863 14.6458L0.55446 13.0887C0.0417175 12.665 -0.1376 11.962 0.110281 11.3474L0.602025 10.1283C0.819715 9.58854 1.32527 9.2217 1.90198 9.17324C2 8.5385 2.2368 7.92978 2.59897 7.39103L3.17938 6.52763C3.67818 5.78562 4.02557 4.9539 4.20193 4.07944L4.53918 2.40715ZM10.8445 9.47585C10.6345 9.63293 10.4642 9.84382 10.3561 10.0938L9.58799 11.8713C9.20026 12.0979 8.75209 12.2237 8.28465 12.2237H6.7153C6.24789 12.2237 5.79975 12.0979 5.41203 11.8714L4.64386 10.0938C4.53581 9.8438 4.36552 9.6329 4.15546 9.47582C4.18121 9.15355 4.2689 8.83503 4.41853 8.53826L5.67678 6.04259L5.68433 6.05007C6.68715 7.04458 8.31304 7.04458 9.31585 6.05007L9.32324 6.04274L10.5814 8.53825C10.7311 8.83504 10.8187 9.15357 10.8445 9.47585ZM9.04068 4.26906V3.05592H8.01353V3.85713C8.23151 3.90123 8.44506 3.97371 8.64848 4.07458L9.04068 4.26906ZM6.98638 3.85718V3.05592H5.95923V4.26919L6.3517 4.07458C6.55504 3.97375 6.7685 3.90129 6.98638 3.85718ZM2.03255 10.1864C1.82255 10.1864 1.6337 10.3132 1.55571 10.5066L1.06397 11.7257C0.981339 11.9306 1.04111 12.1649 1.21203 12.3062L3.0962 13.8633C3.27907 14.0144 3.54269 14.0211 3.73313 13.8795L4.49179 13.3152C4.6813 13.1743 4.74901 12.923 4.6557 12.7071L3.69976 10.4951C3.61884 10.3078 3.43316 10.1864 3.22771 10.1864H2.03255ZM13.4443 10.5066C13.3663 10.3132 13.1775 10.1864 12.9674 10.1864H11.7723C11.5668 10.1864 11.3812 10.3078 11.3002 10.4951L10.3443 12.7071C10.251 12.923 10.3187 13.1743 10.5082 13.3152L11.2669 13.8795C11.4573 14.0211 11.7209 14.0144 11.9038 13.8633L13.788 12.3062C13.9589 12.1649 14.0187 11.9306 13.936 11.7257L13.4443 10.5066ZM6.81106 4.98568C7.24481 4.7706 7.75537 4.7706 8.18912 4.98568L8.68739 5.23275L8.58955 5.32978C7.98786 5.92649 7.01232 5.92649 6.41063 5.32978L6.31279 5.23275L6.81106 4.98568Z',
    version: '1.0.8',
    releaseDate: '2025-12-29',
    downloadUrl: 'https://github.com/xicv/recogniz.ing/releases/download/v1.0.8/recognizing-1.0.8-linux.tar.gz',
    changelog: [
      'Portable AppImage format',
      'Same features as macOS and Windows',
      'Tested on Ubuntu 18.04+'
    ],
    requirements: 'Ubuntu 18.04 or later',
    color: 'amber'
  }
])

const selectedPlatform = ref<Platform | null>(null)
const animatedDownloadCount = ref(0)
const targetDownloadCount = 150000

onMounted(() => {
  // Animate download count
  const duration = 2000
  const startTime = performance.now()
  const startValue = 0

  const animateCount = (currentTime: number) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / duration, 1)
    const easeProgress = 1 - Math.pow(1 - progress, 4) // easeOutQuart

    animatedDownloadCount.value = Math.floor(startValue + (targetDownloadCount - startValue) * easeProgress)

    if (progress < 1) {
      requestAnimationFrame(animateCount)
    }
  }

  requestAnimationFrame(animateCount)
})

const formatDownloadCount = (count: number) => {
  if (count >= 1000) {
    return (count / 1000).toFixed(0) + 'K+'
  }
  return count.toLocaleString()
}

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
          <div
            class="flex items-center justify-center gap-3 scroll-reveal"
          >
            <div class="flex items-center gap-2 px-4 py-2 rounded-full bg-slate-100 dark:bg-slate-800 transition-colors duration-300">
              <svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
              </svg>
              <span class="font-medium tabular-nums">{{ formatDownloadCount(animatedDownloadCount) }}</span>
            </div>
            <span class="text-slate-500 dark:text-slate-400">downloads and counting</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Platform Downloads -->
    <section class="py-16 lg:py-24 section-padding">
      <div class="container-custom">
        <div class="max-w-6xl mx-auto">
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            <div
              v-for="platform in platforms"
              :key="platform.name"
              class="group rounded-3xl border bg-white dark:bg-slate-800 hover:border-slate-300 dark:hover:border-slate-600 transition-all duration-300 overflow-hidden scroll-reveal hover:shadow-xl hover:-translate-y-1"
              :class="getPlatformColor(platform.color).border"
            >
              <!-- Platform Icon -->
              <div
                class="p-6 sm:p-8 text-center border-b border-slate-100 dark:border-slate-700 transition-colors duration-300"
              >
                <div class="w-16 h-16 mx-auto mb-4 rounded-2xl flex items-center justify-center transition-colors duration-300"
                  :class="getPlatformColor(platform.color).bg"
                >
                  <svg
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    class="w-8 h-8 transition-colors duration-300"
                    :class="getPlatformColor(platform.color).text"
                  >
                    <path :d="platform.icon"/>
                  </svg>
                </div>
                <h3
                  class="text-xl sm:text-2xl font-semibold mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300"
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
                  class="inline-block px-2 py-1 rounded-full text-xs font-medium mt-2 bg-slate-100 text-slate-500 dark:bg-slate-700 dark:text-slate-400"
                >
                  Coming Soon
                </span>
                <span
                  v-else
                  class="inline-block px-2 py-1 rounded-full text-xs font-medium mt-2 bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-400"
                >
                  Available Now
                </span>
              </div>

              <!-- Download Button -->
              <div class="p-6 sm:p-8">
                <button
                  @click="downloadPlatform(platform)"
                  :disabled="platform.downloadUrl === '#'"
                  class="w-full px-6 py-4 rounded-xl font-medium transition-all duration-300 mb-4 text-white flex items-center justify-center gap-2 min-h-[52px] sm:min-h-[48px]"
                  :class="[
                    platform.downloadUrl === '#'
                      ? 'bg-slate-200 text-slate-400 cursor-not-allowed'
                      : 'bg-slate-900 hover:bg-slate-800 dark:bg-sky-500 dark:hover:bg-sky-400 hover:scale-105 hover:shadow-lg'
                  ]"
                >
                  <svg v-if="platform.downloadUrl !== '#'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

    <!-- Installation Instructions - Accordion Style -->
    <section
      class="py-16 lg:py-24 section-padding bg-slate-50 dark:bg-slate-900/30 transition-colors duration-300"
    >
      <div class="container-custom">
        <div class="max-w-4xl mx-auto">
          <div class="text-center mb-12 scroll-reveal">
            <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
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

          <!-- Step Cards -->
          <div class="space-y-6">
            <!-- Step 1: API Key -->
            <div class="card scroll-reveal">
              <div class="flex items-start gap-6">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-sky-500 to-cyan-500 flex items-center justify-center text-white font-bold text-lg">
                  1
                </div>
                <div class="flex-1">
                  <h3
                    class="text-xl font-semibold mb-2 text-slate-950 dark:text-slate-50 transition-colors duration-300"
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
                    class="inline-flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all bg-slate-900 text-white hover:bg-slate-800 dark:bg-sky-500 dark:hover:bg-sky-400 min-h-[48px]"
                  >
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                    </svg>
                    Get API Key
                  </a>
                </div>
              </div>
            </div>

            <!-- Step 2: Download & Install -->
            <div class="card scroll-reveal">
              <div class="flex items-start gap-6">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-violet-500 to-purple-500 flex items-center justify-center text-white font-bold text-lg">
                  2
                </div>
                <div class="flex-1">
                  <h3
                    class="text-xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
                  >
                    Download & Install
                  </h3>

                  <!-- Installation details by platform -->
                  <div class="grid sm:grid-cols-2 gap-4">
                    <!-- Android -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-emerald-500" fill="currentColor">
                          <path d="M6.382 3.968A8.962 8.962 0 0 1 12 2c2.125 0 4.078.736 5.618 1.968l1.453-1.453 1.414 1.414-1.453 1.453A8.962 8.962 0 0 1 21 11v1H3v-1c0-2.125.736-4.078 1.968-5.618L3.515 3.93l1.414-1.414 1.453 1.453zM3 14h18v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7z"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">Android</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1 list-decimal list-inside">
                        <li>Download the APK file</li>
                        <li>Enable "Install from unknown sources"</li>
                        <li>Open the APK and tap "Install"</li>
                      </ol>
                    </div>

                    <!-- macOS -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-slate-500" fill="currentColor">
                          <path d="M18.7 19.5c-.8 1.2-1.7 2.5-3 2.5-1.3 0-1.8-.8-3.3-.8-1.5 0-2 .8-3.3.8-1.3 0-2.3-1.3-3.1-2.5C4.2 17 2.9 12.5 4.7 9.4c.9-1.5 2.4-2.5 4.1-2.5 1.3 0 2.5.9 3.3.9.8 0 2.3-1.1 3.8-.9.6.03 2.5.3 3.6 2-.1.06-2.2 1.3-2.1 3.8.03 3 2.6 4 2.7 4-.03.07-.4 1.4-1.4 2.8M13 3.5c.7-.8 1.9-1.5 2.9-1.5.1 1.2-.3 2.4-1 3.2-.7.8-1.8 1.5-2.9 1.4-.1-1.1.4-2.4 1.1-3.1z"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">macOS</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1 list-decimal list-inside">
                        <li>Download and unzip the file</li>
                        <li>Drag to Applications folder</li>
                        <li>Right-click → Open (if blocked)</li>
                      </ol>
                    </div>

                    <!-- Windows -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-sky-500" fill="currentColor">
                          <path d="M3 12V6.7L9 5.4v6.5L3 12M20 3v8.8L10 11.9V5.2L20 3M3 13l6 .1V19.9L3 18.7V13m17 .3V22L10 20.1v-7"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">Windows</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1 list-decimal list-inside">
                        <li>Download the .exe installer</li>
                        <li>Run as Administrator</li>
                        <li>Follow the wizard</li>
                      </ol>
                    </div>

                    <!-- Linux -->
                    <div class="p-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
                      <div class="flex items-center gap-3 mb-3">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 text-amber-500" fill="currentColor">
                          <path d="M12 2C6.477 2 2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.879V14.89h-2.896v-2.896h2.896V9.466c0-2.889 1.723-4.486 4.351-4.486 1.263 0 2.533.102 2.533.102v2.72h-1.425c-1.406 0-1.843.872-1.843 1.767v2.012h3.289l-.528 2.896h-2.761v6.989C18.343 21.128 22 16.991 22 12c0-5.523-4.477-10-10-10z"/>
                        </svg>
                        <span class="font-medium text-slate-950 dark:text-slate-50">Linux</span>
                      </div>
                      <ol class="text-sm text-slate-600 dark:text-slate-400 space-y-1 list-decimal list-inside">
                        <li>Download the .AppImage</li>
                        <li>Make executable: <code class="text-xs px-1 rounded bg-slate-100 dark:bg-slate-900">chmod +x</code></li>
                        <li>Run the AppImage</li>
                      </ol>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Step 3: Setup -->
            <div class="card scroll-reveal">
              <div class="flex items-start gap-6">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-500 flex items-center justify-center text-white font-bold text-lg">
                  3
                </div>
                <div class="flex-1">
                  <h3
                    class="text-xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
                  >
                    Setup & Start Recording
                  </h3>
                  <div class="grid sm:grid-cols-2 gap-4">
                    <div class="flex items-start gap-3">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Launch the app</span>
                    </div>
                    <div class="flex items-start gap-3">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Go to Settings tab</span>
                    </div>
                    <div class="flex items-start gap-3">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5">
                        <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                      </div>
                      <span class="text-slate-600 dark:text-slate-400">Enter your Gemini API key</span>
                    </div>
                    <div class="flex items-start gap-3">
                      <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center flex-shrink-0 mt-0.5">
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
            <!-- v1.0.8 -->
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
                      Version 1.0.8
                    </h3>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                      December 29, 2025
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
                  Fixed detached HEAD error when pushing landing downloads
                </li>
                <li class="flex items-start gap-3 text-slate-600 dark:text-slate-400">
                  <svg class="w-5 h-5 text-emerald-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  macOS and Windows downloads now available
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
