<script setup lang="ts">
import { ref } from 'vue'

type TabType = 'prompts' | 'vocabulary' | 'settings'

const activeTab = ref<TabType>('prompts')

const setActiveTab = (tab: TabType) => {
  activeTab.value = tab
}

// Tab data
const prompts = [
  {
    title: 'Clean Transcription',
    description: 'Removes filler words and fixes grammar automatically',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>',
    color: 'blue'
  },
  {
    title: 'Formal Writing',
    description: 'Converts casual speech into professional text',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>',
    color: 'purple'
  },
  {
    title: 'Bullet Points',
    description: 'Organizes content into concise, scannable bullets',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>',
    color: 'green'
  },
  {
    title: 'Email Draft',
    description: 'Creates professional email templates',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>',
    color: 'orange'
  },
  {
    title: 'Meeting Notes',
    description: 'Structures meeting summaries and action items',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>',
    color: 'pink'
  },
  {
    title: 'Social Media Post',
    description: 'Optimizes content for social platforms',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/>',
    color: 'indigo'
  }
]

const vocabulary = [
  {
    title: 'General Tech',
    description: 'Common technology terms: AI, API, UI/UX, GitHub',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9V3m0 9a9 9 0 000 18z"/>',
    color: 'blue'
  },
  {
    title: 'Technology',
    description: 'Industry terms: Kubernetes, Docker, AWS, CI/CD',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2z"/>',
    color: 'green'
  },
  {
    title: 'Business',
    description: 'Corporate terms: ROI, KPI, SaaS, stakeholders',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>',
    color: 'purple'
  },
  {
    title: 'Medical',
    description: 'Healthcare terms: diagnosis, therapy, radiology',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>',
    color: 'red'
  },
  {
    title: 'Legal',
    description: 'Legal terms: liability, litigation, jurisprudence',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"/>',
    color: 'yellow'
  },
  {
    title: 'Finance',
    description: 'Financial terms: portfolio, dividend, equity, IPO',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>',
    color: 'green'
  }
]

const settings = [
  {
    title: 'Recording Settings',
    description: 'Configure audio input, sensitivity, and VAD parameters',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"/>',
    color: 'blue'
  },
  {
    title: 'Hotkey Configuration',
    description: 'Set up global hotkeys for quick recording access',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/>',
    color: 'purple'
  },
  {
    title: 'API Integration',
    description: 'Manage API keys and service provider settings',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>',
    color: 'orange'
  },
  {
    title: 'Theme Preferences',
    description: 'Choose between light and dark themes',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>',
    color: 'indigo'
  },
  {
    title: 'Data Management',
    description: 'Export, backup, and manage your transcription history',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"/>',
    color: 'green'
  },
  {
    title: 'Privacy Settings',
    description: 'Configure data encryption and local storage options',
    icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>',
    color: 'red'
  }
]
</script>

<template>
  <div>
    <!-- Hero Section -->
    <section class="pt-32 pb-24 section-padding bg-gradient-to-br from-slate-50 to-white">
      <div class="container-custom">
        <div class="text-center max-w-4xl mx-auto animate-fade-in">
          <h1 class="text-5xl sm:text-6xl lg:text-7xl font-light leading-tight mb-6 tracking-tight">
            Powerful Features for
            <span class="font-medium bg-gradient-to-r from-primary-600 to-primary-800 bg-clip-text text-transparent">Voice Typing</span>
          </h1>
          <p class="text-xl text-slate-600 leading-relaxed">
            Everything you need to transform your voice into perfect text, tailored to your workflow
          </p>
        </div>
      </div>
    </section>

    <!-- Core Features Grid -->
    <section class="py-32 section-padding">
      <div class="container-custom">
        <div class="text-center mb-16">
          <h2 class="text-4xl font-light mb-4">Core Features</h2>
          <p class="text-xl text-slate-600">Designed for productivity and ease of use</p>
        </div>

        <div class="max-w-6xl mx-auto">
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
            <!-- Smart Voice Recording -->
            <div class="feature-item group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Smart Voice Recording</h3>
              <p class="text-slate-600 text-sm leading-relaxed">VAD with global hotkeys & system tray</p>
            </div>

            <!-- AI Transcription -->
            <div class="feature-item group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">AI-Powered Transcription</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Gemini 1.5 with single API optimization</p>
            </div>

            <!-- Dashboard & Analytics -->
            <div class="feature-item group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Dashboard & Analytics</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Searchable history with editing & stats</p>
            </div>

            <!-- Customization -->
            <div class="feature-item group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Customization</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Custom prompts & vocabulary sets</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Customization Section -->
    <section class="py-32 section-padding bg-slate-50">
      <div class="container-custom">
        <div class="text-center mb-16">
          <h2 class="text-4xl font-light mb-4">Customization</h2>
          <p class="text-xl text-slate-600">Tailor Recogniz.ing to your exact needs</p>
        </div>

        <!-- Interactive Tabs -->
        <div class="max-w-5xl mx-auto">
          <div class="flex justify-center mb-12">
            <div class="inline-flex rounded-lg p-1 bg-slate-100">
              <button
                v-for="(items, tab) in { prompts, vocabulary, settings }"
                :key="tab"
                @click="setActiveTab(tab as TabType)"
                class="px-6 py-3 rounded-md font-medium transition-all capitalize"
                :class="[
                  activeTab === tab
                    ? 'bg-slate-900 text-white'
                    : 'text-slate-600 hover:bg-slate-200'
                ]"
              >
                {{ tab === 'prompts' ? 'Smart Prompts' : tab === 'vocabulary' ? 'Vocabulary Sets' : 'Settings' }}
              </button>
            </div>
          </div>

          <!-- Tab Content -->
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div
              v-for="item in (activeTab === 'prompts' ? prompts : activeTab === 'vocabulary' ? vocabulary : settings)"
              :key="item.title"
              class="bg-white p-6 rounded-2xl border border-slate-200"
            >
              <div :class="`w-12 h-12 bg-${item.color}-100 rounded-lg flex items-center justify-center mb-4`">
                <svg :class="`w-6 h-6 text-${item.color}-600`" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="item.icon"/>
              </div>
              <h3 class="text-lg font-medium mb-2">{{ item.title }}</h3>
              <p class="text-slate-600 text-sm">{{ item.description }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Performance Section -->
    <section class="py-32 section-padding">
      <div class="container-custom">
        <div class="max-w-6xl mx-auto">
          <div class="grid lg:grid-cols-2 gap-16 items-center">
            <div>
              <h2 class="text-4xl font-light mb-6">Built for Performance</h2>
              <p class="text-xl text-slate-600 mb-8">
                Optimized for speed and efficiency with intelligent caching and background processing.
              </p>

              <div class="space-y-6">
                <div class="flex items-start space-x-4">
                  <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3 class="text-lg font-medium mb-1">Single API Call Mode</h3>
                    <p class="text-slate-600">Reduces transcription time by up to 50%</p>
                  </div>
                </div>

                <div class="flex items-start space-x-4">
                  <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3 class="text-lg font-medium mb-1">Background Processing</h3>
                    <p class="text-slate-600">Audio analysis in isolates for smooth UI</p>
                  </div>
                </div>

                <div class="flex items-start space-x-4">
                  <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3 class="text-lg font-medium mb-1">Pre-validation</h3>
                    <p class="text-slate-600">Filters non-speech audio to reduce costs</p>
                  </div>
                </div>

                <div class="flex items-start space-x-4">
                  <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3 class="text-lg font-medium mb-1">Smart Retry Logic</h3>
                    <p class="text-slate-600">Intelligent policies with circuit breaker</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Performance Metrics Visualization -->
            <div class="bg-slate-100 rounded-2xl p-8">
              <div class="text-center mb-8">
                <div class="text-5xl font-light text-slate-900 mb-2">2x</div>
                <div class="text-slate-600">Faster than traditional transcription</div>
              </div>

              <div class="space-y-4">
                <div>
                  <div class="flex justify-between text-sm mb-2">
                    <span class="text-slate-600">API Efficiency</span>
                    <span class="text-slate-900 font-medium">95%</span>
                  </div>
                  <div class="w-full bg-slate-300 rounded-full h-2">
                    <div class="bg-gradient-to-r from-blue-500 to-blue-600 h-2 rounded-full" style="width: 95%"></div>
                  </div>
                </div>

                <div>
                  <div class="flex justify-between text-sm mb-2">
                    <span class="text-slate-600">Accuracy Rate</span>
                    <span class="text-slate-900 font-medium">98%</span>
                  </div>
                  <div class="w-full bg-slate-300 rounded-full h-2">
                    <div class="bg-gradient-to-r from-green-500 to-green-600 h-2 rounded-full" style="width: 98%"></div>
                  </div>
                </div>

                <div>
                  <div class="flex justify-between text-sm mb-2">
                    <span class="text-slate-600">Cost Reduction</span>
                    <span class="text-slate-900 font-medium">50%</span>
                  </div>
                  <div class="w-full bg-slate-300 rounded-full h-2">
                    <div class="bg-gradient-to-r from-purple-500 to-purple-600 h-2 rounded-full" style="width: 50%"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-32 section-padding bg-gradient-to-br from-slate-900 to-slate-800">
      <div class="container-custom text-center">
        <h2 class="text-4xl font-light text-white mb-6">
          Ready to Transform Your Workflow?
        </h2>
        <p class="text-xl text-slate-300 mb-12 max-w-2xl mx-auto">
          Join thousands of professionals who have streamlined their transcription process
        </p>

        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
          <RouterLink
            to="/downloads"
            class="bg-white text-slate-900 hover:bg-slate-100 px-10 py-5 rounded-full font-medium text-lg transition-all duration-300 hover:scale-105"
          >
            Get Started Free
          </RouterLink>

          <a
            href="https://aistudio.google.com/app/apikey"
            target="_blank"
            rel="noopener"
            class="border border-slate-600 text-white hover:bg-slate-800 px-10 py-5 rounded-full font-medium text-lg transition-all duration-300"
          >
            Get API Key
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

.feature-item {
  @apply text-center;
}
</style>