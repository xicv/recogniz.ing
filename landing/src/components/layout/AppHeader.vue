<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useDarkMode } from '@/composables/useDarkMode'

const router = useRouter()
const route = useRoute()
const { toggle: toggleDarkMode } = useDarkMode()

// Simple toggle function for debugging
const handleDarkModeToggle = () => {
  const html = document.documentElement
  if (html.classList.contains('dark')) {
    html.classList.remove('dark')
    localStorage.setItem('theme', 'light')
  } else {
    html.classList.add('dark')
    localStorage.setItem('theme', 'dark')
  }
}

// Initialize dark mode on mount
onMounted(() => {
  const stored = localStorage.getItem('theme')
  const html = document.documentElement
  if (stored === 'dark' || (!stored && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    html.classList.add('dark')
  } else {
    html.classList.remove('dark')
  }
})

const isScrolled = ref(false)
const isMobileMenuOpen = ref(false)

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

const closeMobileMenu = () => {
  isMobileMenuOpen.value = false
}
</script>

<template>
  <nav
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-300"
    :class="[
      'glass-card',
      isScrolled ? 'border-b shadow-lg backdrop-blur-xl' : 'border-b-0 backdrop-blur-md'
    ]"
  >
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo - Enhanced with subtle hover effect -->
        <RouterLink
          to="/"
          class="flex items-center gap-3 group"
        >
          <div class="relative">
            <img src="/app-icon.svg" alt="Recogniz.ing" class="w-10 h-10 transition-transform group-hover:scale-110" />
            <div class="absolute inset-0 rounded-lg bg-sky-500/20 opacity-0 group-hover:opacity-100 transition-opacity blur-xl" />
          </div>
          <span class="text-xl font-semibold tracking-tight text-slate-950 dark:text-slate-50 group-hover:text-sky-600 dark:group-hover:text-sky-400 transition-colors">
            Recogniz.ing
          </span>
        </RouterLink>

        <!-- Desktop Navigation Links - Enhanced with better active states -->
        <nav class="hidden md:flex items-center gap-1">
          <RouterLink
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            class="relative px-4 py-2 text-sm font-medium rounded-xl transition-all duration-200 text-slate-600 hover:text-slate-950 hover:bg-slate-100/80 dark:text-slate-400 dark:hover:text-slate-50 dark:hover:bg-slate-800/80 group"
            :class="{ 'text-slate-950 bg-slate-100 dark:text-slate-50 dark:bg-slate-800': isActive(link.path) }"
          >
            {{ link.label }}
            <!-- Active indicator -->
            <span
              v-if="isActive(link.path)"
              class="absolute bottom-0 left-1/2 -translate-x-1/2 w-8 h-0.5 bg-sky-500 rounded-full"
            />
            <!-- Hover indicator -->
            <span
              v-else
              class="absolute bottom-0 left-1/2 -translate-x-1/2 w-0 h-0.5 bg-sky-500 rounded-full group-hover:w-8 transition-all duration-200"
            />
          </RouterLink>
        </nav>

        <!-- Desktop Right Side Actions - Enhanced -->
        <div class="hidden md:flex items-center gap-3">
          <!-- Dark Mode Toggle - Better hover effect -->
          <button
            @click="handleDarkModeToggle"
            class="btn-icon group"
            aria-label="Toggle dark mode"
          >
            <svg class="w-5 h-5 block dark:hidden text-slate-600 group-hover:text-slate-900 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
            <svg class="w-5 h-5 hidden dark:block text-slate-400 group-hover:text-sky-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          </button>

          <!-- CTA Button - Enhanced with glow -->
          <RouterLink
            to="/downloads"
            class="btn-primary inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold text-white rounded-full transition-all duration-200 hover:shadow-xl hover:-translate-y-0.5 bg-slate-950 hover:bg-slate-900 dark:bg-sky-500 dark:hover:bg-sky-400 group"
          >
            <svg class="w-4 h-4 transition-transform group-hover:translate-y-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
            </svg>
            Download
          </RouterLink>
        </div>

        <!-- Mobile Menu Button - Enhanced -->
        <div class="flex md:hidden items-center gap-2">
          <!-- Dark Mode Toggle (Mobile) -->
          <button
            @click="handleDarkModeToggle"
            class="btn-icon"
            aria-label="Toggle dark mode"
          >
            <svg class="w-5 h-5 block dark:hidden text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
            <svg class="w-5 h-5 hidden dark:block text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          </button>

          <!-- Hamburger Button - Enhanced with rotation -->
          <button
            @click="isMobileMenuOpen = !isMobileMenuOpen"
            class="btn-icon relative w-10 h-10 flex items-center justify-center"
            aria-label="Toggle menu"
          >
            <svg
              v-if="!isMobileMenuOpen"
              class="w-6 h-6 text-slate-600 dark:text-slate-400 transition-transform"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
            <svg
              v-else
              class="w-6 h-6 text-slate-600 dark:text-slate-400 transition-transform rotate-90"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile Menu Dropdown - Enhanced with glassmorphism -->
    <transition
      enter-active-class="transition-all duration-300 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div
        v-if="isMobileMenuOpen"
        class="md:hidden border-t glass-card border-slate-200 dark:border-slate-800 mt-1 mx-4 rounded-2xl overflow-hidden"
      >
        <div class="px-4 py-4 space-y-2">
          <RouterLink
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            @click="closeMobileMenu"
            class="block px-4 py-3 rounded-xl text-base font-medium transition-all duration-200 text-slate-600 hover:text-slate-950 hover:bg-slate-100/80 dark:text-slate-400 dark:hover:text-slate-50 dark:hover:bg-slate-800/80"
            :class="{ 'text-slate-950 bg-slate-100 dark:text-slate-50 dark:bg-slate-800': isActive(link.path) }"
          >
            {{ link.label }}
          </RouterLink>

          <!-- Mobile CTA - Enhanced -->
          <RouterLink
            to="/downloads"
            @click="closeMobileMenu"
            class="btn-primary flex items-center justify-center gap-2 w-full px-4 py-3 text-base font-semibold text-white rounded-full transition-all duration-200 mt-4 bg-slate-950 hover:bg-slate-900 dark:bg-sky-500 dark:hover:bg-sky-400"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
            </svg>
            Download
          </RouterLink>
        </div>
      </div>
    </transition>
  </nav>
</template>