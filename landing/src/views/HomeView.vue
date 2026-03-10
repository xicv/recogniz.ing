<script setup lang="ts">
import AppPreview from '@/components/ui/AppPreview.vue'
import { useScrollAnimations } from '@/composables/useScrollAnimations'
import { onMounted, ref } from 'vue'
import { getVersionWithPrefix } from '@/version'
import {
  Download, KeyRound, Check, Zap, Mic, FileText,
  BookOpen, Monitor, Lock, ChevronDown
} from 'lucide-vue-next'

useScrollAnimations()

// Hero animation
const heroVisible = ref(false)
onMounted(() => {
  setTimeout(() => { heroVisible.value = true }, 100)
})

// FAQ state
const openFaq = ref<number | null>(null)
const toggleFaq = (index: number) => {
  openFaq.value = openFaq.value === index ? null : index
}

const features = [
  {
    icon: Zap,
    title: 'Lightning Fast',
    description: 'Instant transcription with auto-copy to clipboard',
    color: 'bg-amber-100 text-amber-600 dark:bg-amber-900/40 dark:text-amber-400'
  },
  {
    icon: Mic,
    title: 'Gemini 3 Flash AI',
    description: 'Accurate, fast transcription with intelligent context understanding',
    color: 'bg-sky-100 text-sky-600 dark:bg-sky-900/40 dark:text-sky-400'
  },
  {
    icon: FileText,
    title: 'Custom Prompts',
    description: 'Templates for any workflow or use case',
    color: 'bg-violet-100 text-violet-600 dark:bg-violet-900/40 dark:text-violet-400'
  },
  {
    icon: BookOpen,
    title: 'Smart Vocabulary',
    description: 'Industry-specific terms and custom dictionaries',
    color: 'bg-emerald-100 text-emerald-600 dark:bg-emerald-900/40 dark:text-emerald-400'
  },
  {
    icon: Monitor,
    title: 'Cross-Platform',
    description: 'Works everywhere — macOS, Windows, Linux, and mobile',
    color: 'bg-rose-100 text-rose-600 dark:bg-rose-900/40 dark:text-rose-400'
  },
  {
    icon: Lock,
    title: 'Private & Secure',
    description: 'All data stored locally on your device',
    color: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400'
  }
]

const steps = [
  { number: '1', title: 'Get API Key', description: 'Free from Google AI Studio', icon: KeyRound },
  { number: '2', title: 'Download App', description: 'Available on all platforms', icon: Download },
  { number: '3', title: 'Start Typing', description: 'Speak and let AI transcribe', icon: Mic }
]

const faqs = [
  {
    question: 'Is the application free to use?',
    answer: 'Yes, Recogniz.ing is completely free and open-source. You only need to provide your own Gemini API key from Google AI Studio. Gemini 3 Flash has a generous free tier that covers daily personal use for most users — no payment required.'
  },
  {
    question: 'What AI model does it use?',
    answer: "Recogniz.ing uses Google Gemini 3 Flash (gemini-3-flash-preview), Google's fastest AI model for transcription. It features auto-retry for transient errors, supports 20+ languages, and offers a free tier that's sufficient for most users."
  },
  {
    question: 'Will I need to pay for the API?',
    answer: "Probably not! Gemini 3 Flash's generous free tier typically covers daily personal voice typing. You can even add multiple API keys and Recogniz.ing will automatically rotate between them when one hits its rate limit. Even if you exceed the free tier, pricing is very affordable (~$0.075 per million characters)."
  },
  {
    question: 'Can I customize vocabulary?',
    answer: 'Yes. Recogniz.ing includes 6 pre-built vocabulary sets (General, Technology, Business, Medical, Legal, Finance) and you can create custom vocabulary lists with industry-specific terms for better accuracy.'
  },
  {
    question: 'Does it record my voice?',
    answer: 'Recogniz.ing uses ML-based Voice Activity Detection (Silero VAD) with ~95% accuracy to automatically detect when you speak and pause. All recordings and transcriptions are stored locally on your device.'
  },
  {
    question: 'Is my data private?',
    answer: 'Yes, privacy-first design. All audio recordings, transcriptions, and settings are stored locally on your device. Audio is only sent to Google\'s API for transcription and is not stored by Google.'
  }
]
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="relative pt-28 pb-20 lg:pt-36 lg:pb-28">
      <div class="container-custom">
        <div class="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          <!-- Left: Content -->
          <div class="text-center lg:text-left">
            <div
              class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-medium mb-6 bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400 transition-opacity duration-500"
              :class="heroVisible ? 'opacity-100' : 'opacity-0'"
            >
              {{ getVersionWithPrefix() }} — Now Available
            </div>

            <h1
              class="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight mb-6 text-slate-950 dark:text-slate-50 transition-all duration-700"
              :class="heroVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'"
              style="line-height: 1.1"
            >
              AI Voice Typing,
              <span class="text-sky-500">Your Way</span>
            </h1>

            <p
              class="text-lg sm:text-xl mb-8 max-w-xl mx-auto lg:mx-0 text-slate-600 dark:text-slate-400 leading-relaxed transition-all duration-700 delay-100"
              :class="heroVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'"
            >
              Your vocabulary, your style, your API key. Privacy-first voice
              typing that adapts to <span class="font-semibold text-slate-900 dark:text-slate-200">you</span>.
            </p>

            <!-- CTA Buttons -->
            <div
              class="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3 mb-8 transition-all duration-700 delay-200"
              :class="heroVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'"
            >
              <RouterLink to="/downloads" class="btn-primary inline-flex items-center gap-2 text-base">
                <Download :size="18" />
                Download
              </RouterLink>
              <a
                href="https://aistudio.google.com/app/apikey"
                target="_blank"
                rel="noopener"
                class="btn-secondary inline-flex items-center gap-2 group"
              >
                <KeyRound :size="18" class="transition-transform group-hover:rotate-12" />
                Get API Key
              </a>
            </div>

            <!-- Trust Badges -->
            <div
              class="flex flex-wrap items-center justify-center lg:justify-start gap-5 text-sm text-slate-500 dark:text-slate-400 transition-all duration-700 delay-300"
              :class="heroVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'"
            >
              <span class="flex items-center gap-1.5">
                <Check :size="16" class="text-emerald-500" />
                No Account Required
              </span>
              <span class="flex items-center gap-1.5">
                <Check :size="16" class="text-emerald-500" />
                Privacy First
              </span>
            </div>
          </div>

          <!-- Right: App Preview -->
          <div
            class="transition-all duration-700 delay-200"
            :class="heroVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'"
          >
            <AppPreview />
          </div>
        </div>
      </div>
    </section>

    <!-- Features Grid -->
    <section class="py-20 lg:py-28">
      <div class="container-custom">
        <div class="max-w-2xl mx-auto text-center mb-14 scroll-reveal">
          <h2 class="text-3xl sm:text-4xl font-bold mb-4 text-slate-950 dark:text-slate-50">
            Everything You Need
          </h2>
          <p class="text-lg text-slate-600 dark:text-slate-400">
            Powerful features for effortless voice typing
          </p>
        </div>

        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5 max-w-5xl mx-auto">
          <div
            v-for="feature in features"
            :key="feature.title"
            class="card scroll-reveal group"
          >
            <div
              class="w-11 h-11 rounded-xl flex items-center justify-center mb-4"
              :class="feature.color"
            >
              <component :is="feature.icon" :size="20" />
            </div>
            <h3 class="text-lg font-semibold mb-1.5 text-slate-950 dark:text-slate-50">
              {{ feature.title }}
            </h3>
            <p class="text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
              {{ feature.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- How It Works -->
    <section class="py-20 lg:py-28 bg-slate-50 dark:bg-slate-900/40">
      <div class="container-custom">
        <div class="max-w-2xl mx-auto text-center mb-14 scroll-reveal">
          <h2 class="text-3xl sm:text-4xl font-bold mb-4 text-slate-950 dark:text-slate-50">
            How It Works
          </h2>
          <p class="text-lg text-slate-600 dark:text-slate-400">
            Three steps to transform your voice into text
          </p>
        </div>

        <div class="max-w-4xl mx-auto">
          <div class="grid md:grid-cols-3 gap-8 relative">
            <!-- Connecting line (desktop) -->
            <div class="hidden md:block absolute top-10 left-[16.6%] right-[16.6%] h-px bg-slate-200 dark:bg-slate-700" />

            <div
              v-for="step in steps"
              :key="step.number"
              class="text-center scroll-reveal relative"
            >
              <div class="w-20 h-20 rounded-full bg-white dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 flex items-center justify-center mx-auto mb-5 relative z-10">
                <component :is="step.icon" :size="28" class="text-sky-500" />
              </div>
              <div class="text-xs font-bold text-sky-500 mb-1.5 uppercase tracking-wider">
                Step {{ step.number }}
              </div>
              <h3 class="text-lg font-semibold mb-1 text-slate-950 dark:text-slate-50">
                {{ step.title }}
              </h3>
              <p class="text-sm text-slate-600 dark:text-slate-400">
                {{ step.description }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- FAQ -->
    <section class="py-20 lg:py-28">
      <div class="container-custom">
        <div class="max-w-3xl mx-auto">
          <div class="text-center mb-12 scroll-reveal">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4 text-slate-950 dark:text-slate-50">
              Questions?
            </h2>
            <p class="text-lg text-slate-600 dark:text-slate-400">
              Common questions about Recogniz.ing
            </p>
          </div>

          <div class="space-y-3">
            <div
              v-for="(faq, index) in faqs"
              :key="index"
              class="faq-item scroll-reveal cursor-pointer"
              @click="toggleFaq(index)"
            >
              <button class="w-full flex items-center justify-between p-5 text-left">
                <span class="text-base font-semibold text-slate-900 dark:text-slate-50 pr-4">
                  {{ faq.question }}
                </span>
                <ChevronDown
                  :size="18"
                  class="text-slate-400 dark:text-slate-500 shrink-0 transition-transform duration-200"
                  :class="{ 'rotate-180': openFaq === index }"
                />
              </button>
              <div
                class="px-5 overflow-hidden transition-all duration-200"
                :class="openFaq === index ? 'max-h-40 pb-5' : 'max-h-0'"
              >
                <p class="text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
                  {{ faq.answer }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@media (max-width: 1024px) {
  .hero-visual {
    order: -1;
  }
}
</style>
