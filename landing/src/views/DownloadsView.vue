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
    icon: 'M8.294 1c-.09 0-.184.005-.28.012-2.465.194-1.811 2.804-1.85 3.674-.043.637-.174 1.14-.612 1.762-.516.613-1.24 1.604-1.584 2.637-.162.485-.24.982-.167 1.452a.247.247 0 00-.064.079c-.152.156-.263.35-.387.49-.116.115-.283.155-.465.232-.183.08-.384.157-.504.397a.78.78 0 00-.077.351c0 .116.016.234.032.313.034.233.068.425.023.566-.145.396-.163.668-.062.865.102.195.313.275.549.351.472.117 1.114.079 1.618.35.54.272 1.088.39 1.526.274.307-.067.566-.27.705-.552.342-.001.717-.157 1.318-.194.408-.034.918.155 1.503.116.015.078.037.116.067.194l.001.002c.229.454.65.66 1.1.625.45-.035.928-.313 1.316-.762.368-.446.982-.632 1.387-.877.203-.116.367-.273.379-.497.013-.234-.117-.473-.417-.803v-.056l-.002-.002c-.099-.117-.145-.312-.197-.54-.05-.234-.106-.459-.287-.61h-.001c-.035-.032-.072-.04-.11-.08a.208.208 0 00-.11-.037c.25-.745.153-1.487-.102-2.154-.31-.823-.854-1.54-1.269-2.032-.464-.587-.919-1.142-.91-1.965.016-1.255.138-3.578-2.067-3.581zm.309 1.986h.007c.125 0 .231.036.34.116a.89.89 0 01.256.31c.062.152.093.268.097.423 0-.012.004-.023.004-.035v.061a.05.05 0 01-.003-.012l-.002-.014c-.001.142-.03.282-.087.412a.556.556 0 01-.125.195.415.415 0 00-.051-.024c-.06-.027-.115-.038-.166-.078a.765.765 0 00-.128-.038c.03-.035.085-.078.107-.116a.69.69 0 00.051-.234V3.94a.706.706 0 00-.035-.233c-.027-.079-.06-.117-.107-.195-.05-.038-.098-.077-.156-.077h-.01c-.054 0-.102.018-.152.077a.467.467 0 00-.12.195.688.688 0 00-.052.234v.01c0 .053.004.105.011.156-.112-.039-.255-.078-.354-.117a.954.954 0 01-.01-.117V3.86a1.034 1.034 0 01.087-.448.63.63 0 01.251-.31.575.575 0 01.347-.117zm-1.728.035h.02c.084 0 .158.028.234.078a.806.806 0 01.2.272c.053.116.082.233.09.389v.002a.856.856 0 01-.002.155v.047l-.048.014c-.089.032-.16.079-.23.117a.633.633 0 00.002-.156V3.93c-.007-.078-.023-.117-.047-.194a.358.358 0 00-.097-.156.145.145 0 00-.107-.037h-.012c-.042.003-.076.023-.109.077a.322.322 0 00-.07.157.55.55 0 00-.013.193v.008c.007.08.021.117.047.195a.363.363 0 00.096.157c.006.005.012.01.02.014-.04.033-.068.04-.102.079a.177.177 0 01-.077.04 1.53 1.53 0 01-.16-.235 1.034 1.034 0 01-.09-.389c-.01-.132.005-.264.046-.39a.834.834 0 01.165-.312c.075-.077.152-.116.244-.116zm.799.995c.194 0 .428.038.71.233.17.116.304.157.613.273h.002c.149.079.236.155.279.232v-.076a.333.333 0 01.009.274c-.072.18-.301.375-.62.491v.001c-.156.08-.292.195-.452.272-.161.078-.343.17-.59.155a.664.664 0 01-.262-.039 2.077 2.077 0 01-.188-.115c-.113-.079-.211-.194-.357-.271v-.003h-.003c-.233-.144-.359-.299-.4-.414-.04-.157-.003-.275.113-.35.13-.08.221-.159.282-.197.06-.043.083-.059.102-.076h.001v-.002c.099-.117.255-.274.49-.35.08-.021.171-.038.272-.038h-.001zm1.633 1.25c.21.826.698 2.026 1.012 2.609.167.311.5.967.643 1.764.091-.003.193.01.3.037.376-.975-.319-2.022-.636-2.314-.128-.116-.135-.195-.071-.195.344.312.796.917.96 1.608.075.312.093.644.012.974.039.017.079.035.12.04.601.311.824.547.717.896v-.025c-.035-.002-.07 0-.105 0h-.01c.089-.272-.106-.481-.62-.714-.534-.233-.96-.196-1.033.271-.005.025-.008.039-.01.079-.04.013-.082.03-.123.037-.25.157-.386.39-.462.693-.076.31-.1.674-.12 1.09v.002c-.011.195-.099.489-.186.787-.875.626-2.088.897-3.12.195a1.543 1.543 0 00-.234-.31.846.846 0 00-.16-.195.963.963 0 00.27-.04.359.359 0 00.184-.194c.063-.156 0-.407-.201-.678-.201-.273-.543-.58-1.043-.888-.368-.233-.575-.507-.671-.814-.096-.312-.083-.633-.009-.96.143-.624.51-1.23.743-1.611.063-.038.022.078-.238.568-.23.438-.665 1.456-.07 2.248.022-.578.15-1.146.377-1.678.329-.745 1.016-2.044 1.07-3.073.029.021.127.08.17.118.126.078.22.194.343.271a.694.694 0 00.511.196l.065.003c.24 0 .425-.078.581-.156.17-.078.304-.195.432-.233h.003c.272-.08.487-.235.609-.409zm1.275 5.225c.021.35.2.726.514.803.343.078.837-.194 1.045-.446l.123-.006c.184-.004.337.006.494.156l.002.002c.121.116.178.31.228.511.05.233.09.455.239.622.283.307.376.528.37.665l.003-.004v.01l-.002-.007c-.009.153-.108.231-.29.347-.368.234-1.02.416-1.434.916-.36.43-.8.665-1.188.695-.387.03-.721-.117-.918-.524l-.003-.002c-.122-.233-.07-.597.033-.985.103-.39.25-.784.27-1.107.022-.417.044-.779.114-1.058.07-.271.18-.465.374-.574l.026-.013v-.001zm-6.308.028h.006a.53.53 0 01.091.009c.22.032.412.194.597.438l.53.97.003.003c.141.31.44.62.693.955.253.348.45.66.425.915v.004c-.033.434-.28.67-.656.755-.376.079-.887 0-1.397-.27-.565-.314-1.235-.274-1.667-.352-.215-.039-.355-.117-.421-.233-.064-.117-.066-.352.071-.718v-.002l.002-.002c.068-.195.017-.439-.016-.652-.032-.234-.049-.414.025-.549.093-.194.23-.233.402-.31.172-.08.374-.118.534-.275h.001c.15-.157.26-.351.39-.49.11-.117.222-.196.387-.196zM8.45 5.226c-.254.117-.551.312-.868.312-.316 0-.566-.155-.747-.272-.09-.078-.163-.156-.217-.195-.096-.078-.084-.194-.044-.194.064.01.076.078.117.117.056.038.125.116.21.194.17.116.396.272.68.272.283 0 .615-.156.816-.272.114-.078.26-.194.378-.272.09-.08.087-.156.163-.156.074.01.02.078-.086.194-.13.098-.264.189-.403.273zm-.631-.923V4.29c-.004-.012.007-.024.017-.03.043-.024.105-.015.151.003.037 0 .094.04.088.079-.004.029-.05.038-.079.038-.032 0-.054-.025-.082-.04-.03-.01-.085-.004-.095-.037zm-.322 0c-.011.034-.066.028-.097.038-.027.015-.05.04-.081.04-.03 0-.076-.012-.08-.04-.005-.038.052-.077.088-.077.047-.018.107-.028.151-.003.011.005.021.017.018.029v.012h.001z',
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