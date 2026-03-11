<script setup lang="ts">
import { Mic, Check } from 'lucide-vue-next'
</script>

<template>
  <div class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-xl overflow-hidden">
    <!-- macOS Window Chrome -->
    <div class="flex items-center gap-2 px-4 py-3 border-b border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-900">
      <div class="w-3 h-3 rounded-full bg-red-400" />
      <div class="w-3 h-3 rounded-full bg-yellow-400" />
      <div class="w-3 h-3 rounded-full bg-green-400" />
      <span class="ml-2 text-xs text-slate-400 dark:text-slate-500 font-medium">Recogniz.ing</span>
    </div>

    <!-- App Content Preview -->
    <div class="p-6 space-y-4">
      <!-- Recording Button -->
      <div class="flex items-center justify-center">
        <div class="w-16 h-16 rounded-full bg-teal-500 flex items-center justify-center shadow-lg">
          <Mic :size="28" class="text-white" />
        </div>
      </div>

      <!-- Fake Transcription Cards -->
      <div class="space-y-3">
        <div class="flex items-start gap-3 p-3 rounded-lg bg-slate-50 dark:bg-slate-800">
          <Check :size="16" class="text-emerald-500 mt-0.5 shrink-0" />
          <p class="text-sm text-slate-600 dark:text-slate-400">AI voice typing that adapts to your vocabulary...</p>
        </div>
        <div class="flex items-start gap-3 p-3 rounded-lg bg-slate-50 dark:bg-slate-800">
          <Check :size="16" class="text-emerald-500 mt-0.5 shrink-0" />
          <p class="text-sm text-slate-600 dark:text-slate-400">Custom prompts for any workflow</p>
        </div>
      </div>
    </div>
  </div>
</template>
