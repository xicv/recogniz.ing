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
  <div>
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
            <RouterLink
              to="/downloads"
              class="bg-slate-900 hover:bg-slate-800 text-white px-10 py-5 rounded-full font-medium text-lg transition-all duration-300 hover:scale-105 inline-block"
            >
              Download Free
            </RouterLink>

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
            <RouterLink to="/downloads" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" fill="#000"/>
                </svg>
                <h3 class="font-medium mb-1">macOS</h3>
                <p class="text-sm text-slate-500">10.15+</p>
              </div>
            </RouterLink>

            <RouterLink to="/downloads" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="#000" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3,12V6.75L9,5.43v6.48L3,12M20,3v8.75L10,11.9V5.21L20,3M3,13l6,.09V19.9L3,18.75V13m17,.25V22L10,20.09v-7Z"/>
                </svg>
                <h3 class="font-medium mb-1">Windows</h3>
                <p class="text-sm text-slate-500">10+</p>
              </div>
            </RouterLink>

            <RouterLink to="/downloads" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 32 32" fill="#000" xmlns="http://www.w3.org/2000/svg">
                  <path d="M16.672 0c-0.208 0-0.421 0.011-0.641 0.027-5.635 0.447-4.14 6.411-4.224 8.4-0.104 1.453-0.4 2.604-1.4 4.027-1.183 1.401-2.839 3.667-3.625 6.025-0.369 1.109-0.547 2.251-0.38 3.324-0.052 0.041-0.104 0.088-0.151 0.176-0.344 0.36-0.6 0.803-0.881 1.12-0.265 0.265-0.645 0.355-1.063 0.532-0.416 0.181-0.88 0.359-1.151 0.911-0.12 0.251-0.183 0.521-0.177 0.803 0 0.26 0.037 0.531 0.073 0.713 0.079 0.531 0.156 0.969 0.052 1.292-0.333 0.905-0.369 1.525-0.14 1.979 0.233 0.448 0.713 0.625 1.249 0.803 1.084 0.265 2.547 0.181 3.704 0.796 1.233 0.625 2.489 0.896 3.489 0.631 0.697-0.156 1.291-0.62 1.609-1.26 0.781-0.005 1.64-0.36 3.011-0.448 0.932-0.079 2.099 0.359 3.437 0.265 0.036 0.183 0.083 0.265 0.156 0.448v0.005c0.52 1.036 1.484 1.505 2.516 1.427 1.025-0.083 2.119-0.713 3.004-1.744 0.844-1.016 2.245-1.444 3.172-2 0.464-0.267 0.839-0.625 0.865-1.141 0.031-0.531-0.265-1.083-0.948-1.833v-0.131l-0.005-0.005c-0.229-0.265-0.333-0.713-0.453-1.233-0.115-0.537-0.24-1.047-0.656-1.396-0.084-0.073-0.167-0.089-0.255-0.177-0.073-0.052-0.163-0.083-0.251-0.088 0.573-1.704 0.349-3.396-0.235-4.923-0.708-1.88-1.953-3.52-2.896-4.645-1.063-1.339-2.104-2.609-2.083-4.489 0.036-2.871 0.317-8.177-4.724-8.188zM17.375 4.541h0.021c0.281 0 0.525 0.084 0.776 0.261 0.255 0.181 0.443 0.443 0.583 0.713 0.141 0.344 0.215 0.609 0.224 0.963 0-0.025 0.005-0.052 0.005-0.077v0.14c0-0.011-0.005-0.020-0.005-0.031l-0.005-0.032c0 0.324-0.067 0.647-0.197 0.943-0.063 0.167-0.156 0.319-0.287 0.448-0.036-0.020-0.073-0.041-0.115-0.057-0.14-0.063-0.265-0.083-0.38-0.176-0.093-0.037-0.192-0.068-0.292-0.089 0.063-0.077 0.193-0.177 0.245-0.265 0.068-0.167 0.104-0.349 0.115-0.536v-0.027c0.005-0.177-0.027-0.359-0.084-0.531-0.057-0.177-0.129-0.267-0.239-0.443-0.115-0.089-0.224-0.177-0.36-0.177h-0.020c-0.125 0-0.235 0.036-0.349 0.177-0.125 0.124-0.219 0.276-0.271 0.443-0.073 0.172-0.115 0.353-0.12 0.531v0.027c0 0.119 0.011 0.239 0.025 0.359-0.26-0.088-0.583-0.183-0.812-0.271-0.011-0.088-0.021-0.177-0.021-0.265v-0.027c-0.009-0.353 0.057-0.703 0.199-1.025 0.109-0.292 0.307-0.543 0.573-0.709 0.228-0.171 0.504-0.265 0.791-0.265zM13.427 4.62h0.047c0.188 0 0.36 0.063 0.532 0.177 0.197 0.172 0.355 0.385 0.459 0.619 0.12 0.267 0.187 0.537 0.208 0.891v0.005c0.005 0.177 0.005 0.272-0.005 0.355v0.109c-0.041 0.011-0.073 0.021-0.109 0.031-0.203 0.073-0.364 0.177-0.527 0.267 0.016-0.12 0.016-0.24 0.005-0.355v-0.021c-0.015-0.176-0.052-0.265-0.109-0.443-0.041-0.135-0.12-0.26-0.224-0.359-0.063-0.057-0.151-0.089-0.239-0.084h-0.032c-0.093 0.005-0.172 0.052-0.244 0.177-0.089 0.099-0.141 0.224-0.161 0.36-0.037 0.14-0.048 0.291-0.032 0.443v0.015c0.016 0.183 0.047 0.272 0.109 0.448 0.057 0.177 0.131 0.267 0.219 0.355 0.016 0.016 0.027 0.027 0.047 0.031-0.093 0.079-0.156 0.095-0.233 0.183-0.053 0.037-0.109 0.084-0.177 0.095-0.141-0.168-0.261-0.349-0.365-0.537-0.129-0.281-0.197-0.583-0.208-0.891-0.021-0.301 0.016-0.604 0.104-0.891 0.079-0.26 0.204-0.505 0.38-0.713 0.172-0.177 0.344-0.265 0.557-0.265zM15.255 6.896c0.443 0 0.975 0.083 1.62 0.531 0.391 0.267 0.699 0.36 1.407 0.62 0.344 0.183 0.541 0.36 0.64 0.537v-0.177c0.095 0.197 0.105 0.421 0.021 0.624-0.167 0.417-0.688 0.86-1.421 1.125v0.005c-0.355 0.177-0.667 0.443-1.032 0.62-0.369 0.177-0.787 0.391-1.349 0.355-0.203 0.009-0.405-0.021-0.599-0.089-0.145-0.077-0.291-0.167-0.427-0.265-0.26-0.177-0.484-0.443-0.817-0.62v-0.005h-0.005c-0.537-0.328-0.823-0.683-0.917-0.948-0.088-0.359-0.005-0.624 0.261-0.801 0.296-0.177 0.504-0.36 0.64-0.448 0.14-0.099 0.193-0.136 0.235-0.172h0.005v-0.005c0.224-0.271 0.577-0.625 1.12-0.803 0.181-0.047 0.391-0.083 0.619-0.083zM18.984 9.749c0.48 1.891 1.6 4.636 2.319 5.964 0.38 0.713 1.14 2.213 1.468 4.032 0.208-0.005 0.437 0.025 0.683 0.088 0.864-2.229-0.724-4.625-1.448-5.292-0.297-0.265-0.312-0.443-0.167-0.443 0.787 0.708 1.817 2.095 2.192 3.672 0.172 0.713 0.215 1.475 0.032 2.229 0.088 0.036 0.177 0.083 0.271 0.088 1.375 0.715 1.885 1.251 1.64 2.052v-0.057c-0.077-0.004-0.161 0-0.239 0h-0.021c0.204-0.624-0.244-1.104-1.421-1.635-1.219-0.531-2.193-0.448-2.36 0.62-0.011 0.057-0.015 0.088-0.020 0.183-0.095 0.031-0.188 0.067-0.281 0.083-0.573 0.36-0.881 0.896-1.057 1.584-0.172 0.713-0.224 1.541-0.271 2.495-0.032 0.448-0.229 1.119-0.428 1.801-2 1.432-4.776 2.052-7.129 0.448-0.152-0.26-0.329-0.5-0.537-0.713-0.099-0.167-0.224-0.312-0.369-0.443 0.244 0 0.453-0.041 0.62-0.089 0.192-0.093 0.344-0.255 0.421-0.447 0.141-0.355 0-0.928-0.464-1.553-0.457-0.619-1.239-1.323-2.38-2.025-0.843-0.531-1.317-1.161-1.536-1.86-0.219-0.713-0.188-1.448-0.021-2.192 0.328-1.427 1.167-2.817 1.704-3.688 0.14-0.083 0.047 0.183-0.547 1.303-0.527 1-1.521 3.328-0.163 5.135 0.053-1.317 0.344-2.619 0.865-3.833 0.749-1.703 2.323-4.671 2.448-7.025 0.063 0.052 0.287 0.183 0.385 0.271 0.287 0.177 0.505 0.443 0.787 0.62 0.281 0.265 0.635 0.448 1.167 0.448 0.052 0.005 0.099 0.005 0.145 0.005 0.547 0 0.975-0.177 1.328-0.355 0.385-0.183 0.699-0.448 0.989-0.536h0.005c0.62-0.177 1.115-0.537 1.391-0.933z"/>
                </svg>
                <h3 class="font-medium mb-1">Linux</h3>
                <p class="text-sm text-slate-500">Ubuntu 18.04+</p>
              </div>
            </RouterLink>

            <RouterLink to="/downloads" class="group">
              <div class="bg-white p-8 rounded-2xl border border-slate-200 hover:border-slate-300 transition-all duration-300">
                <svg class="w-12 h-12 mx-auto mb-4" viewBox="0 0 24 24" fill="none">
                  <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 1 10.25 4.22 4.21c.98-1.71 2.56-2.86 4.28-3.01 1.72-.16 3.38.96 4.54.96s3.27-1.19 5.52-1.02c1 .03 3.57.42 5.22 2.62-.13.1-3.08 1.82-3.04 5.46.05 4.42 3.77 5.93 3.8 5.94-.03.1-.59 2.08-2 4.12zM13 3.5c.07-.88.37-1.64.89-2.32.73-.92 1.84-1.54 2.91-1.54.04 1.24-.54 2.22-1.18 2.96-.69.79-1.73 1.43-2.87 1.35-.1-.95.28-1.77.25-2.45z" fill="#000"/>
                </svg>
                <h3 class="font-medium mb-1">iOS</h3>
                <p class="text-sm text-slate-500">15.0+</p>
              </div>
            </RouterLink>
          </div>

          <p class="text-slate-500">
            Works on iOS, Android, iPadOS, and web. Simple setup in minutes.
          </p>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section class="py-32 section-padding">
      <div class="container-custom">
        <div class="max-w-4xl mx-auto">
          <h2 class="text-4xl font-light mb-4 text-center">Questions?</h2>
          <p class="text-xl text-slate-600 mb-16 text-center">
            We're here to help
          </p>

          <!-- Simplified FAQ Accordion -->
          <div class="space-y-4">
            <div
              v-for="(faq, index) in faqs"
              :key="index"
              class="bg-white p-6 rounded-2xl border border-slate-200 cursor-pointer transition-all hover:border-slate-300"
              @click="toggleFaq(index)"
            >
              <div class="flex items-center justify-between">
                <h3 class="text-lg font-medium text-slate-900">{{ faq.question }}</h3>
                <svg
                  class="w-6 h-6 text-slate-400 transition-transform"
                  :class="{ 'rotate-180': openFaq === index }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                </svg>
              </div>
              <div
                class="px-8 overflow-hidden transition-all duration-300 ease-in-out"
                :class="openFaq === index ? 'max-h-96 pb-6' : 'max-h-0'"
              >
                <p class="text-slate-600">{{ faq.answer }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>