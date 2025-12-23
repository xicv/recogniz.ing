<script setup lang="ts">
// Downloads page - Updated for v1.0.4
import { ref, onMounted } from 'vue'

interface Platform {
  name: string
  icon: string // SVG path string
  version: string
  releaseDate: string
  downloadUrl: string
  changelog: string[]
}

const platforms = ref<Platform[]>([
  {
    name: 'Android',
    icon: 'M6.382 3.968A8.962 8.962 0 0 1 12 2c2.125 0 4.078.736 5.618 1.968l1.453-1.453 1.414 1.414-1.453 1.453A8.962 8.962 0 0 1 21 11v1H3v-1c0-2.125.736-4.078 1.968-5.618L3.515 3.93l1.414-1.414 1.453 1.453zM3 14h18v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7zm6-5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm6 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2z',
    version: '1.0.4',
    releaseDate: '2025-12-23',
    downloadUrl: 'https://xicv.github.io/recogniz.ing/downloads/android/1.0.4/recognizing-1.0.4.apk',
    changelog: [
      'Standalone APK - no Google Play required',
      'Works on Android 8.0+ (API 26)',
      'Optimized for both phones and tablets'
    ]
  },
  {
    name: 'macOS',
    icon: 'M18.7 19.5c-.8 1.2-1.7 2.5-3 2.5-1.3 0-1.8-.8-3.3-.8-1.5 0-2 .8-3.3.8-1.3 0-2.3-1.3-3.1-2.5C4.2 17 2.9 12.5 4.7 9.4c.9-1.5 2.4-2.5 4.1-2.5 1.3 0 2.5.9 3.3.9.8 0 2.3-1.1 3.8-.9.6.03 2.5.3 3.6 2-.1.06-2.2 1.3-2.1 3.8.03 3 2.6 4 2.7 4-.03.07-.4 1.4-1.4 2.8M13 3.5c.7-.8 1.9-1.5 2.9-1.5.1 1.2-.3 2.4-1 3.2-.7.8-1.8 1.5-2.9 1.4-.1-1.1.4-2.4 1.1-3.1z',
    version: '1.0.4',
    releaseDate: '2025-12-23',
    downloadUrl: 'https://xicv.github.io/recogniz.ing/downloads/macos/1.0.4/recognizing-1.0.4-macos.zip',
    changelog: [
      'User preferences with persistent desktop settings',
      'Desktop-specific features: auto-start, minimize to tray',
      'VAD modal UI fixes and audio processing improvements'
    ]
  },
  {
    name: 'Windows',
    icon: 'M3 12V6.7L9 5.4v6.5L3 12M20 3v8.8L10 11.9V5.2L20 3M3 13l6 .1V19.9L3 18.7V13m17 .3V22L10 20.1v-7',
    version: '1.0.4',
    releaseDate: '2025-12-23',
    downloadUrl: '#',
    changelog: [
      'Updated to match macOS release',
      'Coming soon - check back later!'
    ]
  },
  {
    name: 'Linux',
    icon: 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 2c4.41 0 8 3.59 8 8s-3.59 8-8 8-8-3.59-8-8 8-3.59 8-8 8 8 8-3.59 8-8zm0 2c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6 2.69 6 6zm-1-5h2v6h-2V6z',
    version: '1.0.4',
    releaseDate: '2025-12-23',
    downloadUrl: '#',
    changelog: [
      'Updated to match macOS release',
      'Coming soon - check back later!'
    ]
  }
])

const selectedPlatform = ref<Platform | null>(null)
const downloadCount = ref(0)

onMounted(() => {
  // Simulate download count
  downloadCount.value = Math.floor(Math.random() * 50000) + 100000
})

const downloadPlatform = (platform: Platform) => {
  selectedPlatform.value = platform
  // Only download if the platform is available (not "#")
  if (platform.downloadUrl !== '#') {
    window.open(platform.downloadUrl, '_blank')
    downloadCount.value++
  }
}
</script>

<template>
  <div>
    <!-- Hero Section -->
    <section class="pt-32 pb-24 section-padding bg-gradient-to-br from-slate-50 to-white">
      <div class="container-custom text-center">
        <div class="max-w-4xl mx-auto animate-fade-in">
          <h1 class="text-5xl sm:text-6xl lg:text-7xl font-light leading-tight mb-6 tracking-tight">
            Download
            <span class="font-medium">Recogniz.ing</span>
          </h1>
          <p class="text-xl text-slate-600 mb-12">
            Free AI-powered voice typing. Available for all platforms.
          </p>
          <div class="text-center text-slate-500">
            <span class="font-medium">{{ downloadCount.toLocaleString() }}</span> downloads and counting
          </div>
        </div>
      </div>
    </section>

    <!-- Platform Downloads -->
    <section class="py-32 section-padding">
      <div class="container-custom">
        <div class="max-w-6xl mx-auto">
          <div class="grid sm:grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              v-for="platform in platforms"
              :key="platform.name"
              class="bg-white rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300 overflow-hidden"
            >
              <!-- Platform Icon -->
              <div class="p-8 text-center border-b border-slate-100">
                <div class="w-16 h-16 mx-auto mb-4">
                  <svg viewBox="0 0 24 24" fill="currentColor" class="w-16 h-16 text-slate-700">
                    <path :d="platform.icon"/>
                  </svg>
                </div>
                <h3 class="text-2xl font-light mb-2">{{ platform.name }}</h3>
                <p class="text-slate-500">Version {{ platform.version }}</p>
                <p class="text-sm text-slate-400">{{ platform.releaseDate }}</p>
              </div>

              <!-- Download Button -->
              <div class="p-8">
                <button
                  @click="downloadPlatform(platform)"
                  :disabled="platform.downloadUrl === '#'"
                  :class="platform.downloadUrl === '#' ? 'bg-slate-300 text-slate-500 cursor-not-allowed' : 'bg-slate-900 hover:bg-slate-800 text-white hover:scale-105'"
                  class="w-full px-8 py-4 rounded-full font-medium transition-all duration-300 mb-6"
                >
                  {{ platform.downloadUrl === '#' ? 'Coming Soon' : `Download for ${platform.name}` }}
                </button>

                <!-- Requirements -->
                <div class="space-y-2 text-sm text-slate-600">
                  <div v-if="platform.name === 'Android'">Android 8.0+ (API 26)</div>
                  <div v-else-if="platform.name === 'macOS'">macOS 10.15 or later</div>
                  <div v-else-if="platform.name === 'Windows'">Windows 10 or later</div>
                  <div v-else>Ubuntu 18.04 or later</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Installation Instructions -->
    <section class="py-32 section-padding bg-slate-50">
      <div class="container-custom">
        <div class="max-w-4xl mx-auto">
          <h2 class="text-4xl font-light mb-12 text-center">Installation Instructions</h2>

          <div class="space-y-12">
            <div>
              <h3 class="text-2xl font-medium mb-4">1. Get API Key</h3>
              <p class="text-slate-600 mb-4">
                Get your free Gemini API key from Google AI Studio. The app will not work without an API key.
              </p>
              <a
                href="https://aistudio.google.com/app/apikey"
                target="_blank"
                rel="noopener"
                class="inline-flex items-center space-x-2 bg-white border border-slate-300 hover:border-slate-400 text-slate-700 px-6 py-3 rounded-lg font-medium transition-all"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                </svg>
                <span>Get API Key</span>
              </a>
            </div>

            <div>
              <h3 class="text-2xl font-medium mb-4">2. Download & Install</h3>
              <div class="bg-white rounded-lg border border-slate-200 p-6">
                <h4 class="font-medium mb-2">Android:</h4>
                <ol class="list-decimal list-inside text-slate-600 space-y-1 mb-4">
                  <li>Download the APK file</li>
                  <li>Enable "Install from unknown sources" in your device settings</li>
                  <li>Open the APK file and tap "Install"</li>
                  <li>Launch the app from your home screen</li>
                </ol>

                <h4 class="font-medium mb-2 mt-6">macOS:</h4>
                <ol class="list-decimal list-inside text-slate-600 space-y-1 mb-4">
                  <li>Download the .app file</li>
                  <li>Drag the .app file to Applications folder</li>
                  <li>If you see a warning "Apple could not verify 'recognizing.app' is free of malware", click "Done", then go to Settings → Privacy & Security, and click "Open Anyway"</li>
                  <li>Alternatively, run <code class="bg-slate-100 px-2 py-1 rounded text-sm">sudo codesign -fs Recognizing /Applications/Recognizing.app</code> from Terminal.app</li>
                  <li>Launch from Applications or Spotlight</li>
                </ol>

                <h4 class="font-medium mb-2 mt-6">Windows:</h4>
                <ol class="list-decimal list-inside text-slate-600 space-y-1 mb-4">
                  <li>Download the .exe installer</li>
                  <li>Run the installer as Administrator</li>
                  <li>Follow the installation wizard</li>
                  <li>Launch from Start Menu</li>
                </ol>

                <h4 class="font-medium mb-2 mt-6">Linux:</h4>
                <ol class="list-decimal list-inside text-slate-600 space-y-1">
                  <li>Download the .AppImage file</li>
                  <li>Make it executable: <code class="bg-slate-100 px-2 py-1 rounded">chmod +x recognizing-linux.AppImage</code></li>
                  <li>Run the AppImage</li>
                </ol>
              </div>
            </div>

            <div>
              <h3 class="text-2xl font-medium mb-4">3. Setup</h3>
              <ol class="list-decimal list-inside text-slate-600 space-y-2">
                <li>Launch the app</li>
                <li>Go to Settings tab</li>
                <li>Enter your Gemini API key</li>
                <li>Customize prompts and vocabulary (optional)</li>
                <li>Return to Dashboard and start recording!</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Changelog -->
    <section class="py-32 section-padding">
      <div class="container-custom">
        <div class="max-w-4xl mx-auto">
          <h2 class="text-4xl font-light mb-12 text-center">What's New</h2>

          <div class="space-y-8">
            <div class="bg-white rounded-lg border border-slate-200 p-8">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-medium">Version 1.0.4</h3>
                <span class="text-sm text-slate-500">December 23, 2025</span>
              </div>
              <ul class="space-y-2 text-slate-600">
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  User preferences with persistent desktop settings
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Desktop-specific features: auto-start, minimize to tray
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  VAD modal UI fixes and audio processing improvements
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Fixed Android build with AGP 8.10 and Gradle 8.11.1
                </li>
              </ul>
            </div>
            <div class="bg-white rounded-lg border border-slate-200 p-8">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-medium">Version 1.0.3</h3>
                <span class="text-sm text-slate-500">December 21, 2025</span>
              </div>
              <ul class="space-y-2 text-slate-600">
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Fixed macOS Gatekeeper verification issues
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Improved app signing and security
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Initial Windows release with native installer
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Enhanced stability and performance
                </li>
              </ul>
            </div>
            <div class="bg-white rounded-lg border border-slate-200 p-8">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-medium">Version 1.0.2</h3>
                <span class="text-sm text-slate-500">December 15, 2024</span>
              </div>
              <ul class="space-y-2 text-slate-600">
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Added comprehensive version management system
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Fixed Settings navigation to open correct tab
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Added keyboard shortcuts (Cmd/Ctrl+S for saving)
                </li>
                <li class="flex items-start">
                  <span class="text-green-500 mr-2">✓</span>
                  Enhanced UI components for better consistency
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Support Section -->
    <section class="py-32 section-padding bg-slate-50">
      <div class="container-custom text-center">
        <h2 class="text-4xl font-light mb-6">Need Help?</h2>
        <p class="text-xl text-slate-600 mb-12">
          Check our documentation or report issues on GitHub
        </p>
        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="#"
            class="bg-white border border-slate-300 hover:border-slate-400 text-slate-700 px-8 py-4 rounded-full font-medium transition-all"
          >
            Documentation
          </a>
          <a
            href="#"
            class="bg-white border border-slate-300 hover:border-slate-400 text-slate-700 px-8 py-4 rounded-full font-medium transition-all"
          >
            Report Issue
          </a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.8s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>