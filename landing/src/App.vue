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

// FAQ data
const faqs = [
  {
    question: "Is Recogniz.ing really free?",
    answer: "Yes! The app is completely free to download and use. You only need a Google Gemini API key, which you can get for free from Google AI Studio."
  },
  {
    question: "How much does it cost to use the Gemini API?",
    answer: "Google Gemini API offers a generous free tier that covers thousands of transcription requests per month. For most users, this is more than enough. Paid plans are available if you need more."
  },
  {
    question: "Does it work without an internet connection?",
    answer: "The app requires an internet connection to transcribe audio as it needs to communicate with the Gemini API. However, your transcriptions are stored locally on your device."
  },
  {
    question: "Can I use custom vocabulary and prompts?",
    answer: "Absolutely! Recogniz.ing comes with 6 pre-configured vocabulary sets and 6 prompt templates. You can also create your own custom vocabulary and prompts for specialized use cases."
  },
  {
    question: "Is my data private and secure?",
    answer: "Yes. Your audio recordings and transcriptions are stored locally on your device. They are only sent to Google's servers for transcription and are not stored anywhere else."
  },
  {
    question: "What languages are supported?",
    answer: "Recogniz.ing supports all languages that Google Gemini API supports, including English, Spanish, French, German, Chinese, Japanese, and many more."
  }
]
</script>

<template>
  <div class="min-h-screen bg-white">
    <!-- Navigation -->
    <nav class="fixed top-0 w-full bg-white/95 backdrop-blur-sm z-50 border-b border-slate-200">
      <div class="container-custom px-4 py-3">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-2">
            <svg class="w-7 h-7" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="32" height="32" rx="8" fill="#2563EB"/>
              <path d="M10 20V12C10 11.4477 10.4477 11 11 11H21C21.5523 11 22 11.4477 22 12V20C22 20.5523 21.5523 21 21 21H11C10.4477 21 10 20.5523 10 20Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M13 14L19 14" stroke="white" stroke-width="2" stroke-linecap="round"/>
              <path d="M13 17L17 17" stroke="white" stroke-width="2" stroke-linecap="round"/>
            </svg>
            <span class="text-xl font-display font-bold text-slate-900">Recogniz.ing</span>
          </div>
          <button
            @click="scrollToSection('download')"
            class="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2 rounded-full font-medium transition-all duration-200"
          >
            Download
          </button>
        </div>
      </div>
    </nav>

    <!-- Hero Section -->
    <section class="pt-16 pb-12 sm:pt-20 sm:pb-16 section-padding">
      <div class="container-custom text-center">
        <div
          :class="[
            'max-w-5xl mx-auto',
            isVisible ? 'animate-fade-in' : 'opacity-0'
          ]"
        >
          <h1 class="text-5xl sm:text-6xl lg:text-7xl font-display font-bold leading-tight mb-8">
            AI Voice Typing
            <span class="gradient-text"> That Understands You</span>
          </h1>

          <p class="text-xl sm:text-2xl text-slate-600 mb-12 max-w-3xl mx-auto leading-relaxed">
            Free AI-powered voice typing with customizable prompts and vocabulary.
            Just add your Gemini API key and start transcribing.
          </p>

          <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16">
            <button
              @click="scrollToSection('download')"
              class="bg-primary-600 hover:bg-primary-700 text-white px-8 py-4 rounded-full font-semibold text-lg transition-all duration-200 transform hover:scale-105"
            >
              Download for Free
            </button>

            <a
              href="https://makersuite.google.com/app/apikey"
              target="_blank"
              rel="noopener"
              class="bg-slate-100 hover:bg-slate-200 text-slate-700 px-8 py-4 rounded-full font-semibold text-lg transition-all duration-200"
            >
              Get Gemini API Key
            </a>
          </div>

          <div class="flex items-center justify-center space-x-8 text-sm text-slate-500">
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span>No subscription</span>
            </div>
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span>Works offline</span>
            </div>
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span>Cross-platform</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="py-20 section-padding bg-slate-50">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto text-center mb-16">
          <h2 class="text-4xl font-display font-bold mb-6">
            Built for Your Workflow
          </h2>
          <p class="text-xl text-slate-600">
            Customize every aspect to match your unique needs
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-shadow">
            <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-3">Lightning Fast</h3>
            <p class="text-slate-600">
              Instant transcription with auto-copy to clipboard. No waiting, no delays.
            </p>
          </div>

          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-shadow">
            <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-3">Custom Prompts</h3>
            <p class="text-slate-600">
              Create templates for emails, meeting notes, or anything you need.
            </p>
          </div>

          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-shadow">
            <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-3">Smart Vocabulary</h3>
            <p class="text-slate-600">
              Industry-specific terms from medical to tech, recognized perfectly.
            </p>
          </div>

          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-shadow">
            <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-3">Auto Copy</h3>
            <p class="text-slate-600">
              Transcriptions automatically copied to your clipboard instantly.
            </p>
          </div>

          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-shadow">
            <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-3">6 Prompt Templates</h3>
            <p class="text-slate-600">
              Pre-built templates for emails, bullet points, formal writing, and more.
            </p>
          </div>

          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-shadow">
            <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-3">Cross-Platform</h3>
            <p class="text-slate-600">
              Works on macOS, Windows, Linux, iOS, and Android devices.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Use Cases Section -->
    <section class="py-20 section-padding">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto text-center mb-16">
          <h2 class="text-4xl font-display font-bold mb-6">
            Perfect for Every Scenario
          </h2>
          <p class="text-xl text-slate-600">
            From quick notes to professional documents
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div class="text-center">
            <div class="w-16 h-16 bg-slate-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
              </svg>
            </div>
            <h4 class="font-semibold mb-2">Meeting Notes</h4>
            <p class="text-sm text-slate-600">Capture discussions instantly</p>
          </div>

          <div class="text-center">
            <div class="w-16 h-16 bg-slate-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
              </svg>
            </div>
            <h4 class="font-semibold mb-2">Email Drafts</h4>
            <p class="text-sm text-slate-600">Compose emails by voice</p>
          </div>

          <div class="text-center">
            <div class="w-16 h-16 bg-slate-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z"/>
              </svg>
            </div>
            <h4 class="font-semibold mb-2">Study Notes</h4>
            <p class="text-sm text-slate-600">Convert lectures to text</p>
          </div>

          <div class="text-center">
            <div class="w-16 h-16 bg-slate-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/>
              </svg>
            </div>
            <h4 class="font-semibold mb-2">Creative Writing</h4>
            <p class="text-sm text-slate-600">Let ideas flow naturally</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Download Section -->
    <section class="py-20 section-padding bg-slate-50">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto text-center mb-16">
          <h2 class="text-4xl font-display font-bold mb-6">
            Download for Your Platform
          </h2>
          <p class="text-xl text-slate-600">
            Available on all major platforms. Always free, no subscription required.
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mb-16">
          <!-- macOS -->
          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-all duration-200 text-center">
            <svg class="w-16 h-16 mx-auto mb-6" viewBox="0 0 24 24" fill="none">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" fill="#000"/>
            </svg>
            <h3 class="text-xl font-semibold mb-2">macOS</h3>
            <p class="text-slate-600 mb-4">10.15 or later</p>
            <a href="#" class="bg-primary-600 hover:bg-primary-700 text-white px-6 py-3 rounded-full font-medium transition-colors">
              Download .dmg
            </a>
          </div>

          <!-- Windows -->
          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-all duration-200 text-center">
            <svg class="w-16 h-16 mx-auto mb-6" viewBox="0 0 24 24" fill="none">
              <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-12.9-1.801" fill="#0078D4"/>
            </svg>
            <h3 class="text-xl font-semibold mb-2">Windows</h3>
            <p class="text-slate-600 mb-4">Windows 10 or later</p>
            <a href="#" class="bg-primary-600 hover:bg-primary-700 text-white px-6 py-3 rounded-full font-medium transition-colors">
              Download .exe
            </a>
          </div>

          <!-- Linux -->
          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-all duration-200 text-center">
            <svg class="w-16 h-16 mx-auto mb-6" viewBox="0 0 24 24" fill="none">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" fill="#FCC624"/>
            </svg>
            <h3 class="text-xl font-semibold mb-2">Linux</h3>
            <p class="text-slate-600 mb-4">Ubuntu 18.04+</p>
            <a href="#" class="bg-primary-600 hover:bg-primary-700 text-white px-6 py-3 rounded-full font-medium transition-colors">
              Download .AppImage
            </a>
          </div>

          <!-- Mobile -->
          <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-all duration-200 text-center">
            <svg class="w-16 h-16 mx-auto mb-6" viewBox="0 0 24 24" fill="none">
              <rect x="6" y="2" width="12" height="20" rx="2" fill="#000"/>
              <rect x="8" y="4" width="8" height="12" fill="#fff"/>
              <circle cx="12" cy="18" r="1" fill="#fff"/>
            </svg>
            <h3 class="text-xl font-semibold mb-2">Mobile</h3>
            <p class="text-slate-600 mb-4">iOS 15+ / Android 8+</p>
            <div class="space-y-2">
              <a href="#" class="bg-black hover:bg-gray-800 text-white px-6 py-2 rounded-full font-medium text-sm transition-colors block">
                App Store
              </a>
              <a href="#" class="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-full font-medium text-sm transition-colors block">
                Google Play
              </a>
            </div>
          </div>
        </div>

        <div class="text-center">
          <p class="text-slate-600">
            <strong>Step 1:</strong> Download and install the app<br>
            <strong>Step 2:</strong> Get your free <a href="https://makersuite.google.com/app/apikey" target="_blank" class="text-primary-600 hover:underline">Gemini API Key</a><br>
            <strong>Step 3:</strong> Start voice typing!
          </p>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section id="faq" class="py-20 section-padding">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto text-center mb-16">
          <h2 class="text-4xl font-display font-bold mb-6">
            Frequently Asked Questions
          </h2>
          <p class="text-xl text-slate-600">
            Got questions? We've got answers.
          </p>
        </div>

        <div class="max-w-3xl mx-auto space-y-3">
          <div
            v-for="(faq, index) in faqs"
            :key="index"
            class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden"
          >
            <button
              @click="toggleFaq(index)"
              class="w-full px-6 py-4 text-left flex items-center justify-between hover:bg-slate-50 transition-colors"
            >
              <h3 class="text-lg font-semibold">{{ faq.question }}</h3>
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
              class="px-6 overflow-hidden transition-all duration-300 ease-in-out"
              :class="openFaq === index ? 'max-h-96 pb-4' : 'max-h-0'"
            >
              <p class="text-slate-600">{{ faq.answer }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section id="download" class="py-20 section-padding bg-primary-600">
      <div class="container-custom text-center">
        <div class="max-w-3xl mx-auto text-white">
          <h2 class="text-4xl font-display font-bold mb-6">
            Start Voice Typing Today
          </h2>
          <p class="text-xl mb-12 opacity-90">
            Completely free. Just your Gemini API key required.
          </p>

          <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
            <a
              href="#"
              class="bg-white text-primary-600 hover:bg-slate-100 px-8 py-4 rounded-full font-semibold text-lg transition-all duration-200 transform hover:scale-105"
            >
              Download for All Platforms
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="py-12 section-padding border-t border-slate-200">
      <div class="container-custom">
        <div class="flex flex-col md:flex-row items-center justify-between">
          <div class="flex items-center space-x-2 mb-4 md:mb-0">
            <svg class="w-6 h-6" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="32" height="32" rx="8" fill="#2563EB"/>
              <path d="M10 20V12C10 11.4477 10.4477 11 11 11H21C21.5523 11 22 11.4477 22 12V20C22 20.5523 21.5523 21 21 21H11C10.4477 21 10 20.5523 10 20Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M13 14L19 14" stroke="white" stroke-width="2" stroke-linecap="round"/>
              <path d="M13 17L17 17" stroke="white" stroke-width="2" stroke-linecap="round"/>
            </svg>
            <span class="text-xl font-display font-bold text-slate-900">Recogniz.ing</span>
          </div>
          <p class="text-slate-600 text-sm">
            Powered by Google Gemini API. Free forever.
          </p>
        </div>
      </div>
    </footer>
  </div>
</template>