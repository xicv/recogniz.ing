<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const isActive = (path: string) => {
  return route.path === path
}

const navLinks = [
  { path: '/', label: 'Home' },
  { path: '/features', label: 'Features' },
  { path: '/downloads', label: 'Download' }
]
</script>

<template>
  <nav class="fixed top-0 w-full bg-white/80 backdrop-blur-xl z-50 border-b border-slate-100">
    <div class="container-custom px-6 py-4">
      <div class="flex items-center justify-between">
        <RouterLink
          to="/"
          class="flex items-center space-x-3 hover:opacity-80 transition-opacity"
        >
          <svg class="w-8 h-8" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#0EA5E9"/>
                <stop offset="50%" stop-color="#0284C7"/>
                <stop offset="100%" stop-color="#0369A1"/>
              </linearGradient>
              <linearGradient id="innerGlow" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="rgba(255,255,255,0.15)"/>
                <stop offset="100%" stop-color="rgba(0,0,0,0.1)"/>
              </linearGradient>
              <linearGradient id="iconGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#FFFFFF"/>
                <stop offset="100%" stop-color="#E0F2FE"/>
              </linearGradient>
            </defs>
            <rect width="1024" height="1024" rx="224" fill="url(#bgGradient)"/>
            <rect width="1024" height="1024" rx="224" fill="url(#innerGlow)"/>
            <g transform="translate(512, 512)">
              <path d="M -280 -120 A 180 180 0 0 0 -280 120" stroke="url(#iconGradient)" stroke-width="44" fill="none" stroke-linecap="round" opacity="0.5"/>
              <path d="M -200 -80 A 120 120 0 0 0 -200 80" stroke="url(#iconGradient)" stroke-width="44" fill="none" stroke-linecap="round" opacity="0.75"/>
              <path d="M -120 -40 A 60 60 0 0 0 -120 40" stroke="url(#iconGradient)" stroke-width="44" fill="none" stroke-linecap="round"/>
              <circle cx="-40" cy="0" r="32" fill="url(#iconGradient)"/>
              <rect x="40" y="-100" width="240" height="36" rx="18" fill="url(#iconGradient)"/>
              <rect x="40" y="-18" width="200" height="36" rx="18" fill="url(#iconGradient)" opacity="0.85"/>
              <rect x="40" y="64" width="160" height="36" rx="18" fill="url(#iconGradient)" opacity="0.7"/>
            </g>
          </svg>
          <span class="text-2xl font-display font-light tracking-tight text-slate-900">
            Recogniz.ing
          </span>
        </RouterLink>

        <nav class="flex items-center space-x-8">
          <RouterLink
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            class="transition-colors"
            :class="[
              'font-medium',
              isActive(link.path)
                ? 'text-slate-900'
                : 'text-slate-700 hover:text-slate-900'
            ]"
          >
            {{ link.label }}
          </RouterLink>
        </nav>
      </div>
    </div>
  </nav>
</template>