<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useScrollAnimations } from '@/composables/useScrollAnimations'
import { getVersion, getDownloadUrl } from '@/version'
import {
  Download, ExternalLink, Check, ArrowRight, CircleHelp
} from 'lucide-vue-next'

useScrollAnimations()

interface Platform {
  name: string
  icon: string
  version: string
  downloadUrl: string
  requirements: string
  color: string
  viewBox?: string
}

const platformBaseData = [
  {
    name: 'Android',
    icon: 'M6.382 3.968A8.962 8.962 0 0 1 12 2c2.125 0 4.078.736 5.618 1.968l1.453-1.453 1.414 1.414-1.453 1.453A8.962 8.962 0 0 1 21 11v1H3v-1c0-2.125.736-4.078 1.968-5.618L3.515 3.93l1.414-1.414 1.453 1.453zM3 14h18v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7zm6-5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm6 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2z',
    requirements: 'Android 8.0+ (API 26)',
    color: 'text-emerald-500'
  },
  {
    name: 'macOS',
    icon: 'M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z',
    requirements: 'macOS 10.15 or later',
    color: 'text-slate-500'
  },
  {
    name: 'Windows',
    icon: 'M3,12V6.75L9,5.43v6.48L3,12M20,3v8.75L10,11.97V5.21L20,3M3,13l6,.09V19.9L3,18.75V13m17,.25V22L10,20.09v-7',
    requirements: 'Windows 10 or later',
    color: 'text-teal-500'
  },
  {
    name: 'Linux',
    icon: 'M12.504 0c-.155 0-.315.008-.48.021-4.226.333-3.105 4.807-3.17 6.298-.076 1.092-.3 1.953-1.05 3.02-.885 1.051-2.127 2.75-2.716 4.521-.278.832-.41 1.684-.287 2.489a.424.424 0 0 0-.11.135c-.26.268-.45.6-.663.839-.199.199-.485.267-.797.4-.313.136-.658.269-.864.68-.09.189-.136.394-.132.602 0 .199.027.4.055.536.058.399.116.728.04.97-.249.68-.28 1.145-.106 1.484.174.334.535.47.94.601.81.2 1.91.135 2.774.6.926.466 1.866.67 2.616.47.526-.116.97-.464 1.208-.946.587-.003 1.23-.269 2.26-.334.699-.058 1.574.267 2.577.2.025.134.063.198.114.333l.003.003c.391.778 1.113 1.132 1.884 1.071.771-.06 1.592-.536 2.257-1.306.631-.765 1.683-1.084 2.378-1.503.348-.199.629-.469.649-.853.023-.4-.2-.811-.714-1.376v-.097l-.003-.003c-.17-.2-.25-.535-.338-.926-.085-.401-.182-.786-.492-1.046h-.003c-.059-.054-.123-.067-.188-.135a.357.357 0 0 0-.19-.064c.431-1.278.264-2.55-.173-3.694-.533-1.41-1.465-2.638-2.175-3.483-.796-1.005-1.576-1.957-1.56-3.368.026-2.152.236-6.133-3.544-6.139z',
    requirements: 'Ubuntu 18.04 or later',
    color: 'text-amber-500'
  }
]

const platforms = computed<Platform[]>(() => {
  const currentVersion = getVersion()
  return platformBaseData.map((p) => {
    let downloadUrl = '#'
    const ext = p.name === 'Android' ? 'apk' : p.name === 'Windows' ? 'exe' : 'zip'
    if (p.name !== 'Android') {
      downloadUrl = getDownloadUrl(p.name.toLowerCase(), ext)
    }
    return { ...p, version: currentVersion, downloadUrl }
  })
})

const downloadPlatform = (platform: Platform) => {
  if (platform.downloadUrl !== '#') {
    window.open(platform.downloadUrl, '_blank')
  }
}

// Changelog
interface ChangelogVersion {
  version: string
  date: string
  stable: boolean
  highlights: string[]
  changes: { category: string; title: string; description: string }[]
}

interface ChangelogData {
  title: string
  description: string
  categories: Record<string, { label: string; icon: string; color: string }>
  versions: ChangelogVersion[]
}

const changelogData = ref<ChangelogData | null>(null)
const isLoadingChangelog = ref(true)

onMounted(async () => {
  try {
    const response = await fetch('/CHANGELOG.json')
    if (!response.ok) throw new Error('Failed to load changelog')
    changelogData.value = await response.json() as ChangelogData
  } catch {
    // Silently fail — the UI handles the empty state
  } finally {
    isLoadingChangelog.value = false
  }
})

useScrollAnimations()

const latestVersion = computed(() => {
  return changelogData.value?.versions.find(v => v.stable) ?? null
})

const formatDate = (dateStr: string): string => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    year: 'numeric', month: 'long', day: 'numeric'
  })
}
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="pt-28 sm:pt-36 pb-16 lg:pb-20">
      <div class="container-custom text-center max-w-3xl mx-auto">
        <h1
          class="text-4xl sm:text-5xl font-bold tracking-tight mb-5 text-slate-950 dark:text-slate-50 scroll-reveal"
          style="line-height: 1.1"
        >
          Download <span class="text-teal-500">Recogniz.ing</span>
        </h1>
        <p class="text-lg sm:text-xl text-slate-600 dark:text-slate-400 scroll-reveal">
          Free AI-powered voice typing. Available for all platforms.
        </p>
      </div>
    </section>

    <!-- Platform Downloads -->
    <section class="py-16 lg:py-24">
      <div class="container-custom">
        <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-5 max-w-5xl mx-auto">
          <div
            v-for="platform in platforms"
            :key="platform.name"
            class="card text-center scroll-reveal group"
          >
            <!-- Platform Icon (brand SVG — kept as inline) -->
            <div class="w-14 h-14 mx-auto mb-4 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
              <svg viewBox="0 0 24 24" fill="currentColor" class="w-7 h-7" :class="platform.color">
                <path :d="platform.icon" />
              </svg>
            </div>

            <h3 class="text-lg font-semibold mb-1 text-slate-950 dark:text-slate-50">
              {{ platform.name }}
            </h3>
            <p class="text-sm text-slate-500 dark:text-slate-400 mb-4">
              v{{ platform.version }}
            </p>

            <!-- Status Badge -->
            <div class="mb-4">
              <span
                v-if="platform.downloadUrl === '#'"
                class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400"
              >
                Coming Soon
              </span>
              <span
                v-else
                class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-400"
              >
                <Check :size="12" />
                Available
              </span>
            </div>

            <!-- Download Button -->
            <button
              @click="downloadPlatform(platform)"
              :disabled="platform.downloadUrl === '#'"
              class="w-full py-3 rounded-xl text-sm font-medium transition-all duration-200 flex items-center justify-center gap-2"
              :class="[
                platform.downloadUrl === '#'
                  ? 'bg-slate-100 text-slate-400 cursor-not-allowed dark:bg-slate-800 dark:text-slate-600'
                  : 'bg-slate-900 text-white hover:bg-slate-800 dark:bg-teal-500 dark:hover:bg-teal-400'
              ]"
            >
              <Download v-if="platform.downloadUrl !== '#'" :size="16" />
              {{ platform.downloadUrl === '#' ? 'Coming Soon' : 'Download' }}
            </button>

            <p class="text-xs text-slate-500 dark:text-slate-400 mt-3">
              {{ platform.requirements }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Quick Start -->
    <section class="py-16 lg:py-24 bg-slate-50 dark:bg-slate-900/40">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto">
          <div class="text-center mb-12 scroll-reveal">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4 text-slate-950 dark:text-slate-50">
              Quick Start
            </h2>
            <p class="text-lg text-slate-600 dark:text-slate-400">
              Get up and running in minutes
            </p>
          </div>

          <div class="space-y-4">
            <!-- Step 1 -->
            <div class="card scroll-reveal">
              <div class="flex items-start gap-5">
                <div class="shrink-0 w-10 h-10 rounded-full bg-teal-500 text-white flex items-center justify-center font-bold text-sm">
                  1
                </div>
                <div>
                  <h3 class="text-lg font-semibold mb-2 text-slate-950 dark:text-slate-50">
                    Get Your Free API Key
                  </h3>
                  <p class="text-sm text-slate-600 dark:text-slate-400 mb-3">
                    Get your free Gemini API key from Google AI Studio. The app requires an API key to work.
                  </p>
                  <a
                    href="https://aistudio.google.com/app/apikey"
                    target="_blank"
                    rel="noopener"
                    class="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium bg-slate-900 text-white hover:bg-slate-800 dark:bg-teal-500 dark:hover:bg-teal-400 transition-colors"
                  >
                    <ExternalLink :size="14" />
                    Get API Key
                  </a>
                </div>
              </div>
            </div>

            <!-- Step 2 -->
            <div class="card scroll-reveal">
              <div class="flex items-start gap-5">
                <div class="shrink-0 w-10 h-10 rounded-full bg-violet-500 text-white flex items-center justify-center font-bold text-sm">
                  2
                </div>
                <div class="flex-1">
                  <h3 class="text-lg font-semibold mb-3 text-slate-950 dark:text-slate-50">
                    Download & Install
                  </h3>
                  <div class="grid sm:grid-cols-2 gap-3">
                    <div
                      v-for="p in ['macOS: Unzip → drag to Applications', 'Windows: Run the .exe installer', 'Linux: chmod +x the .AppImage', 'Android: Install the APK']"
                      :key="p"
                      class="flex items-start gap-2 text-sm text-slate-600 dark:text-slate-400"
                    >
                      <Check :size="14" class="text-emerald-500 mt-0.5 shrink-0" />
                      <span>{{ p }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Step 3 -->
            <div class="card scroll-reveal">
              <div class="flex items-start gap-5">
                <div class="shrink-0 w-10 h-10 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-sm">
                  3
                </div>
                <div>
                  <h3 class="text-lg font-semibold mb-2 text-slate-950 dark:text-slate-50">
                    Start Recording
                  </h3>
                  <p class="text-sm text-slate-600 dark:text-slate-400">
                    Launch the app, go to Settings, enter your API key, and start speaking!
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Changelog Preview -->
    <section class="py-16 lg:py-24">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto">
          <div class="text-center mb-10 scroll-reveal">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4 text-slate-950 dark:text-slate-50">
              What's New
            </h2>
          </div>

          <!-- Loading -->
          <div v-if="isLoadingChangelog" class="card text-center py-10 scroll-reveal">
            <div class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-teal-500" />
            <p class="mt-3 text-sm text-slate-500">Loading changelog...</p>
          </div>

          <!-- Latest Version -->
          <div v-else-if="latestVersion" class="card scroll-reveal">
            <div class="flex items-center justify-between mb-5">
              <div>
                <h3 class="text-xl font-semibold text-slate-950 dark:text-slate-50">
                  Version {{ latestVersion.version }}
                </h3>
                <p class="text-sm text-slate-500">{{ formatDate(latestVersion.date) }}</p>
              </div>
              <span class="px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-400">
                Latest
              </span>
            </div>

            <ul v-if="latestVersion.highlights.length" class="space-y-2">
              <li
                v-for="highlight in latestVersion.highlights"
                :key="highlight"
                class="flex items-start gap-2.5 text-sm text-slate-600 dark:text-slate-400"
              >
                <Check :size="14" class="text-emerald-500 mt-0.5 shrink-0" />
                {{ highlight }}
              </li>
            </ul>
          </div>

          <!-- Error -->
          <div v-else class="card text-center py-10 scroll-reveal">
            <CircleHelp :size="32" class="mx-auto text-slate-300 dark:text-slate-600 mb-3" />
            <p class="text-sm text-slate-500">Unable to load changelog.</p>
          </div>

          <div class="text-center mt-8">
            <RouterLink
              to="/changelog"
              class="inline-flex items-center gap-2 text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-200 transition-colors"
            >
              View All Versions
              <ArrowRight :size="16" />
            </RouterLink>
          </div>
        </div>
      </div>
    </section>

    <!-- Support -->
    <section class="py-16 lg:py-20 bg-slate-50 dark:bg-slate-900/40">
      <div class="container-custom text-center max-w-2xl mx-auto">
        <h2 class="text-2xl font-bold mb-3 text-slate-950 dark:text-slate-50">
          Need Help?
        </h2>
        <p class="text-slate-600 dark:text-slate-400 mb-6">
          Check our documentation or report issues on GitHub
        </p>
        <div class="flex flex-col sm:flex-row items-center justify-center gap-3">
          <a
            href="https://github.com/xicv/recogniz.ing"
            target="_blank"
            rel="noopener"
            class="btn-primary inline-flex items-center gap-2 text-sm"
          >
            <!-- GitHub brand icon — kept as inline SVG -->
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
            View on GitHub
          </a>
          <a
            href="https://github.com/xicv/recogniz.ing/issues"
            target="_blank"
            rel="noopener"
            class="btn-secondary inline-flex items-center gap-2 text-sm"
          >
            <CircleHelp :size="16" />
            Report Issue
          </a>
        </div>
      </div>
    </section>
  </div>
</template>
