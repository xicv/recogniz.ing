<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useScrollAnimations } from '@/composables/useScrollAnimations'

// Initialize scroll animations
useScrollAnimations()

type TabType = 'prompts' | 'vocabulary' | 'settings'

const activeTab = ref<TabType>('prompts')

const setActiveTab = (tab: TabType) => {
  activeTab.value = tab
}

// Tab configuration with colors
const tabConfig = {
  prompts: {
    label: 'Smart Prompts',
    color: 'violet',
    bgColor: 'bg-violet-100 dark:bg-violet-900/50',
    textColor: 'text-violet-600 dark:text-violet-400',
    borderColor: 'border-violet-200 dark:border-violet-800'
  },
  vocabulary: {
    label: 'Vocabulary Sets',
    color: 'emerald',
    bgColor: 'bg-emerald-100 dark:bg-emerald-900/50',
    textColor: 'text-emerald-600 dark:text-emerald-400',
    borderColor: 'border-emerald-200 dark:border-emerald-800'
  },
  settings: {
    label: 'Settings',
    color: 'slate',
    bgColor: 'bg-slate-100 dark:bg-slate-800',
    textColor: 'text-slate-600 dark:text-slate-400',
    borderColor: 'border-slate-200 dark:border-slate-700'
  }
}

// Tab data with proper icon paths
const prompts = [
  {
    title: 'Clean Transcription',
    description: 'Removes filler words and fixes grammar automatically',
    icon: 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z',
    badge: 'Popular'
  },
  {
    title: 'Formal Writing',
    description: 'Converts casual speech into professional text',
    icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
  },
  {
    title: 'Bullet Points',
    description: 'Organizes content into concise, scannable bullets',
    icon: 'M4 6h16M4 12h16M4 18h16'
  },
  {
    title: 'Email Draft',
    description: 'Creates professional email templates',
    icon: 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z'
  },
  {
    title: 'Meeting Notes',
    description: 'Structures meeting summaries and action items',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2'
  },
  {
    title: 'Social Media Post',
    description: 'Optimizes content for social platforms',
    icon: 'M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z'
  }
]

const vocabulary = [
  {
    title: 'General Tech',
    description: 'Common technology terms: AI, API, UI/UX, GitHub',
    icon: 'M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9V3m0 9a9 9 0 000 18z',
    badge: 'New'
  },
  {
    title: 'DevOps & Cloud',
    description: 'Industry terms: Kubernetes, Docker, AWS, CI/CD',
    icon: 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2z'
  },
  {
    title: 'Business',
    description: 'Corporate terms: ROI, KPI, SaaS, stakeholders',
    icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4'
  },
  {
    title: 'Medical',
    description: 'Healthcare terms: diagnosis, therapy, radiology',
    icon: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z'
  },
  {
    title: 'Legal',
    description: 'Legal terms: liability, litigation, jurisprudence',
    icon: 'M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3'
  },
  {
    title: 'Finance',
    description: 'Financial terms: portfolio, dividend, equity, IPO',
    icon: 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
  }
]

const settings = [
  {
    title: 'Recording Settings',
    description: 'Configure audio input, sensitivity, and VAD parameters',
    icon: 'M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z'
  },
  {
    title: 'Hotkey Configuration',
    description: 'Set up global hotkeys for quick recording access',
    icon: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4'
  },
  {
    title: 'API Integration',
    description: 'Manage API keys and service provider settings',
    icon: 'M13 10V3L4 14h7v7l9-11h-7z',
    badge: 'Important'
  },
  {
    title: 'Theme Preferences',
    description: 'Choose between light and dark themes',
    icon: 'M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z'
  },
  {
    title: 'Data Management',
    description: 'Export, backup, and manage your transcription history',
    icon: 'M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4'
  },
  {
    title: 'Privacy Settings',
    description: 'Configure data encryption and local storage options',
    icon: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z'
  }
]

// Core features with asymmetric grid layout
const coreFeatures = [
  {
    title: 'Smart Voice Recording',
    description: 'VAD with global hotkeys & system tray',
    icon: 'M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z',
    gradient: 'from-amber-500 to-orange-500',
    span: 'col-span-1'
  },
  {
    title: 'AI-Powered Transcription',
    description: 'Gemini 3.0 Flash with intelligent optimization',
    icon: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z',
    gradient: 'from-sky-500 to-cyan-500',
    span: 'col-span-1 sm:col-span-2 row-span-2'
  },
  {
    title: 'Dashboard & Analytics',
    description: 'Searchable history with editing & stats',
    icon: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
    gradient: 'from-violet-500 to-purple-500',
    span: 'col-span-1'
  },
  {
    title: 'Customization',
    description: 'Custom prompts & vocabulary sets',
    icon: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z',
    gradient: 'from-emerald-500 to-teal-500',
    span: 'col-span-1'
  }
]

const activeItems = computed(() => {
  if (activeTab.value === 'prompts') return prompts
  if (activeTab.value === 'vocabulary') return vocabulary
  return settings
})

const activeConfig = computed(() => tabConfig[activeTab.value])
</script>

<template>
  <div>
    <!-- Hero Section -->
    <section
      class="pt-24 sm:pt-32 pb-16 lg:pb-24 section-padding bg-gradient-to-br from-slate-50 to-white dark:from-slate-900 dark:to-[#0a0a0a] transition-colors duration-300"
    >
      <div class="container-custom">
        <div class="text-center max-w-4xl mx-auto">
          <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-6 scroll-reveal-scale bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
            FEATURES
          </span>
          <h1
            class="text-4xl sm:text-5xl lg:text-6xl font-semibold mb-6 tracking-tight text-slate-950 dark:text-slate-50 transition-colors duration-300 scroll-reveal"
            style="font-size: clamp(2.5rem, 2rem + 2.5vw, 4.5rem); line-height: 1.1;"
          >
            Powerful Features for
            <span class="gradient-text-accent">Voice Typing</span>
          </h1>
          <p
            class="text-lg sm:text-xl leading-relaxed text-slate-600 dark:text-slate-400 transition-colors duration-300 scroll-reveal"
          >
            Everything you need to transform your voice into perfect text, tailored to your workflow
          </p>
        </div>
      </div>
    </section>

    <!-- Core Features Grid - Asymmetric -->
    <section class="py-16 lg:py-24 section-padding relative overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-slate-50/50 to-transparent dark:via-slate-900/30 pointer-events-none" />

      <div class="container-custom relative z-10">
        <div class="text-center mb-12 scroll-reveal">
          <span class="inline-block px-4 py-1.5 rounded-full text-xs font-semibold mb-4 bg-slate-100/80 backdrop-blur text-slate-600 border border-slate-200 dark:bg-slate-800/80 dark:border-slate-700 dark:text-slate-400">
            CORE FEATURES
          </span>
          <h2
            class="text-3xl sm:text-4xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
          >
            Designed for Productivity
          </h2>
          <p class="text-lg text-slate-600 dark:text-slate-400">
            Powerful features that make voice typing effortless
          </p>
        </div>

        <!-- Asymmetric Bento Grid -->
        <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 auto-rows-min">
          <div
            v-for="(feature, index) in coreFeatures"
            :key="feature.title"
            :class="[feature.span, 'bento-card scroll-reveal group']"
            :style="{ animationDelay: `${index * 100}ms` }"
          >
            <!-- Icon with gradient background and hover effect -->
            <div class="w-14 h-14 rounded-2xl flex items-center justify-center mb-5 bg-gradient-to-br transition-transform group-hover:scale-110 group-hover:shadow-lg" :class="feature.gradient">
              <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" :d="feature.icon"/>
              </svg>
            </div>
            <h3
              class="text-xl font-semibold mb-2 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-sky-600 dark:group-hover:text-sky-400"
            >
              {{ feature.title }}
            </h3>
            <p class="text-slate-600 dark:text-slate-400">{{ feature.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Customization Section -->
    <section
      class="py-16 lg:py-24 section-padding bg-slate-50 dark:bg-slate-900/30 transition-colors duration-300 relative overflow-hidden"
    >
      <!-- Decorative background -->
      <div class="absolute top-0 right-0 w-96 h-96 bg-gradient-to-bl from-violet-500/5 to-transparent rounded-full blur-3xl pointer-events-none" />

      <div class="container-custom relative z-10">
        <div class="text-center mb-12 scroll-reveal">
          <span class="inline-block px-4 py-1.5 rounded-full text-xs font-semibold mb-4 bg-slate-100/80 backdrop-blur text-slate-600 border border-slate-200 dark:bg-slate-800/80 dark:border-slate-700 dark:text-slate-400">
            CUSTOMIZATION
          </span>
          <h2
            class="text-3xl sm:text-4xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
          >
            Tailor Recogniz.ing to Your Exact Needs
          </h2>
          <p class="text-lg text-slate-600 dark:text-slate-400">
            Create custom prompts, vocabulary sets, and configure settings
          </p>
        </div>

        <!-- Interactive Tabs - Swipeable on mobile -->
        <div class="max-w-6xl mx-auto">
          <!-- Tab Navigation - Enhanced with glassmorphism -->
          <div class="flex justify-center mb-12">
            <div
              class="inline-flex rounded-2xl p-1.5 glass-card border-slate-200 dark:border-slate-700 transition-all duration-300"
            >
              <button
                v-for="(config, tab) in tabConfig"
                :key="tab"
                @click="setActiveTab(tab as TabType)"
                class="relative px-4 sm:px-6 py-3 rounded-xl font-medium transition-all min-h-[44px] min-w-[100px] tab-snap group"
                :class="[
                  activeTab === tab
                    ? `${config.bgColor} ${config.textColor} shadow-md`
                    : 'text-slate-600 hover:bg-slate-200/50 dark:text-slate-400 dark:hover:bg-slate-700/50'
                ]"
              >
                {{ config.label }}
              </button>
            </div>
          </div>

          <!-- Tab Content Grid - Enhanced -->
          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <transition
              name="tab-content"
              mode="out-in"
            >
              <div
                :key="activeTab"
                class="contents"
              >
                <div
                  v-for="item in activeItems"
                  :key="item.title"
                  class="p-6 rounded-2xl border bg-white dark:bg-slate-800 dark:border-slate-700 border-slate-200 transition-all duration-300 hover:shadow-xl hover:-translate-y-1 shimmer group"
                >
                  <!-- Badge if present -->
                  <span
                    v-if="item.badge"
                    class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold mb-4 transition-transform group-hover:scale-105"
                    :class="`${activeConfig.bgColor} ${activeConfig.textColor}`"
                  >
                    {{ item.badge }}
                  </span>

                  <!-- Icon with hover effect -->
                  <div
                    class="w-12 h-12 rounded-xl flex items-center justify-center mb-4 transition-all duration-300 group-hover:scale-110"
                    :class="activeConfig.bgColor"
                  >
                    <svg
                      class="w-6 h-6 transition-colors duration-300"
                      :class="activeConfig.textColor"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                      stroke-width="2"
                    >
                      <path stroke-linecap="round" stroke-linejoin="round" :d="item.icon"/>
                    </svg>
                  </div>

                  <h3
                    class="text-lg font-semibold mb-2 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-sky-600 dark:group-hover:text-sky-400"
                  >
                    {{ item.title }}
                  </h3>
                  <p
                    class="text-sm leading-relaxed text-slate-600 dark:text-slate-400 transition-colors duration-300"
                  >
                    {{ item.description }}
                  </p>
                </div>
              </div>
            </transition>
          </div>
        </div>
      </div>
    </section>

    <!-- Performance Section -->
    <section class="py-16 lg:py-24 section-padding relative overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute bottom-0 left-0 w-96 h-96 bg-gradient-to-tr from-sky-500/5 to-transparent rounded-full blur-3xl pointer-events-none" />

      <div class="container-custom relative z-10">
        <div class="max-w-6xl mx-auto">
          <div class="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
            <div class="scroll-reveal-left">
              <span class="inline-block px-4 py-1.5 rounded-full text-xs font-semibold mb-4 bg-slate-100/80 backdrop-blur text-slate-600 border border-slate-200 dark:bg-slate-800/80 dark:border-slate-700 dark:text-slate-400">
                PERFORMANCE
              </span>
              <h2
                class="text-3xl sm:text-4xl font-semibold mb-6 text-slate-950 dark:text-slate-50 transition-colors duration-300"
              >
                Built for Performance
              </h2>
              <p
                class="text-lg mb-8 text-slate-600 dark:text-slate-400 transition-colors duration-300"
              >
                Optimized for speed and efficiency with intelligent caching and background processing.
              </p>

              <div class="space-y-6">
                <div class="flex items-start space-x-4 group">
                  <div
                    class="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 mt-1 bg-emerald-100 dark:bg-emerald-900/50 transition-colors duration-300 group-hover:scale-110"
                  >
                    <svg
                      class="w-4 h-4 text-emerald-600 dark:text-emerald-400 transition-colors duration-300"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3
                      class="text-lg font-medium mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-emerald-600 dark:group-hover:text-emerald-400"
                    >
                      Single API Call Mode
                    </h3>
                    <p
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300"
                    >
                      Reduces transcription time by up to 50%
                    </p>
                  </div>
                </div>

                <div class="flex items-start space-x-4 group">
                  <div
                    class="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 mt-1 bg-emerald-100 dark:bg-emerald-900/50 transition-colors duration-300 group-hover:scale-110"
                  >
                    <svg
                      class="w-4 h-4 text-emerald-600 dark:text-emerald-400 transition-colors duration-300"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3
                      class="text-lg font-medium mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-emerald-600 dark:group-hover:text-emerald-400"
                    >
                      Background Processing
                    </h3>
                    <p
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300"
                    >
                      Audio analysis in isolates for smooth UI
                    </p>
                  </div>
                </div>

                <div class="flex items-start space-x-4 group">
                  <div
                    class="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 mt-1 bg-emerald-100 dark:bg-emerald-900/50 transition-colors duration-300 group-hover:scale-110"
                  >
                    <svg
                      class="w-4 h-4 text-emerald-600 dark:text-emerald-400 transition-colors duration-300"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3
                      class="text-lg font-medium mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-emerald-600 dark:group-hover:text-emerald-400"
                    >
                      Pre-validation
                    </h3>
                    <p
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300"
                    >
                      Filters non-speech audio to reduce costs
                    </p>
                  </div>
                </div>

                <div class="flex items-start space-x-4 group">
                  <div
                    class="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 mt-1 bg-emerald-100 dark:bg-emerald-900/50 transition-colors duration-300 group-hover:scale-110"
                  >
                    <svg
                      class="w-4 h-4 text-emerald-600 dark:text-emerald-400 transition-colors duration-300"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                  <div>
                    <h3
                      class="text-lg font-medium mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300 group-hover:text-emerald-600 dark:group-hover:text-emerald-400"
                    >
                      Smart Retry Logic
                    </h3>
                    <p
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300"
                    >
                      Intelligent policies with circuit breaker
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Performance Metrics Visualization - Enhanced with glassmorphism -->
            <div
              class="rounded-3xl p-8 glass-card scroll-reveal-scale shadow-xl border-slate-200 dark:border-slate-700"
            >
              <div class="text-center mb-8">
                <div
                  class="text-5xl sm:text-6xl font-bold mb-2 gradient-text-accent tabular-nums transition-colors duration-300"
                >
                  2x
                </div>
                <div
                  class="text-slate-600 dark:text-slate-400 transition-colors duration-300"
                >
                  Faster than traditional transcription
                </div>
              </div>

              <div class="space-y-5">
                <div>
                  <div class="flex justify-between text-sm mb-2">
                    <span
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300 font-medium"
                    >
                      API Efficiency
                    </span>
                    <span
                      class="font-semibold text-slate-900 dark:text-slate-50 tabular-nums transition-colors duration-300"
                    >
                      95%
                    </span>
                  </div>
                  <div
                    class="w-full rounded-full h-3 bg-slate-200 dark:bg-slate-700 transition-colors duration-300 overflow-hidden"
                  >
                    <div
                      class="h-full rounded-full bg-gradient-to-r from-sky-500 to-cyan-500 transition-all duration-1000 ease-out shadow-lg shadow-sky-500/30"
                      style="width: 95%"
                    ></div>
                  </div>
                </div>

                <div>
                  <div class="flex justify-between text-sm mb-2">
                    <span
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300 font-medium"
                    >
                      Accuracy Rate
                    </span>
                    <span
                      class="font-semibold text-slate-900 dark:text-slate-50 tabular-nums transition-colors duration-300"
                    >
                      98%
                    </span>
                  </div>
                  <div
                    class="w-full rounded-full h-3 bg-slate-200 dark:bg-slate-700 transition-colors duration-300 overflow-hidden"
                  >
                    <div
                      class="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-500 transition-all duration-1000 ease-out shadow-lg shadow-emerald-500/30"
                      style="width: 98%; animation-delay: 200ms;"
                    ></div>
                  </div>
                </div>

                <div>
                  <div class="flex justify-between text-sm mb-2">
                    <span
                      class="text-slate-600 dark:text-slate-400 transition-colors duration-300 font-medium"
                    >
                      Cost Reduction
                    </span>
                    <span
                      class="font-semibold text-slate-900 dark:text-slate-50 tabular-nums transition-colors duration-300"
                    >
                      50%
                    </span>
                  </div>
                  <div
                    class="w-full rounded-full h-3 bg-slate-200 dark:bg-slate-700 transition-colors duration-300 overflow-hidden"
                  >
                    <div
                      class="h-full rounded-full bg-gradient-to-r from-violet-500 to-purple-500 transition-all duration-1000 ease-out shadow-lg shadow-violet-500/30"
                      style="width: 50%; animation-delay: 400ms;"
                    ></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section - Enhanced -->
    <section
      class="py-16 lg:py-24 section-padding bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 transition-colors duration-300 relative overflow-hidden"
    >
      <div class="absolute inset-0 bg-grid opacity-10" />
      <!-- Animated glow spots -->
      <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-sky-500/20 rounded-full blur-3xl animate-pulse" style="animation-duration: 6s;" />
      <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-500/20 rounded-full blur-3xl animate-pulse" style="animation-duration: 8s; animation-delay: 2s;" />

      <div class="container-custom relative z-10 text-center">
        <h2 class="text-3xl sm:text-4xl sm:text-5xl font-semibold text-white mb-6 transition-colors duration-300">
          Ready to Transform Your Workflow?
        </h2>
        <p class="text-lg sm:text-xl text-slate-300 mb-12 max-w-2xl mx-auto">
          Join thousands of professionals who have streamlined their transcription process
        </p>

        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
          <RouterLink
            to="/downloads"
            class="btn-accent inline-flex items-center gap-2.5 px-8 py-4 text-base font-semibold text-white rounded-full transition-all duration-300 hover:shadow-2xl hover:scale-105 min-h-[48px]"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
            </svg>
            Get Started Free
          </RouterLink>

          <a
            href="https://aistudio.google.com/app/apikey"
            target="_blank"
            rel="noopener"
            class="btn-secondary inline-flex items-center gap-2.5 px-8 py-4 text-base font-semibold text-white border border-slate-600 rounded-full transition-all duration-300 hover:bg-slate-800 hover:shadow-xl min-h-[48px] group"
          >
            <svg class="w-5 h-5 transition-transform group-hover:rotate-45" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
            </svg>
            Get API Key
          </a>
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

.scroll-reveal-left {
  opacity: 0;
  transform: translateX(-50px);
  transition: opacity 0.8s var(--ease-out-expo),
              transform 0.8s var(--ease-out-expo);
}

.scroll-reveal-left.visible {
  opacity: 1;
  transform: translateX(0);
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

/* Tab content transitions */
.tab-content-enter-active,
.tab-content-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.tab-content-enter-from,
.tab-content-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

/* Tabular numbers */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}

/* Progress bar animation */
@keyframes fillProgress {
  from { width: 0; }
}

/* Mobile swipe hint */
@media (max-width: 640px) {
  .tab-navigation {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    scroll-snap-type: x mandatory;
  }

  .tab-snap {
    scroll-snap-align: center;
  }
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .scroll-reveal,
  .scroll-reveal-left,
  .scroll-reveal-scale {
    opacity: 1;
    transform: none;
    transition: none;
  }
}
</style>
