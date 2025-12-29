<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimations } from '@/composables/useScrollAnimations'
import GradientMesh from '@/components/ui/GradientMesh.vue'
import ProductMockup from '@/components/ui/ProductMockup.vue'

useScrollAnimations()

// FAQ state management
const openFaq = ref<number | null>(null)

const toggleFaq = (index: number) => {
  openFaq.value = openFaq.value === index ? null : index
}

// FAQ data
const faqs = [
  {
    question: "Is it really free?",
    answer: "Yes! The app is completely free. You only need a Google Gemini API key."
  },
  {
    question: "How much does the API cost?",
    answer: "Google Gemini API offers a generous free tier covering thousands of transcriptions monthly."
  },
  {
    question: "Can I customize vocabulary?",
    answer: "Absolutely! Create custom vocabulary sets and prompts for specialized needs."
  },
  {
    question: "Is my data secure?",
    answer: "Yes. Recordings and transcriptions are stored locally on your device."
  },
  {
    question: "What's the BYOK model?",
    answer: "Bring Your Own Key means you use your own Gemini API key. Your data, your cost, full transparency."
  }
]

// Feature data for bento grid with asymmetric layout
const features = [
  {
    icon: 'lightning',
    title: 'Lightning Fast',
    description: 'Instant transcription with auto-copy to clipboard',
    gradient: 'bg-gradient-to-br from-amber-500 to-orange-500',
    span: 'col-span-1',
    category: 'recording'
  },
  {
    icon: 'sparkles',
    title: 'AI-Powered',
    description: 'Powered by Google Gemini 3.0 Flash for accurate transcription with intelligent context understanding',
    gradient: 'bg-gradient-to-br from-sky-500 to-cyan-500',
    span: 'col-span-1 sm:col-span-2 row-span-2',
    category: 'recording'
  },
  {
    icon: 'document',
    title: 'Custom Prompts',
    description: 'Templates for any workflow or use case',
    gradient: 'bg-gradient-to-br from-violet-500 to-purple-500',
    span: 'col-span-1',
    category: 'prompts'
  },
  {
    icon: 'book',
    title: 'Smart Vocabulary',
    description: 'Industry-specific terms and custom dictionaries',
    gradient: 'bg-gradient-to-br from-emerald-500 to-teal-500',
    span: 'col-span-1',
    category: 'vocabulary'
  },
  {
    icon: 'desktop',
    title: 'Cross-Platform',
    description: 'Works everywhere you do - desktop and mobile',
    gradient: 'bg-gradient-to-br from-rose-500 to-pink-500',
    span: 'col-span-1',
    category: 'settings'
  },
  {
    icon: 'lock',
    title: 'Private & Secure',
    description: 'All data stored locally on your device',
    gradient: 'bg-gradient-to-br from-slate-600 to-slate-800',
    span: 'col-span-1',
    category: 'settings'
  }
]

// Icon components mapping
const icons = {
  lightning: 'M13 10V3L4 14h7v7l9-11h-7z',
  sparkles: 'M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z',
  document: 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z',
  book: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253',
  desktop: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  lock: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z'
}

// Demo feature data
const demoFeatures = [
  {
    title: 'Custom Vocabulary',
    description: 'Add industry terms, names, and jargon that the AI will recognize perfectly',
    icon: icons.book
  },
  {
    title: 'Smart Prompts',
    description: 'Choose from templates or create your own for custom output formats',
    icon: icons.document
  },
  {
    title: 'Privacy First',
    description: 'All recordings and transcriptions stored locally on your device',
    icon: icons.lock
  }
]

// Hero animation state
const heroAnimated = ref(false)

onMounted(() => {
  setTimeout(() => {
    heroAnimated.value = true
  }, 100)
})
</script>

<template>
  <div>
    <!-- Hero Section - Enhanced with gradient mesh and product mockup -->
    <section class="hero-section relative min-h-screen flex items-center overflow-hidden">
      <!-- Animated gradient mesh background -->
      <GradientMesh :opacity="0.6" />

      <!-- Grid overlay -->
      <div class="absolute inset-0 bg-grid opacity-50" />

      <div class="container-custom relative z-10 pt-24 pb-16 lg:pt-32 lg:pb-24">
        <div class="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          <!-- Left: Hero Content -->
          <div class="hero-content text-center lg:text-left">
            <!-- Badge -->
            <div
              class="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm mb-8 transition-all duration-300 scroll-reveal-scale bg-slate-100/80 backdrop-blur border border-slate-200 text-slate-600 dark:bg-slate-800/80 dark:border-slate-700 dark:text-slate-400"
            >
              <span class="relative flex h-2 w-2">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-sky-500"></span>
              </span>
              v1.0.8 — Now Available
            </div>

            <!-- Headline with kinetic text effect -->
            <h1
              class="text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-bold tracking-tight mb-6 text-slate-950 dark:text-slate-50 transition-colors duration-300"
              style="font-size: clamp(2.75rem, 2rem + 4vw, 5.5rem); line-height: 1.1;"
            >
              <span class="block kinetic-word" :class="{ 'animate-in': heroAnimated }" style="animation-delay: 0ms;">
                Free AI Voice
              </span>
              <span class="block gradient-text-accent kinetic-word" :class="{ 'animate-in': heroAnimated }" style="animation-delay: 150ms;">
                Typing, Your Way
              </span>
            </h1>

            <!-- Subheading -->
            <p
              class="text-lg sm:text-xl lg:text-2xl mb-8 max-w-2xl mx-auto lg:mx-0 leading-relaxed text-slate-600 dark:text-slate-400 transition-colors duration-300 kinetic-word"
              :class="{ 'animate-in': heroAnimated }"
              style="animation-delay: 300ms;"
            >
              Your vocabulary, your style, your API key. Privacy-first voice typing that adapts to <strong>you</strong>.
            </p>

            <!-- CTA Buttons -->
            <div
              class="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 mb-12 kinetic-word"
              :class="{ 'animate-in': heroAnimated }"
              style="animation-delay: 450ms;"
            >
              <RouterLink
                to="/downloads"
                class="btn-primary inline-flex items-center gap-2 text-lg bg-slate-950 hover:bg-slate-900 dark:bg-sky-500 dark:hover:bg-sky-400 cta-pulse"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                </svg>
                Download Free
              </RouterLink>

              <a
                href="https://aistudio.google.com/app/apikey"
                target="_blank"
                rel="noopener"
                class="btn-secondary inline-flex items-center gap-2"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
                </svg>
                Get API Key
              </a>
            </div>

          </div>

          <!-- Right: Product Mockup -->
          <div class="hero-visual relative scroll-reveal-right">
            <ProductMockup />
          </div>
        </div>
      </div>

      <!-- Scroll indicator -->
      <div class="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2 text-slate-400 dark:text-slate-500 animate-bounce">
        <span class="text-xs uppercase tracking-wider">Scroll to explore</span>
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 14l-7 7m0 0l-7-7m7 7V3"/>
        </svg>
      </div>
    </section>

    <!-- Features Bento Grid Section - Asymmetric Layout -->
    <section
      class="py-24 lg:py-32 transition-colors duration-300"
      data-animate-id="features"
    >
      <div class="container-custom">
        <div class="max-w-3xl mx-auto text-center mb-16 scroll-reveal" data-animate-id="features-title">
          <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
            FEATURES
          </span>
          <h2
            class="text-4xl sm:text-5xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
          >
            Everything You Need
          </h2>
          <p class="text-xl text-slate-600 dark:text-slate-400">
            Powerful features for effortless voice typing
          </p>
        </div>

        <!-- Asymmetric Bento Grid -->
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-6 auto-rows-min">
          <div
            v-for="(feature, index) in features"
            :key="feature.title"
            :class="[feature.span, 'bento-card scroll-reveal']"
            :data-animate-id="'feature-' + index"
            :style="{ 'animation-delay': `${index * 100}ms` }"
          >
            <!-- Category badge -->
            <div
              v-if="feature.category"
              class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium mb-4"
              :class="`badge-${feature.category}`"
            >
              {{ feature.category }}
            </div>

            <!-- Icon with gradient background -->
            <div class="w-14 h-14 rounded-2xl flex items-center justify-center mb-5" :class="feature.gradient">
              <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" :d="icons[feature.icon]"/>
              </svg>
            </div>
            <h3
              class="text-xl font-semibold mb-2 text-slate-950 dark:text-slate-50 transition-colors duration-300"
            >
              {{ feature.title }}
            </h3>
            <p class="text-slate-600 dark:text-slate-400">{{ feature.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Product Demo Section -->
    <section class="py-24 lg:py-32 bg-slate-50/50 dark:bg-slate-900/30 transition-colors duration-300" data-animate-id="demo">
      <div class="container-custom">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-16 scroll-reveal" data-animate-id="demo-title">
            <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
              HOW IT WORKS
            </span>
            <h2
              class="text-4xl sm:text-5xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
            >
              See It In Action
            </h2>
            <p class="text-xl text-slate-600 dark:text-slate-400">
              How Recogniz.ing transforms your voice into perfect text
            </p>
          </div>

          <div class="grid md:grid-cols-3 gap-8">
            <div
              v-for="(demo, index) in demoFeatures"
              :key="demo.title"
              class="card shimmer scroll-reveal"
              :data-animate-id="'demo-' + index"
            >
              <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-sky-500 to-cyan-500 flex items-center justify-center mb-5">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" :d="demo.icon"/>
                </svg>
              </div>
              <h3
                class="text-lg font-semibold mb-2 text-slate-950 dark:text-slate-50 transition-colors duration-300"
              >
                {{ demo.title }}
              </h3>
              <p class="text-sm leading-relaxed text-slate-600 dark:text-slate-400">
                {{ demo.description }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Download Section -->
    <section
      id="download"
      class="py-24 lg:py-32"
      data-animate-id="download"
    >
      <div class="container-custom">
        <div class="max-w-5xl mx-auto text-center mb-16 scroll-reveal" data-animate-id="download-title">
          <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
            DOWNLOAD
          </span>
          <h2
            class="text-4xl sm:text-5xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
          >
            Get Started Today
          </h2>
          <p class="text-xl text-slate-600 dark:text-slate-400">
            Available on all platforms. Always free.
          </p>
        </div>

        <!-- Platform Cards -->
        <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 max-w-5xl mx-auto">
          <RouterLink
            to="/downloads"
            class="platform-card group scroll-reveal"
            :data-animate-id="'platform-macos'"
          >
            <div
              class="w-14 h-14 mx-auto mb-4 rounded-xl flex items-center justify-center bg-slate-100 group-hover:bg-slate-200 dark:bg-slate-800 dark:group-hover:bg-slate-700 transition-colors duration-300"
            >
              <svg class="w-8 h-8 text-slate-700 dark:text-slate-300" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
            </div>
            <h3 class="font-semibold mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300">macOS</h3>
            <p class="text-sm text-slate-500 transition-colors duration-300">10.15+</p>
          </RouterLink>

          <RouterLink
            to="/downloads"
            class="platform-card group scroll-reveal"
            :data-animate-id="'platform-windows'"
          >
            <div
              class="w-14 h-14 mx-auto mb-4 rounded-xl flex items-center justify-center bg-slate-100 group-hover:bg-slate-200 dark:bg-slate-800 dark:group-hover:bg-slate-700 transition-colors duration-300"
            >
              <svg class="w-8 h-8 text-slate-700 dark:text-slate-300" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3,12V6.75L9,5.43v6.48L3,12M20,3v8.75L10,11.9V5.21L20,3M3,13l6 .09V19.9L3,18.75V13m17 .25V22L10,20.09v-7Z"/>
              </svg>
            </div>
            <h3 class="font-semibold mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300">Windows</h3>
            <p class="text-sm text-slate-500">10+</p>
          </RouterLink>

          <RouterLink
            to="/downloads"
            class="platform-card group scroll-reveal"
            :data-animate-id="'platform-linux'"
          >
            <div
              class="w-14 h-14 mx-auto mb-4 rounded-xl flex items-center justify-center bg-slate-100 group-hover:bg-slate-200 dark:bg-slate-800 dark:group-hover:bg-slate-700 transition-colors duration-300"
            >
              <svg class="w-8 h-8 text-slate-700 dark:text-slate-300" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12.504 0c-.155 0-.315.008-.48.021-4.226.333-3.105 4.807-3.17 6.298-.076 1.092-.3 1.953-1.05 3.02-.885 1.051-2.127 2.75-2.716 4.521-.278.832-.41 1.684-.287 2.489a.424.424 0 0 0-.11.135c-.26.268-.45.6-.663.839-.199.199-.485.267-.797.4-.313.136-.658.269-.864.68-.09.189-.136.394-.132.602 0 .199.027.4.055.536.058.399.116.728.04.97-.249.68-.28 1.145-.106 1.484.174.334.535.47.94.601.81.2 1.91.135 2.774.6.926.466 1.866.67 2.616.47.526-.116.97-.464 1.208-.946.587-.003 1.23-.269 2.26-.334.699-.058 1.574.267 2.577.2.025.134.063.198.114.333l.003.003c.391.778 1.113 1.132 1.884 1.071.771-.06 1.592-.536 2.257-1.306.631-.765 1.683-1.084 2.378-1.503.348-.199.629-.469.649-.853.023-.4-.2-.811-.714-1.376v-.097l-.003-.003c-.17-.2-.25-.535-.338-.926-.085-.401-.182-.786-.492-1.046h-.003c-.059-.054-.123-.067-.188-.135a.357.357 0 0 0-.19-.064c.431-1.278.264-2.55-.173-3.694-.533-1.41-1.465-2.638-2.175-3.483-.796-1.005-1.576-1.957-1.56-3.368.026-2.152.236-6.133-3.544-6.139z"/>
              </svg>
            </div>
            <h3 class="font-semibold mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300">Linux</h3>
            <p class="text-sm text-slate-500">Ubuntu 18.04+</p>
          </RouterLink>

          <RouterLink
            to="/downloads"
            class="platform-card group scroll-reveal"
            :data-animate-id="'platform-ios'"
          >
            <div
              class="w-14 h-14 mx-auto mb-4 rounded-xl flex items-center justify-center bg-slate-100 group-hover:bg-slate-200 dark:bg-slate-800 dark:group-hover:bg-slate-700 transition-colors duration-300"
            >
              <svg class="w-8 h-8 text-slate-700 dark:text-slate-300" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
            </div>
            <h3 class="font-semibold mb-1 text-slate-950 dark:text-slate-50 transition-colors duration-300">iOS</h3>
            <p class="text-sm text-slate-500">15.0+</p>
          </RouterLink>
        </div>

        <p class="text-center mt-8 text-slate-500 transition-colors duration-300">
          Also available on Android and iPadOS
        </p>
      </div>
    </section>

    <!-- FAQ Section -->
    <section
      class="py-24 lg:py-32 bg-slate-50/50 dark:bg-slate-900/30 transition-colors duration-300"
      data-animate-id="faq"
    >
      <div class="container-custom">
        <div class="max-w-3xl mx-auto">
          <div class="text-center mb-12 scroll-reveal" data-animate-id="faq-title">
            <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold mb-4 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400">
              FAQ
            </span>
            <h2
              class="text-4xl sm:text-5xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
            >
              Questions?
            </h2>
            <p class="text-xl text-slate-600 dark:text-slate-400">
              We're here to help
            </p>
          </div>

          <!-- FAQ Accordion -->
          <div class="space-y-3">
            <div
              v-for="(faq, index) in faqs"
              :key="index"
              class="faq-item scroll-reveal"
              :data-animate-id="'faq-' + index"
              @click="toggleFaq(index)"
            >
              <button class="w-full flex items-center justify-between p-6 text-left">
                <span
                  class="text-lg font-semibold text-slate-900 dark:text-slate-50 transition-colors duration-300"
                >
                  {{ faq.question }}
                </span>
                <svg
                  class="w-5 h-5 transition-transform duration-300 flex-shrink-0 ml-4 text-slate-400 dark:text-slate-500"
                  :class="{ 'rotate-180': openFaq === index }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                </svg>
              </button>
              <div
                class="px-6 overflow-hidden transition-all duration-300 ease-in-out"
                :class="openFaq === index ? 'max-h-32 pb-6' : 'max-h-0'"
              >
                <p class="text-slate-600 dark:text-slate-400">{{ faq.answer }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Final CTA Section -->
    <section class="py-24 lg:py-32 relative overflow-hidden" data-animate-id="cta">
      <!-- Background gradient -->
      <div class="absolute inset-0 bg-gradient-to-br from-slate-900 to-slate-800" />
      <div class="absolute inset-0 bg-grid opacity-10" />

      <div class="container-custom relative z-10">
        <div class="max-w-3xl mx-auto text-center scroll-reveal" data-animate-id="cta-title">
          <h2
            class="text-4xl sm:text-5xl font-semibold mb-6 text-white transition-colors duration-300"
          >
            Ready to Get Started?
          </h2>
          <p class="text-xl mb-10 text-slate-300">
            Join thousands of users who are already typing smarter, not harder.
          </p>
          <RouterLink
            to="/downloads"
            class="inline-flex items-center gap-2 px-8 py-4 text-lg font-semibold text-white rounded-full transition-all duration-300 hover:shadow-xl hover:scale-105 bg-slate-950 hover:bg-slate-900 dark:bg-sky-500 dark:hover:bg-sky-400"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
            </svg>
            Download Now
          </RouterLink>
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

.scroll-reveal-right {
  opacity: 0;
  transform: translateX(50px);
  transition: opacity 0.8s var(--ease-out-expo),
              transform 0.8s var(--ease-out-expo);
}

.scroll-reveal-right.visible {
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

/* Kinetic word animation */
.kinetic-word {
  display: inline-block;
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.6s var(--ease-out-expo),
              transform 0.6s var(--ease-out-expo);
}

.kinetic-word.animate-in {
  opacity: 1;
  transform: translateY(0);
}

/* Tabular numbers for stats */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}

/* Stagger animations for bento grid */
.bento-card:nth-child(1) { transition-delay: 0ms; }
.bento-card:nth-child(2) { transition-delay: 100ms; }
.bento-card:nth-child(3) { transition-delay: 200ms; }
.bento-card:nth-child(4) { transition-delay: 300ms; }
.bento-card:nth-child(5) { transition-delay: 400ms; }
.bento-card:nth-child(6) { transition-delay: 500ms; }

/* Hero section specific */
.hero-section {
  min-height: 100vh;
}

@media (max-width: 1024px) {
  .hero-content {
    text-center: !important;
  }

  .hero-visual {
    order: -1;
    margin-bottom: 2rem;
  }
}

/* Reduced motion */
@media (prefers-reduce-motion: reduce) {
  .kinetic-word,
  .scroll-reveal,
  .scroll-reveal-right,
  .scroll-reveal-scale {
    opacity: 1;
    transform: none;
    transition: none;
  }
}
</style>
