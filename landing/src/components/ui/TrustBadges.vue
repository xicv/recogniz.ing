<script setup lang="ts">
import { ref } from 'vue'

interface TrustBadge {
  name: string
  icon: string
  color: string
  link?: string
}

const badges = ref<TrustBadge[]>([
  {
    name: 'Powered by Google Gemini',
    icon: 'M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5',
    color: 'text-slate-600 dark:text-slate-400',
    link: 'https://aistudio.google.com'
  },
  {
    name: 'Open Source',
    icon: 'M12 2C6.477 2 2 6.477 2 12c0 4.42 2.87 8.17 6.84 9.5.5.08.66-.17.66-.45v-1.69c-2.77.6-3.36-1.34-3.36-1.34-.46-1.16-1.11-1.47-1.11-1.47-.91-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.87 1.52 2.34 1.07 2.91.83.09-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.92 0-1.11.38-2 1.03-2.71-.1-.25-.45-1.29.1-2.64 0 0 .84-.27 2.75 1.02a9.68 9.68 0 015 0c1.91-1.29 2.75-1.02 2.75-1.02.55 1.35.2 2.39.1 2.64.65.71 1.03 1.6 1.03 2.71 0 3.82-2.34 4.66-4.57 4.91.36.31.69.92.69 1.85V21c0 .27.16.54.67.45C19.14 20.17 22 16.42 22 12A10 10 0 0012 2z',
    color: 'text-slate-600 dark:text-slate-400',
    link: 'https://github.com/xicv/recogniz.ing'
  },
  {
    name: 'Built with Flutter',
    icon: 'M4.5 12c0-1.82.59-3.5 1.59-4.88L4.5 5.53c-.94.94-1.5 2.2-1.5 3.47 0 1.28.56 2.54 1.5 3.48l1.59-1.59C5.09 10.5 4.5 8.82 4.5 12zm15-1.59L19.5 12l-1.59-1.59c-.94.94-1.5 2.2-1.5 3.47 0 1.28.56 2.54 1.5 3.48l1.59-1.59c-.94-.94-1.5-2.2-1.5-3.47 0-1.28.56-2.54 1.5-3.48zM7.41 7.41L9 9l1.59-1.59L9 5.82 7.41 7.41zm9.18 9.18L15 15l-1.59 1.59L15 18.18l1.59-1.59z',
    color: 'text-sky-500',
    link: 'https://flutter.dev'
  },
  {
    name: 'Privacy First',
    icon: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z',
    color: 'text-emerald-500'
  }
])

const hoveredIndex = ref<number | null>(null)
</script>

<template>
  <div class="trust-badges">
    <p class="trust-badges-label text-sm text-slate-500 dark:text-slate-400 mb-4">
      Trusted by developers worldwide
    </p>
    <div class="trust-badges-list flex flex-wrap items-center justify-center gap-6 md:gap-8">
      <a
        v-for="(badge, index) in badges"
        :key="badge.name"
        v-tooltip="badge.name"
        :href="badge.link"
        target="_blank"
        rel="noopener"
        class="trust-badge group flex items-center gap-2 px-4 py-2 rounded-full transition-all duration-300 hover:bg-slate-100 dark:hover:bg-slate-800"
        :class="badge.color"
        @mouseenter="hoveredIndex = index"
        @mouseleave="hoveredIndex = null"
      >
        <svg
          class="w-5 h-5 transition-transform duration-300"
          :class="{ 'scale-110': hoveredIndex === index }"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.5"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            :d="badge.icon"
          />
        </svg>
        <span class="text-sm font-medium opacity-0 group-hover:opacity-100 transition-opacity duration-300 max-w-0 overflow-hidden group-hover:max-w-xs whitespace-nowrap">
          {{ badge.name }}
        </span>
      </a>
    </div>
  </div>
</template>

<style scoped>
.trust-badges {
  @apply flex flex-col items-center;
}

.trust-badge {
  cursor: pointer;
}

@media (max-width: 640px) {
  .trust-badges-list {
    @apply gap-4;
  }

  .trust-badge span {
    display: none;
  }
}
</style>
