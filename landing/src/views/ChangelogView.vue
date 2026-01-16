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
    month: 'short',
    day: 'numeric'
  })
}

const getCategoryInfo = (category: string) => {
  return categories.value[category] || { label: category, icon: 'circle', color: 'bg-slate-500' }
}

// Group changes by category for display
const groupChangesByCategory = (changes: Change[]) => {
  const grouped: Record<string, Change[]> = {}
  changes.forEach(change => {
    if (!grouped[change.category]) {
      grouped[change.category] = []
    }
    grouped[change.category].push(change)
  })
  return grouped
}
</script>

<template>
  <div
    class="min-h-screen pt-24 sm:pt-32 pb-16 lg:pb-24 bg-gradient-to-br from-slate-50 to-white dark:from-slate-900 dark:to-[#0a0a0a] transition-colors duration-300"
  >
    <div class="container-custom max-w-4xl">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1
          class="text-4xl sm:text-5xl font-semibold mb-4 text-slate-950 dark:text-slate-50 transition-colors duration-300"
        >
          What's New
        </h1>
        <p
          class="text-lg text-slate-600 dark:text-slate-400 transition-colors duration-300"
        >
          Track the latest features, improvements, and fixes
        </p>
      </div>

      <!-- Search and Filters -->
      <div class="mb-10 space-y-4">
        <!-- Search -->
        <div class="relative max-w-md mx-auto">
          <svg
            class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 dark:text-slate-500 transition-colors duration-300"
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
            class="w-full pl-10 pr-4 py-2.5 rounded-lg border focus:outline-none focus:ring-2 transition-all bg-white dark:bg-slate-800 dark:border-slate-700 border-slate-200 text-slate-900 dark:text-slate-50 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:border-slate-400 dark:focus:border-slate-600 focus:ring-slate-100 dark:focus:ring-slate-700 text-sm"
          />
        </div>

        <!-- Category Filter -->
        <div class="flex flex-wrap justify-center gap-1.5">
          <button
            @click="selectedCategory = selectedCategory === null ? null : null"
            class="px-3 py-1.5 rounded-md text-xs font-medium transition-all"
            :class="[
              selectedCategory === null
                ? 'bg-slate-900 text-white dark:bg-slate-700'
                : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:hover:bg-slate-700 dark:border-slate-700'
            ]"
          >
            All
          </button>
          <button
            v-for="(cat, categoryId) in categories"
            :key="categoryId"
            @click="selectedCategory = selectedCategory === categoryId ? null : categoryId"
            class="px-3 py-1.5 rounded-md text-xs font-medium transition-all flex items-center gap-1.5"
            :class="[
              selectedCategory === categoryId
                ? `${cat.color} text-white`
                : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:hover:bg-slate-700 dark:border-slate-700'
            ]"
          >
            {{ cat.label }}
            <span
              v-if="categoryCounts[categoryId]"
              class="px-1.5 py-0.5 rounded text-[10px]"
              :class="selectedCategory === categoryId ? 'bg-white/20' : 'bg-slate-200 dark:bg-slate-700'"
            >
              {{ categoryCounts[categoryId] }}
            </span>
          </button>
        </div>
      </div>

      <!-- Versions List -->
      <div class="space-y-8">
        <article
          v-for="version in filteredVersionsByCategory"
          :key="version.version"
          class="relative pl-6"
        >
          <!-- Timeline indicator -->
          <div class="absolute left-0 top-0 bottom-0 w-px bg-slate-200 dark:bg-slate-700"></div>
          <div class="absolute left-[-3px] top-2 w-1.5 h-1.5 rounded-full bg-slate-400 dark:bg-slate-600"></div>

          <!-- Version Header -->
          <div class="flex flex-wrap items-center gap-3 mb-4">
            <h2
              class="text-xl font-semibold text-slate-900 dark:text-slate-50 transition-colors duration-300"
            >
              v{{ version.version }}
            </h2>
            <span
              v-if="version.stable"
              class="px-2 py-0.5 rounded text-[10px] font-medium bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-400 transition-colors duration-300"
            >
              Stable
            </span>
            <time
              class="text-xs text-slate-500 transition-colors duration-300"
            >
              {{ formatDate(version.date) }}
            </time>
          </div>

          <!-- Highlights -->
          <div
            v-if="version.highlights && version.highlights.length"
            class="mb-4 pl-4"
          >
            <ul class="space-y-1.5">
              <li
                v-for="highlight in version.highlights"
                :key="highlight"
                class="text-sm text-slate-600 dark:text-slate-400 transition-colors duration-300 flex items-start gap-2"
              >
                <span class="text-sky-500 mt-0.5">•</span>
                {{ highlight }}
              </li>
            </ul>
          </div>

          <!-- Changes Grouped by Category -->
          <div class="space-y-3">
            <template
              v-for="(changesList, category) in groupChangesByCategory(version.changes)"
              :key="category"
            >
              <div>
                <h3
                  class="inline-block px-2 py-0.5 rounded text-[10px] font-medium mb-2"
                  :class="getCategoryInfo(category).color + ' text-white'"
                >
                  {{ getCategoryInfo(category).label }}
                </h3>
                <ul class="space-y-1 pl-4">
                  <li
                    v-for="(change, idx) in changesList"
                    :key="idx"
                    class="text-sm text-slate-600 dark:text-slate-400 transition-colors duration-300"
                  >
                    <span class="font-medium text-slate-900 dark:text-slate-200">{{ change.title }}</span>
                    <span v-if="change.description"> - {{ change.description }}</span>
                  </li>
                </ul>
              </div>
            </template>
          </div>
        </article>
      </div>

      <!-- Empty State -->
      <div v-if="filteredVersionsByCategory.length === 0" class="text-center py-16">
        <svg
          class="w-12 h-12 mx-auto mb-4 text-slate-300 dark:text-slate-700 transition-colors duration-300"
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
      <div class="mt-12 text-center">
        <a
          :href="changelog.title ? `https://github.com/xicv/recogniz.ing/blob/main/CHANGELOG.md` : '#' "
          target="_blank"
          rel="noopener"
          class="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-700 dark:hover:text-slate-300 transition-colors duration-300"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
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
