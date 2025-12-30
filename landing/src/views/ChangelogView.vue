<script setup lang="ts">
import { ref, computed } from 'vue'

// @ts-expect-error - JSON import from parent directory
import changelogData from '@root/CHANGELOG.json'

interface Change {
  category: string
  title: string
  description: string
}

interface Version {
  version: string
  date: string
  stable: boolean
  highlights: string[]
  changes: Change[]
}

interface Category {
  label: string
  icon: string
  color: string
}

const changelog = ref(changelogData)
const selectedCategory = ref<string | null>(null)
const searchQuery = ref('')

const categoryIconPaths: Record<string, string> = {
  added: 'M4 12H20M12 4V20',
  changed: 'M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15',
  fixed: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
  removed: 'M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 011-1h2a1 1 0 011 1v3M4 7h16',
  security: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z'
}

const categories = computed(() => changelog.value.categories as Record<string, Category>)

const filteredVersions = computed(() => {
  return changelog.value.versions.filter((version: Version) => {
    if (!searchQuery.value) return true

    const query = searchQuery.value.toLowerCase()
    return (
      version.version.toLowerCase().includes(query) ||
      version.highlights.some(h => h.toLowerCase().includes(query)) ||
      version.changes.some(
        (c: Change) =>
          c.title.toLowerCase().includes(query) ||
          c.description.toLowerCase().includes(query)
      )
    )
  })
})

const filteredVersionsByCategory = computed(() => {
  if (!selectedCategory.value) return filteredVersions.value

  return filteredVersions.value.map((version: Version) => ({
    ...version,
    changes: version.changes.filter((c: Change) => c.category === selectedCategory.value)
  })).filter((version: Version) => version.changes.length > 0)
})

const categoryCounts = computed(() => {
  const counts: Record<string, number> = {}
  filteredVersions.value.forEach((version: Version) => {
    version.changes.forEach((change: Change) => {
      counts[change.category] = (counts[change.category] || 0) + 1
    })
  })
  return counts
})

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const getCategoryInfo = (category: string) => {
  return categories.value[category] || { label: category, icon: 'circle', color: 'bg-slate-500' }
}

const getCategoryIcon = (category: string) => {
  return categoryIconPaths[category] || categoryIconPaths.added
}
</script>

<template>
  <div
    class="min-h-screen pt-24 sm:pt-32 pb-16 lg:pb-24 bg-gradient-to-br from-slate-50 to-white dark:from-slate-900 dark:to-[#0a0a0a] transition-colors duration-300"
  >
    <div class="container-custom max-w-5xl">
      <!-- Header -->
      <div class="text-center mb-16">
        <h1
          class="text-4xl sm:text-5xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
        >
          What's New
        </h1>
        <p
          class="text-xl text-slate-600 dark:text-slate-400 transition-colors duration-300"
        >
          Track the latest features, improvements, and fixes
        </p>
      </div>

      <!-- Search and Filters -->
      <div class="mb-12 space-y-4">
        <!-- Search -->
        <div class="relative max-w-md mx-auto">
          <svg
            class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 dark:text-slate-500 transition-colors duration-300"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search changelog..."
            class="w-full pl-12 pr-4 py-3 rounded-full border focus:outline-none focus:ring-2 transition-all bg-white dark:bg-slate-800 dark:border-slate-700 border-slate-200 text-slate-900 dark:text-slate-50 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:border-slate-400 dark:focus:border-slate-600 focus:ring-slate-100 dark:focus:ring-slate-700"
          />
        </div>

        <!-- Category Filter -->
        <div class="flex flex-wrap justify-center gap-2">
          <button
            @click="selectedCategory = selectedCategory === null ? null : null"
            class="px-4 py-2 rounded-full text-sm font-medium transition-all"
            :class="[
              selectedCategory === null
                ? 'bg-slate-900 text-white dark:bg-slate-700'
                : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:hover:bg-slate-700 dark:border-slate-700'
            ]"
          >
            All Changes
          </button>
          <button
            v-for="(cat, categoryId) in categories"
            :key="categoryId"
            @click="selectedCategory = selectedCategory === categoryId ? null : categoryId"
            class="px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2"
            :class="[
              selectedCategory === categoryId
                ? `${cat.color} text-white`
                : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:hover:bg-slate-700 dark:border-slate-700'
            ]"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M4 12H20M12 4V20"/>
            </svg>
            {{ cat.label }}
            <span
              v-if="categoryCounts[categoryId]"
              class="ml-1 px-2 py-0.5 rounded-full text-xs"
              :class="selectedCategory === categoryId ? 'bg-white/20' : 'bg-slate-200 dark:bg-slate-700'"
            >
              {{ categoryCounts[categoryId] }}
            </span>
          </button>
        </div>
      </div>

      <!-- Versions List -->
      <div class="space-y-12">
        <article
          v-for="version in filteredVersionsByCategory"
          :key="version.version"
          class="relative"
        >
          <!-- Version Header -->
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
            <div class="flex items-center gap-4">
              <div class="flex items-baseline gap-2">
                <h2
                  class="text-3xl font-semibold text-slate-900 dark:text-slate-50 transition-colors duration-300"
                >
                  v{{ version.version }}
                </h2>
                <span
                  v-if="version.stable"
                  class="px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-400 transition-colors duration-300"
                >
                  Stable
                </span>
              </div>
            </div>
            <time
              class="text-sm text-slate-500 transition-colors duration-300"
            >
              {{ formatDate(version.date) }}
            </time>
          </div>

          <!-- Highlights -->
          <div
            v-if="version.highlights && version.highlights.length"
            class="mb-6 p-4 rounded-xl border bg-gradient-to-br from-slate-50 to-slate-100/50 dark:bg-slate-800/50 dark:border-slate-700 border-slate-200 transition-colors duration-300"
          >
            <h3
              class="text-sm font-semibold mb-3 text-slate-700 dark:text-slate-300 transition-colors duration-300"
            >
              Highlights
            </h3>
            <ul class="space-y-2">
              <li
                v-for="highlight in version.highlights"
                :key="highlight"
                class="flex items-start gap-3 text-sm text-slate-600 dark:text-slate-400 transition-colors duration-300"
              >
                <svg class="w-5 h-5 text-sky-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                </svg>
                {{ highlight }}
              </li>
            </ul>
          </div>

          <!-- Changes -->
          <div class="space-y-3">
            <div
              v-for="(change, idx) in version.changes"
              :key="idx"
              class="group flex gap-4 p-4 rounded-xl border bg-white dark:bg-slate-800 dark:border-slate-700 border-slate-100 hover:border-slate-200 dark:hover:border-slate-600 hover:shadow-sm transition-all"
            >
              <!-- Category Icon -->
              <div
                class="flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center"
                :class="getCategoryInfo(change.category).color"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" :d="getCategoryIcon(change.category)"/>
                </svg>
              </div>

              <!-- Change Content -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-1">
                  <span
                    class="px-2 py-0.5 rounded text-xs font-medium"
                    :class="getCategoryInfo(change.category).color + ' text-white'"
                  >
                    {{ getCategoryInfo(change.category).label }}
                  </span>
                  <h3
                    class="font-semibold text-slate-900 dark:text-slate-50 transition-colors duration-300"
                  >
                    {{ change.title }}
                  </h3>
                </div>
                <p
                  class="text-sm leading-relaxed text-slate-600 dark:text-slate-400 transition-colors duration-300"
                >
                  {{ change.description }}
                </p>
              </div>
            </div>
          </div>
        </article>
      </div>

      <!-- Empty State -->
      <div v-if="filteredVersionsByCategory.length === 0" class="text-center py-16">
        <svg
          class="w-16 h-16 mx-auto mb-4 text-slate-300 dark:text-slate-700 transition-colors duration-300"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          stroke-width="1.5"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <p
          class="text-slate-500 transition-colors duration-300"
        >
          No changes found matching your search.
        </p>
      </div>

      <!-- Footer Link -->
      <div class="mt-16 text-center">
        <a
          :href="changelog.title ? `https://github.com/xicv/recogniz.ing/blob/main/CHANGELOG.md` : '#'"
          target="_blank"
          rel="noopener"
          class="inline-flex items-center gap-2 text-slate-500 hover:text-slate-700 dark:hover:text-slate-300 transition-colors duration-300"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
          </svg>
          View on GitHub
        </a>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* No custom styles needed - using Tailwind utility classes */
</style>
