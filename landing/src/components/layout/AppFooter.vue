<template>
  <footer class="border-t border-slate-200/60 bg-slate-50/30">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="flex flex-col md:flex-row items-center justify-between gap-6">
        <!-- Logo and tagline -->
        <div class="flex items-center gap-3">
          <img src="/app-icon.svg" alt="Recogniz.ing" class="w-9 h-9" />
          <span class="text-lg font-semibold text-slate-950">Recogniz.ing</span>
        </div>

        <!-- Links -->
        <nav class="flex items-center gap-6 text-sm">
          <RouterLink to="/" class="text-slate-600 hover:text-slate-950 transition-colors">Home</RouterLink>
          <RouterLink to="/features" class="text-slate-600 hover:text-slate-950 transition-colors">Features</RouterLink>
          <RouterLink to="/downloads" class="text-slate-600 hover:text-slate-950 transition-colors">Download</RouterLink>
        </nav>

        <!-- Tagline -->
        <p class="text-slate-500 text-sm flex items-center gap-2">
          <span>Powered by</span>
          <span class="font-medium text-slate-700">Google Gemini API</span>
        </p>
      </div>
    </div>
  </footer>
</template>