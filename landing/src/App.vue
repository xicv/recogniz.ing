<script setup lang="ts">
import { ref, onMounted } from 'vue'

const isVisible = ref(false)

onMounted(() => {
  isVisible.value = true
})

const scrollToSection = (sectionId: string) => {
  const element = document.getElementById(sectionId)
  element?.scrollIntoView({ behavior: 'smooth' })
}

// FAQ state management
const openFaq = ref<number | null>(null)

const toggleFaq = (index: number) => {
  openFaq.value = openFaq.value === index ? null : index
}

// FAQ data - simplified
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
  }
]
</script>

<template>
  <div class="min-h-screen bg-white">
    <!-- Navigation -->
    <nav class="fixed top-0 w-full bg-white/80 backdrop-blur-xl z-50 border-b border-slate-100">
      <div class="container-custom px-6 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <svg class="w-8 h-8" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="32" height="32" rx="10" fill="#2563EB"/>
              <path d="M10 20V12C10 11.4477 10.4477 11 11 11H21C21.5523 11 22 11.4477 22 12V20C22 20.5523 21.5523 21 21 21H11C10.4477 21 10 20.5523 10 20Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M13 14L19 14" stroke="white" stroke-width="2" stroke-linecap="round"/>
              <path d="M13 17L17 17" stroke="white" stroke-width="2" stroke-linecap="round"/>
            </svg>
            <span class="text-2xl font-display font-light tracking-tight text-slate-900">Recogniz.ing</span>
          </div>
          <button
            @click="scrollToSection('download')"
            class="text-slate-700 hover:text-slate-900 font-medium transition-colors"
          >
            Download
          </button>
        </div>
      </div>
    </nav>

    <!-- Hero Section - simplified and more spacious -->
    <section class="pt-32 pb-24 section-padding">
      <div class="container-custom text-center">
        <div
          :class="[
            'max-w-4xl mx-auto',
            isVisible ? 'animate-fade-in' : 'opacity-0'
          ]"
        >
          <!-- Simplified headline -->
          <h1 class="text-6xl sm:text-7xl lg:text-8xl font-light leading-tight mb-8 tracking-tight">
            Voice Typing
            <span class="font-medium"> That Understands</span>
          </h1>

          <!-- Simplified subheading -->
          <p class="text-2xl text-slate-500 mb-16 max-w-2xl mx-auto leading-relaxed font-light">
            Free AI-powered voice typing. Your words, your vocabulary, your style.
          </p>

          <!-- Cleaner CTA buttons -->
          <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mb-20">
            <button
              @click="scrollToSection('download')"
              class="bg-slate-900 hover:bg-slate-800 text-white px-10 py-5 rounded-full font-medium text-lg transition-all duration-300 hover:scale-105"
            >
              Download Free
            </button>

            <a
              href="https://aistudio.google.com/app/apikey"
              target="_blank"
              rel="noopener"
              class="border border-slate-300 hover:border-slate-400 text-slate-700 px-10 py-5 rounded-full font-medium text-lg transition-all duration-300"
            >
              Get API Key
            </a>
          </div>

          <!-- Simplified trust indicators -->
          <div class="flex items-center justify-center space-x-12 text-sm text-slate-400">
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span>Forever Free</span>
            </div>
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span>All Platforms</span>
            </div>
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span>Private & Secure</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Combined Features & Download Section - removing redundancy -->
    <section id="download" class="py-32 section-padding bg-slate-50">
      <div class="container-custom">
        <!-- Simplified features - only 4 key points -->
        <div class="max-w-5xl mx-auto mb-32">
          <div class="grid md:grid-cols-2 gap-16">
            <div class="space-y-4">
              <div class="flex items-start space-x-4">
                <div class="w-10 h-10 bg-slate-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <svg class="w-5 h-5 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-lg font-medium mb-1">Lightning Fast</h3>
                  <p class="text-slate-600">Instant transcription with auto-copy</p>
                </div>
              </div>
            </div>

            <div class="space-y-4">
              <div class="flex items-start space-x-4">
                <div class="w-10 h-10 bg-slate-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <svg class="w-5 h-5 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-lg font-medium mb-1">Custom Prompts</h3>
                  <p class="text-slate-600">Templates for any workflow</p>
                </div>
              </div>
            </div>

            <div class="space-y-4">
              <div class="flex items-start space-x-4">
                <div class="w-10 h-10 bg-slate-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <svg class="w-5 h-5 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-lg font-medium mb-1">Smart Vocabulary</h3>
                  <p class="text-slate-600">Industry-specific terms</p>
                </div>
              </div>
            </div>

            <div class="space-y-4">
              <div class="flex items-start space-x-4">
                <div class="w-10 h-10 bg-slate-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <svg class="w-5 h-5 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-lg font-medium mb-1">Cross-Platform</h3>
                  <p class="text-slate-600">Works everywhere you do</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Simplified Download Section -->
        <div class="max-w-4xl mx-auto text-center">
          <h2 class="text-4xl font-light mb-6">Get Started</h2>
          <p class="text-xl text-slate-600 mb-12">Available on all platforms. Always free.</p>

          <!-- Cleaner platform cards -->
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
            <a href="#" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" fill="#000"/>
                </svg>
                <h3 class="font-medium mb-1">macOS</h3>
                <p class="text-sm text-slate-500">10.15+</p>
              </div>
            </a>

            <a href="#" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-12.9-1.801" fill="#0078D4"/>
                </svg>
                <h3 class="font-medium mb-1">Windows</h3>
                <p class="text-sm text-slate-500">10+</p>
              </div>
            </a>

            <a href="#" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" fill="#FCC624"/>
                </svg>
                <h3 class="font-medium mb-1">Linux</h3>
                <p class="text-sm text-slate-500">Ubuntu 18.04+</p>
              </div>
            </a>

            <a href="#" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <rect x="6" y="2" width="12" height="20" rx="2" fill="#000"/>
                  <rect x="8" y="4" width="8" height="12" fill="#fff"/>
                  <circle cx="12" cy="18" r="1" fill="#fff"/>
                </svg>
                <h3 class="font-medium mb-1">Mobile</h3>
                <p class="text-sm text-slate-500">iOS & Android</p>
              </div>
            </a>
          </div>

          <!-- Simplified setup steps -->
          <div class="bg-white p-8 rounded-2xl border border-slate-200">
            <p class="text-slate-600">
              <span class="font-medium">1.</span> Download the app •
              <span class="font-medium">2.</span> Get your free <a href="https://aistudio.google.com/app/apikey" target="_blank" class="text-primary-600 hover:underline">API key</a> •
              <span class="font-medium">3.</span> Start typing
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Simplified FAQ Section -->
    <section id="faq" class="py-32 section-padding">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto text-center mb-20">
          <h2 class="text-4xl font-light mb-4">Questions?</h2>
        </div>

        <div class="max-w-3xl mx-auto space-y-4">
          <div
            v-for="(faq, index) in faqs"
            :key="index"
            class="bg-white rounded-2xl border border-slate-200 overflow-hidden"
          >
            <button
              @click="toggleFaq(index)"
              class="w-full px-8 py-6 text-left flex items-center justify-between hover:bg-slate-50 transition-colors"
            >
              <h3 class="text-lg font-medium">{{ faq.question }}</h3>
              <svg
                class="w-5 h-5 text-slate-400 transition-transform duration-200"
                :class="{ 'rotate-180': openFaq === index }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
              </svg>
            </button>
            <div
              class="px-8 overflow-hidden transition-all duration-300 ease-in-out"
              :class="openFaq === index ? 'max-h-96 pb-6' : 'max-h-0'"
            >
              <p class="text-slate-600">{{ faq.answer }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Simplified Footer -->
    <footer class="py-16 border-t border-slate-100">
      <div class="container-custom">
        <div class="flex flex-col md:flex-row items-center justify-between">
          <div class="flex items-center space-x-3 mb-6 md:mb-0">
            <svg class="w-7 h-7" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="32" height="32" rx="10" fill="#2563EB"/>
              <path d="M10 20V12C10 11.4477 10.4477 11 11 11H21C21.5523 11 22 11.4477 22 12V20C22 20.5523 21.5523 21 21 21H11C10.4477 21 10 20.5523 10 20Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M13 14L19 14" stroke="white" stroke-width="2" stroke-linecap="round"/>
              <path d="M13 17L17 17" stroke="white" stroke-width="2" stroke-linecap="round"/>
            </svg>
            <span class="text-xl font-display font-light tracking-tight text-slate-900">Recogniz.ing</span>
          </div>
          <p class="text-slate-500 text-sm">
            Powered by Google Gemini API
          </p>
        </div>
      </div>
    </footer>
  </div>
</template>