<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const isScrolled = ref(false)

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const isActive = (path: string) => {
  return route.path === path
}

const navLinks = [
  { path: '/', label: 'Home' },
  { path: '/features', label: 'Features' },
  { path: '/downloads', label: 'Download' },
  { path: '/changelog', label: 'Changelog' }
]
</script>

<template>
  <nav
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-300"
    :class="[
      'bg-white/80 backdrop-blur-xl',
      isScrolled ? 'border-b border-slate-200/60 shadow-sm' : 'border-b border-transparent'
    ]"
  >
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <RouterLink
          to="/"
          class="flex items-center gap-3 hover:opacity-80 transition-opacity"
        >
          <img src="/app-icon.svg" alt="Recogniz.ing" class="w-10 h-10" />
          <span class="text-xl font-semibold tracking-tight text-slate-950">
            Recogniz.ing
          </span>
        </RouterLink>

        <!-- Navigation Links -->
        <nav class="flex items-center gap-1">
          <RouterLink
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            class="relative px-4 py-2 text-sm font-medium rounded-lg transition-all duration-200"
            :class="[
              isActive(link.path)
                ? 'text-slate-950 bg-slate-100'
                : 'text-slate-600 hover:text-slate-950 hover:bg-slate-50'
            ]"
          >
            {{ link.label }}
          </RouterLink>
        </nav>

        <!-- CTA Button -->
        <RouterLink
          to="/downloads"
          class="hidden sm:inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold text-white bg-slate-950 hover:bg-slate-900 rounded-full transition-all duration-200 hover:shadow-lg hover:shadow-slate-900/20 hover:-translate-y-0.5"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
          </svg>
          Download
        </RouterLink>
      </div>
    </div>
  </nav>
</template>