<template>
  <footer class="py-16 border-t border-slate-100">
    <div class="container-custom">
      <div class="flex flex-col md:flex-row items-center justify-between">
        <div class="flex items-center space-x-3 mb-6 md:mb-0">
          <svg class="w-7 h-7" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <linearGradient id="bgGradientFooter" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#0EA5E9"/>
                <stop offset="50%" stop-color="#0284C7"/>
                <stop offset="100%" stop-color="#0369A1"/>
              </linearGradient>
              <linearGradient id="innerGlowFooter" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="rgba(255,255,255,0.15)"/>
                <stop offset="100%" stop-color="rgba(0,0,0,0.1)"/>
              </linearGradient>
              <linearGradient id="iconGradientFooter" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#FFFFFF"/>
                <stop offset="100%" stop-color="#E0F2FE"/>
              </linearGradient>
            </defs>
            <rect width="1024" height="1024" rx="224" fill="url(#bgGradientFooter)"/>
            <rect width="1024" height="1024" rx="224" fill="url(#innerGlowFooter)"/>
            <g transform="translate(512, 512)">
              <path d="M -280 -120 A 180 180 0 0 0 -280 120" stroke="url(#iconGradientFooter)" stroke-width="44" fill="none" stroke-linecap="round" opacity="0.5"/>
              <path d="M -200 -80 A 120 120 0 0 0 -200 80" stroke="url(#iconGradientFooter)" stroke-width="44" fill="none" stroke-linecap="round" opacity="0.75"/>
              <path d="M -120 -40 A 60 60 0 0 0 -120 40" stroke="url(#iconGradientFooter)" stroke-width="44" fill="none" stroke-linecap="round"/>
              <circle cx="-40" cy="0" r="32" fill="url(#iconGradientFooter)"/>
              <rect x="40" y="-100" width="240" height="36" rx="18" fill="url(#iconGradientFooter)"/>
              <rect x="40" y="-18" width="200" height="36" rx="18" fill="url(#iconGradientFooter)" opacity="0.85"/>
              <rect x="40" y="64" width="160" height="36" rx="18" fill="url(#iconGradientFooter)" opacity="0.7"/>
            </g>
          </svg>
          <span class="text-xl font-display font-light tracking-tight text-slate-900">Recogniz.ing</span>
        </div>
        <p class="text-slate-500 text-sm">
          Powered by Google Gemini API
        </p>
      </div>
    </div>
  </footer>
</template>