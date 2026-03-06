<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useDarkMode } from '@/composables/useDarkMode'
import { Moon, Sun, Download, Menu, X } from 'lucide-vue-next'

const route = useRoute()
const { toggle: toggleDarkMode, isDark } = useDarkMode()

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

const isActive = (path: string) => route.path === path

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
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-200 bg-white/90 dark:bg-gray-950/90 backdrop-blur-sm"
    :class="isScrolled ? 'border-b border-slate-200 dark:border-slate-800 shadow-sm' : ''"
  >
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <RouterLink to="/" class="flex items-center gap-3 group">
          <img src="/app-icon.svg" alt="Recogniz.ing" class="w-9 h-9" />
          <span class="text-lg font-semibold tracking-tight text-slate-950 dark:text-slate-50">
            Recogniz.ing
          </span>
        </RouterLink>

        <!-- Desktop Nav -->
        <nav class="hidden md:flex items-center gap-1">
          <RouterLink
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            class="relative px-4 py-2 text-sm font-medium rounded-lg transition-colors duration-200 text-slate-600 hover:text-slate-950 dark:text-slate-400 dark:hover:text-slate-50"
            :class="{ 'text-slate-950 dark:text-slate-50': isActive(link.path) }"
          >
            {{ link.label }}
            <span
              v-if="isActive(link.path)"
              class="absolute bottom-0 left-1/2 -translate-x-1/2 w-6 h-0.5 bg-sky-500 rounded-full"
            />
          </RouterLink>
        </nav>

        <!-- Desktop Actions -->
        <div class="hidden md:flex items-center gap-3">
          <button
            @click="toggleDarkMode"
            class="p-2.5 rounded-lg text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 transition-colors"
            aria-label="Toggle dark mode"
          >
            <Moon v-if="!isDark" :size="18" />
            <Sun v-else :size="18" />
          </button>

          <RouterLink
            to="/downloads"
            class="btn-primary inline-flex items-center gap-2 px-5 py-2.5 text-sm"
          >
            <Download :size="16" />
            Download
          </RouterLink>
        </div>

        <!-- Mobile Actions -->
        <div class="flex md:hidden items-center gap-2">
          <button
            @click="toggleDarkMode"
            class="p-2.5 rounded-lg text-slate-500 dark:text-slate-400 transition-colors"
            aria-label="Toggle dark mode"
          >
            <Moon v-if="!isDark" :size="18" />
            <Sun v-else :size="18" />
          </button>

          <button
            @click="isMobileMenuOpen = !isMobileMenuOpen"
            class="p-2.5 rounded-lg text-slate-500 dark:text-slate-400"
            aria-label="Toggle menu"
          >
            <Menu v-if="!isMobileMenuOpen" :size="20" />
            <X v-else :size="20" />
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile Menu -->
    <transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div
        v-if="isMobileMenuOpen"
        class="md:hidden border-t border-slate-200 dark:border-slate-800 bg-white dark:bg-gray-950"
      >
        <div class="px-4 py-3 space-y-1">
          <RouterLink
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            @click="closeMobileMenu"
            class="block px-4 py-3 rounded-lg text-base font-medium text-slate-600 hover:text-slate-950 hover:bg-slate-50 dark:text-slate-400 dark:hover:text-slate-50 dark:hover:bg-slate-800"
            :class="{ 'text-slate-950 bg-slate-50 dark:text-slate-50 dark:bg-slate-800': isActive(link.path) }"
          >
            {{ link.label }}
          </RouterLink>

          <RouterLink
            to="/downloads"
            @click="closeMobileMenu"
            class="btn-primary flex items-center justify-center gap-2 w-full mt-3 text-sm"
          >
            <Download :size="16" />
            Download
          </RouterLink>
        </div>
      </div>
    </transition>
  </nav>
</template>
