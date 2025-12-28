<script setup lang="ts">
import { ref } from 'vue'
import { useParallax } from '@/composables/useParallax'

const { scrollY, isReducedMotion, getTransform, getScale } = useParallax({
  speed: 0.15
})

const isHovered = ref(false)
</script>

<template>
  <div class="product-mockup-container relative">
    <!-- Glow effect behind mockup -->
    <div
      class="product-mockup-glow absolute inset-0 rounded-2xl opacity-50"
      :class="isReducedMotion ? '' : 'animate-pulse'"
      :style="{
        background: 'radial-gradient(ellipse at center, rgba(14, 165, 233, 0.15) 0%, transparent 70%)'
      }"
    />

    <!-- Main mockup frame -->
    <div
      class="product-mockup-frame relative rounded-2xl border overflow-hidden transition-all duration-500"
      :class="[
        'bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-700 shadow-2xl',
        isHovered ? 'scale-[1.02] shadow-sky-500/20' : ''
      ]"
      @mouseenter="isHovered = true"
      @mouseleave="isHovered = false"
      :style="isReducedMotion ? {} : { transform: getTransform() }"
    >
      <!-- Window controls (macOS style) -->
      <div class="mockup-header flex items-center gap-2 px-4 py-3 border-b border-slate-100 dark:border-slate-800">
        <div class="flex gap-2">
          <div class="w-3 h-3 rounded-full bg-red-400" />
          <div class="w-3 h-3 rounded-full bg-yellow-400" />
          <div class="w-3 h-3 rounded-full bg-green-400" />
        </div>
        <div class="flex-1 text-center">
          <span class="text-xs font-medium text-slate-400">Recogniz.ing</span>
        </div>
      </div>

      <!-- App content preview -->
      <div class="mockup-content p-6 space-y-4 bg-gradient-to-br from-slate-50 to-white dark:from-slate-900 dark:to-slate-800">
        <!-- Recording button animation -->
        <div class="flex items-center justify-center py-8">
          <div
            class="recording-button flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-sky-500 to-cyan-500 shadow-lg transition-all duration-300"
            :class="isHovered ? 'scale-110 shadow-sky-500/40' : 'scale-100'"
          >
            <svg
              class="w-8 h-8 text-white"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              stroke-width="2"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"
              />
            </svg>
          </div>
        </div>

        <!-- Fake transcription cards -->
        <div class="space-y-3">
          <div
            v-for="i in 3"
            :key="i"
            class="transcription-card p-4 rounded-xl border border-slate-100 dark:border-slate-700 bg-white dark:bg-slate-800 transition-all duration-300"
            :class="isHovered ? `opacity-${100 - i * 20}` : ''"
            :style="{ opacity: isHovered ? 1 - (i * 0.15) : 1 }"
          >
            <div class="flex items-start gap-3">
              <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-slate-100 to-slate-200 dark:from-slate-700 dark:to-slate-600 flex-shrink-0" />
              <div class="flex-1 space-y-2">
                <div class="h-3 bg-slate-100 dark:bg-slate-700 rounded w-3/4" />
                <div class="h-3 bg-slate-50 dark:bg-slate-800 rounded w-1/2" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- VAD indicator overlay -->
      <div
        class="vad-overlay absolute inset-0 flex items-end justify-center pb-4 pointer-events-none transition-opacity duration-300"
        :class="isHovered ? 'opacity-100' : 'opacity-0'"
      >
        <div class="flex gap-1 items-end h-8">
          <div
            v-for="i in 8"
            :key="i"
            class="w-1 bg-sky-500 rounded-full transition-all duration-150"
            :style="{
              height: isHovered ? `${Math.random() * 100}%` : '20%',
              animationDelay: `${i * 50}ms`
            }"
            :class="isHovered ? 'animate-pulse' : ''"
          />
        </div>
      </div>
    </div>

    <!-- Floating elements -->
    <div
      class="floating-element absolute -right-4 top-8 p-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700 shadow-lg transition-transform duration-500"
      :style="isReducedMotion ? {} : { transform: getTransform(-0.05) }"
    >
      <div class="flex items-center gap-2">
        <svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
        </svg>
        <span class="text-sm font-medium text-slate-700 dark:text-slate-300">Transcription complete</span>
      </div>
    </div>

    <div
      class="floating-element absolute -left-4 bottom-12 p-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700 shadow-lg transition-transform duration-500"
      :style="isReducedMotion ? {} : { transform: getTransform(-0.08) }"
    >
      <div class="flex items-center gap-2">
        <svg class="w-5 h-5 text-sky-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        <span class="text-sm font-medium text-slate-700 dark:text-slate-300">Gemini 3.0 Flash</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.product-mockup-container {
  @apply relative w-full max-w-2xl mx-auto;
  perspective: 1000px;
}

.product-mockup-frame {
  box-shadow:
    0 25px 50px -12px rgba(0, 0, 0, 0.15),
    0 0 0 1px rgba(0, 0, 0, 0.05);
}

.dark .product-mockup-frame {
  box-shadow:
    0 25px 50px -12px rgba(0, 0, 0, 0.4),
    0 0 0 1px rgba(255, 255, 255, 0.05);
}

.floating-element {
  animation: float 6s ease-in-out infinite;
}

.floating-element:nth-child(3) {
  animation-delay: -2s;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@media (prefers-reduced-motion: reduce) {
  .floating-element {
    animation: none;
  }
}
</style>
