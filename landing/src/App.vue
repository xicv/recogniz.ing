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
            <svg class="w-8 h-8" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="1024" height="1024" rx="180" fill="white"/>
              <defs>
                <linearGradient id="waveGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" style="stop-color:#2196F3"/>
                  <stop offset="100%" style="stop-color:#00BCD4"/>
                </linearGradient>
              </defs>
              <path d="M 150 400 Q 250 300 350 400 T 450 512" stroke="url(#waveGradient)" stroke-width="30" fill="none" stroke-linecap="round"/>
              <path d="M 150 512 Q 250 600 350 512 T 450 624" stroke="url(#waveGradient)" stroke-width="30" fill="none" stroke-linecap="round"/>
              <rect x="550" y="350" width="300" height="12" rx="6" fill="#424242"/>
              <rect x="550" y="390" width="280" height="12" rx="6" fill="#616161"/>
              <rect x="550" y="430" width="290" height="12" rx="6" fill="#757575"/>
              <rect x="550" y="470" width="260" height="12" rx="6" fill="#9E9E9E"/>
              <path d="M 460 512 L 520 512" stroke="#757575" stroke-width="6" stroke-linecap="round"/>
              <path d="M 520 512 L 505 500 M 520 512 L 505 524" stroke="#757575" stroke-width="6" stroke-linecap="round"/>
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
            <a
              href="/downloads.html"
              class="bg-slate-900 hover:bg-slate-800 text-white px-10 py-5 rounded-full font-medium text-lg transition-all duration-300 hover:scale-105 inline-block"
            >
              Download Free
            </a>

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
        <div class="max-w-6xl mx-auto mb-32">
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
            <div class="text-center group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Lightning Fast</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Instant transcription with auto-copy</p>
            </div>

            <div class="text-center group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Custom Prompts</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Templates for any workflow</p>
            </div>

            <div class="text-center group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Smart Vocabulary</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Industry-specific terms</p>
            </div>

            <div class="text-center group">
              <div class="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center mx-auto mb-6 group-hover:bg-slate-200 transition-colors">
                <svg class="w-8 h-8 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <h3 class="text-lg font-medium mb-2">Cross-Platform</h3>
              <p class="text-slate-600 text-sm leading-relaxed">Works everywhere you do</p>
            </div>
          </div>
        </div>

        <!-- Simplified Download Section -->
        <div class="max-w-4xl mx-auto text-center">
          <h2 class="text-4xl font-light mb-6">Get Started</h2>
          <p class="text-xl text-slate-600 mb-12">Available on all platforms. Always free.</p>

          <!-- Cleaner platform cards -->
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
            <a href="/downloads.html" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" fill="#000"/>
                </svg>
                <h3 class="font-medium mb-1">macOS</h3>
                <p class="text-sm text-slate-500">10.15+</p>
              </div>
            </a>

            <a href="/downloads.html" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="#000" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3,12V6.75L9,5.43v6.48L3,12M20,3v8.75L10,11.9V5.21L20,3M3,13l6,.09V19.9L3,18.75V13m17,.25V22L10,20.09v-7Z"/>
                </svg>
                <h3 class="font-medium mb-1">Windows</h3>
                <p class="text-sm text-slate-500">10+</p>
              </div>
            </a>

            <a href="/downloads.html" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 32 32" fill="#000" xmlns="http://www.w3.org/2000/svg">
                  <path d="M16.672 0c-0.208 0-0.421 0.011-0.641 0.027-5.635 0.447-4.14 6.411-4.224 8.4-0.104 1.453-0.4 2.604-1.4 4.027-1.183 1.401-2.839 3.667-3.625 6.025-0.369 1.109-0.547 2.251-0.38 3.324-0.052 0.041-0.104 0.088-0.151 0.176-0.344 0.36-0.6 0.803-0.881 1.12-0.265 0.265-0.645 0.355-1.063 0.532-0.416 0.181-0.88 0.359-1.151 0.911-0.12 0.251-0.183 0.521-0.177 0.803 0 0.26 0.037 0.531 0.073 0.713 0.079 0.531 0.156 0.969 0.052 1.292-0.333 0.905-0.369 1.525-0.14 1.979 0.233 0.448 0.713 0.625 1.249 0.803 1.084 0.265 2.547 0.181 3.704 0.796 1.233 0.625 2.489 0.896 3.489 0.631 0.697-0.156 1.291-0.62 1.609-1.26 0.781-0.005 1.64-0.36 3.011-0.448 0.932-0.079 2.099 0.359 3.437 0.265 0.036 0.183 0.083 0.265 0.156 0.448v0.005c0.52 1.036 1.484 1.505 2.516 1.427 1.025-0.083 2.119-0.713 3.004-1.744 0.844-1.016 2.245-1.444 3.172-2 0.464-0.267 0.839-0.625 0.865-1.141 0.031-0.531-0.265-1.083-0.948-1.833v-0.131l-0.005-0.005c-0.229-0.265-0.333-0.713-0.453-1.233-0.115-0.537-0.24-1.047-0.656-1.396-0.084-0.073-0.167-0.089-0.255-0.177-0.073-0.052-0.163-0.083-0.251-0.088 0.573-1.704 0.349-3.396-0.235-4.923-0.708-1.88-1.953-3.52-2.896-4.645-1.063-1.339-2.104-2.609-2.083-4.489 0.036-2.871 0.317-8.177-4.724-8.188zM17.375 4.541h0.021c0.281 0 0.525 0.084 0.776 0.261 0.255 0.181 0.443 0.443 0.583 0.713 0.141 0.344 0.215 0.609 0.224 0.963 0-0.025 0.005-0.052 0.005-0.077v0.14c0-0.011-0.005-0.020-0.005-0.031l-0.005-0.032c0 0.324-0.067 0.647-0.197 0.943-0.063 0.167-0.156 0.319-0.287 0.448-0.036-0.020-0.073-0.041-0.115-0.057-0.14-0.063-0.265-0.083-0.38-0.176-0.093-0.037-0.192-0.068-0.292-0.089 0.063-0.077 0.193-0.177 0.245-0.265 0.068-0.167 0.104-0.349 0.115-0.536v-0.027c0.005-0.177-0.027-0.359-0.084-0.531-0.057-0.177-0.129-0.267-0.239-0.443-0.115-0.089-0.224-0.177-0.36-0.177h-0.020c-0.125 0-0.235 0.036-0.349 0.177-0.125 0.124-0.219 0.276-0.271 0.443-0.073 0.172-0.115 0.353-0.12 0.531v0.027c0 0.119 0.011 0.239 0.025 0.359-0.26-0.088-0.583-0.183-0.812-0.271-0.011-0.088-0.021-0.177-0.021-0.265v-0.027c-0.009-0.353 0.057-0.703 0.199-1.025 0.109-0.292 0.307-0.543 0.573-0.709 0.228-0.171 0.504-0.265 0.791-0.265zM13.427 4.62h0.047c0.188 0 0.36 0.063 0.532 0.177 0.197 0.172 0.355 0.385 0.459 0.619 0.12 0.267 0.187 0.537 0.208 0.891v0.005c0.005 0.177 0.005 0.272-0.005 0.355v0.109c-0.041 0.011-0.073 0.021-0.109 0.031-0.203 0.073-0.364 0.177-0.527 0.267 0.016-0.12 0.016-0.24 0.005-0.355v-0.021c-0.015-0.176-0.052-0.265-0.109-0.443-0.041-0.135-0.12-0.26-0.224-0.359-0.063-0.057-0.151-0.089-0.239-0.084h-0.032c-0.093 0.005-0.172 0.052-0.244 0.177-0.089 0.099-0.141 0.224-0.161 0.36-0.037 0.14-0.048 0.291-0.032 0.443v0.015c0.016 0.183 0.047 0.272 0.109 0.448 0.057 0.177 0.131 0.267 0.219 0.355 0.016 0.016 0.027 0.027 0.047 0.031-0.093 0.079-0.156 0.095-0.233 0.183-0.053 0.037-0.109 0.084-0.177 0.095-0.141-0.168-0.261-0.349-0.365-0.537-0.129-0.281-0.197-0.583-0.208-0.891-0.021-0.301 0.016-0.604 0.104-0.891 0.079-0.26 0.204-0.505 0.38-0.713 0.172-0.177 0.344-0.265 0.557-0.265zM15.255 6.896c0.443 0 0.975 0.083 1.62 0.531 0.391 0.267 0.699 0.36 1.407 0.62 0.344 0.183 0.541 0.36 0.64 0.537v-0.177c0.095 0.197 0.105 0.421 0.021 0.624-0.167 0.417-0.688 0.86-1.421 1.125v0.005c-0.355 0.177-0.667 0.443-1.032 0.62-0.369 0.177-0.787 0.391-1.349 0.355-0.203 0.009-0.405-0.021-0.599-0.089-0.145-0.077-0.291-0.167-0.427-0.265-0.26-0.177-0.484-0.443-0.817-0.62v-0.005h-0.005c-0.537-0.328-0.823-0.683-0.917-0.948-0.088-0.359-0.005-0.624 0.261-0.801 0.296-0.177 0.504-0.36 0.64-0.448 0.14-0.099 0.193-0.136 0.235-0.172h0.005v-0.005c0.224-0.271 0.577-0.625 1.12-0.803 0.181-0.047 0.391-0.083 0.619-0.083zM18.984 9.749c0.48 1.891 1.6 4.636 2.319 5.964 0.38 0.713 1.14 2.213 1.468 4.032 0.208-0.005 0.437 0.025 0.683 0.088 0.864-2.229-0.724-4.625-1.448-5.292-0.297-0.265-0.312-0.443-0.167-0.443 0.787 0.708 1.817 2.095 2.192 3.672 0.172 0.713 0.215 1.475 0.032 2.229 0.088 0.036 0.177 0.083 0.271 0.088 1.375 0.715 1.885 1.251 1.64 2.052v-0.057c-0.077-0.004-0.161 0-0.239 0h-0.021c0.204-0.624-0.244-1.104-1.421-1.635-1.219-0.531-2.193-0.448-2.36 0.62-0.011 0.057-0.015 0.088-0.020 0.183-0.095 0.031-0.188 0.067-0.281 0.083-0.573 0.36-0.881 0.896-1.057 1.584-0.172 0.713-0.224 1.541-0.271 2.495-0.032 0.448-0.229 1.119-0.428 1.801-2 1.432-4.776 2.052-7.129 0.448-0.152-0.26-0.329-0.5-0.537-0.713-0.099-0.167-0.224-0.312-0.369-0.443 0.244 0 0.453-0.041 0.62-0.089 0.192-0.093 0.344-0.255 0.421-0.447 0.141-0.355 0-0.928-0.464-1.553-0.457-0.619-1.239-1.323-2.38-2.025-0.843-0.531-1.317-1.161-1.536-1.86-0.219-0.713-0.188-1.448-0.021-2.192 0.328-1.427 1.167-2.817 1.704-3.688 0.14-0.083 0.047 0.183-0.547 1.303-0.527 1-1.521 3.328-0.163 5.135 0.053-1.317 0.344-2.619 0.865-3.833 0.749-1.703 2.323-4.671 2.448-7.025 0.063 0.052 0.287 0.183 0.385 0.271 0.287 0.177 0.505 0.443 0.787 0.62 0.281 0.265 0.635 0.448 1.167 0.448 0.052 0.005 0.099 0.005 0.145 0.005 0.547 0 0.975-0.177 1.328-0.355 0.385-0.183 0.699-0.448 0.989-0.536h0.005c0.62-0.177 1.115-0.537 1.391-0.933z"/>
                </svg>
                <h3 class="font-medium mb-1">Linux</h3>
                <p class="text-sm text-slate-500">Ubuntu 18.04+</p>
              </div>
            </a>

            <a href="/downloads.html" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="#0F1729" xmlns="http://www.w3.org/2000/svg">
                  <path d="M13 19C13 19.5523 12.5523 20 12 20C11.4477 20 11 19.5523 11 19C11 18.4477 11.4477 18 12 18C12.5523 18 13 18.4477 13 19Z"/>
                  <path fill-rule="evenodd" clip-rule="evenodd" d="M9.23417 1L9.28281 1.00001C9.2904 1 9.298 1 9.30559 1.00001H14.6944C14.702 1 14.7096 1 14.7172 1.00001L14.7658 1C14.7898 1 14.813 0.999997 14.8357 1.00001H15C15.0164 1.00001 15.0327 1.0004 15.0489 1.00118C15.1351 1.00243 15.2118 1.00496 15.2841 1.01011C17.2693 1.15145 18.8486 2.73075 18.9899 4.71593C19.0001 4.85862 19 5.01839 19 5.23416L19 17.212C19 18.0305 19 18.7061 18.9544 19.2561C18.9069 19.8274 18.805 20.3523 18.5497 20.8439C18.1702 21.5745 17.5745 22.1702 16.8439 22.5497C16.3523 22.805 15.8274 22.9069 15.2561 22.9544C14.7061 23 14.0306 23 13.2121 23H10.7879C9.96946 23 9.29391 23 8.74394 22.9544C8.17259 22.9069 7.64775 22.805 7.15611 22.5497C6.42554 22.1702 5.82986 21.5745 5.45035 20.8439C5.19497 20.3523 5.09311 19.8274 5.04566 19.2561C4.99998 18.7061 4.99999 18.0305 5.00001 17.212L5 5.23417C4.99997 5.0184 4.99995 4.85862 5.01011 4.71593C5.15145 2.73075 6.73075 1.15145 8.71593 1.01011C8.78824 1.00496 8.86493 1.00243 8.95107 1.00118C8.96729 1.0004 8.9836 1.00001 9.00001 1.00001H9.16434C9.18696 0.999997 9.21023 1 9.23417 1ZM9.27151 3.00001C9.00219 3.00001 8.91996 3.00064 8.85797 3.00506C7.86538 3.07573 7.07573 3.86538 7.00506 4.85797C7.00064 4.91996 7.00001 5.00219 7.00001 5.27151V17.17C7.00001 18.041 7.00081 18.6331 7.0388 19.0906C7.07579 19.536 7.1428 19.7634 7.22518 19.922C7.41493 20.2872 7.71277 20.5851 8.07806 20.7748C8.23664 20.8572 8.46402 20.9242 8.90946 20.9612C9.36687 20.9992 9.95899 21 10.83 21H13.17C14.041 21 14.6331 20.9992 15.0906 20.9612C15.536 20.9242 15.7634 20.8572 15.922 20.7748C16.2872 20.5851 16.5851 20.2872 16.7748 19.922C16.8572 19.7634 16.9242 19.536 16.9612 19.0906C16.9992 18.6331 17 18.041 17 17.17V5.27151C17 5.00219 16.9994 4.91996 16.995 4.85797C16.9243 3.86538 16.1346 3.07573 15.142 3.00506C15.0801 3.00064 14.9978 3.00001 14.7285 3.00001C14.6616 3.00001 14.6541 3.00017 14.6491 3.00037C14.5206 3.00524 14.3989 3.05943 14.3094 3.15168C14.3058 3.1553 14.3007 3.16075 14.256 3.21046L13.7673 3.75343L13.7548 3.76722C13.7489 3.77362 13.7374 3.78609 13.7227 3.80087C13.6914 3.83231 13.6352 3.88538 13.5553 3.93802C13.4595 4.00108 13.3541 4.04803 13.2432 4.07701C13.1506 4.1012 13.0735 4.10751 13.0293 4.1097C13.0084 4.11073 12.9914 4.11096 12.9828 4.11104L12.9642 4.11112H11.0359L11.0172 4.11104C11.0086 4.11096 10.9916 4.11073 10.9708 4.1097C10.9265 4.10751 10.8494 4.1012 10.7568 4.07701C10.6459 4.04803 10.5405 4.00108 10.4447 3.93802C10.3648 3.88538 10.3086 3.83231 10.2773 3.80087C10.2627 3.78609 10.2511 3.77362 10.2452 3.76722L10.2327 3.75343L9.74405 3.21046C9.69932 3.16075 9.69418 3.1553 9.69066 3.15168C9.60108 3.05943 9.47941 3.00524 9.35092 3.00037C9.34587 3.00017 9.33838 3.00001 9.27151 3.00001Z"/>
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
            <svg class="w-7 h-7" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="1024" height="1024" rx="180" fill="white"/>
              <defs>
                <linearGradient id="waveGradientFooter" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" style="stop-color:#2196F3"/>
                  <stop offset="100%" style="stop-color:#00BCD4"/>
                </linearGradient>
              </defs>
              <path d="M 150 400 Q 250 300 350 400 T 450 512" stroke="url(#waveGradientFooter)" stroke-width="30" fill="none" stroke-linecap="round"/>
              <path d="M 150 512 Q 250 600 350 512 T 450 624" stroke="url(#waveGradientFooter)" stroke-width="30" fill="none" stroke-linecap="round"/>
              <rect x="550" y="350" width="300" height="12" rx="6" fill="#424242"/>
              <rect x="550" y="390" width="280" height="12" rx="6" fill="#616161"/>
              <rect x="550" y="430" width="290" height="12" rx="6" fill="#757575"/>
              <rect x="550" y="470" width="260" height="12" rx="6" fill="#9E9E9E"/>
              <path d="M 460 512 L 520 512" stroke="#757575" stroke-width="6" stroke-linecap="round"/>
              <path d="M 520 512 L 505 500 M 520 512 L 505 524" stroke="#757575" stroke-width="6" stroke-linecap="round"/>
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