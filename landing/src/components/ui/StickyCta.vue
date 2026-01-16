<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

defineProps<{
  href?: string
  label?: string
}>()

const isVisible = ref(false)
const scrollThreshold = 400

const handleScroll = () => {
  isVisible.value = window.scrollY > scrollThreshold
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<template>
  <transition
    enter-active-class="transition-all duration-300 ease-out"
    enter-from-class="translate-y-full opacity-0"
    enter-to-class="translate-y-0 opacity-100"
    leave-active-class="transition-all duration-300 ease-in"
    leave-from-class="translate-y-0 opacity-100"
    leave-to-class="translate-y-full opacity-0"
  >
    <div
      v-if="isVisible"
      class="sticky-cta fixed bottom-0 left-0 right-0 z-40 p-4 border-t shadow-lg backdrop-blur-xl bg-white/90 dark:bg-slate-900/90 dark:border-slate-800"
    >
      <div class="max-w-7xl mx-auto flex items-center justify-between">
        <div class="hidden sm:block">
          <p class="text-sm font-medium text-slate-700 dark:text-slate-300">
            Ready to get started?
          </p>
          <p class="text-xs text-slate-500 dark:text-slate-400">
            Free forever, no subscription required
          </p>
        </div>

        <RouterLink
          :to="href || '/downloads'"
          class="flex-1 sm:flex-none inline-flex items-center justify-center gap-2 px-6 py-3 rounded-full text-base font-semibold text-white bg-slate-950 hover:bg-slate-900 dark:bg-sky-500 dark:hover:bg-sky-400 transition-all duration-300 hover:shadow-lg min-h-[44px]"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
          </svg>
          {{ label || 'Download Free' }}
        </RouterLink>
      </div>
    </div>
  </transition>
</template>

<style scoped>
.sticky-cta {
  padding-bottom: max(4px, env(safe-area-inset-bottom));
}

@media (max-width: 640px) {
  .sticky-cta {
    padding: 12px 16px;
    padding-bottom: calc(12px + max(4px, env(safe-area-inset-bottom)));
  }
}
</style>
