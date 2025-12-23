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
  added: 'M12 4v16m8-8H4m8 0l-6 6m6-6v-6m-6 6h12', // plus-circle
  changed: 'M21 12a9 9 0 01-9 9m9 9a9 9 0 01-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c0 .75-.21 1.467-.58 2m0 0c.75-.21 1.467-.58 2', // refresh-cw
  fixed: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z', // bug
  removed: 'M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 011-1h2a1 1 0 011 1v3M4 7h16', // trash-2
  security: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z' // shield
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
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-white py-16 section-padding">
    <div class="container-custom max-w-5xl">
      <!-- Header -->
      <div class="text-center mb-16">
        <h1 class="text-4xl sm:text-5xl font-semibold mb-4">
          What's New
        </h1>
        <p class="text-xl text-slate-600">
          Track the latest features, improvements, and fixes
        </p>
      </div>

      <!-- Search and Filters -->
      <div class="mb-12 space-y-4">
        <!-- Search -->
        <div class="relative max-w-md mx-auto">
          <svg class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search changelog..."
            class="w-full pl-12 pr-4 py-3 rounded-full border border-slate-200 focus:border-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-100 transition-all"
          />
        </div>

        <!-- Category Filter -->
        <div class="flex flex-wrap justify-center gap-2">
          <button
            @click="selectedCategory = selectedCategory === null ? null : null"
            :class="selectedCategory === null ? 'bg-slate-900 text-white' : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'"
            class="px-4 py-2 rounded-full text-sm font-medium transition-all"
          >
            All Changes
          </button>
          <button
            v-for="(cat, key) in categories"
            :key="key"
            @click="selectedCategory = selectedCategory === key ? null : key"
            :class="selectedCategory === key ? `${cat.color} text-white` : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'"
            class="px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
            </svg>
            {{ cat.label }}
            <span v-if="categoryCounts[key]" class="ml-1 px-2 py-0.5 rounded-full text-xs" :class="selectedCategory === key ? 'bg-white/20' : 'bg-slate-200'">
              {{ categoryCounts[key] }}
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
                <h2 class="text-3xl font-semibold text-slate-900">
                  v{{ version.version }}
                </h2>
                <span
                  v-if="version.stable"
                  class="px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700"
                >
                  Stable
                </span>
              </div>
            </div>
            <time class="text-sm text-slate-500">
              {{ formatDate(version.date) }}
            </time>
          </div>

          <!-- Highlights -->
          <div v-if="version.highlights && version.highlights.length" class="mb-6 p-4 rounded-xl bg-gradient-to-br from-slate-50 to-slate-100/50 border border-slate-200">
              <h3 class="text-sm font-semibold text-slate-700 mb-3">Highlights</h3>
              <ul class="space-y-2">
                <li v-for="highlight in version.highlights" :key="highlight" class="flex items-start gap-3 text-sm text-slate-600">
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
              class="group flex gap-4 p-4 rounded-xl bg-white border border-slate-100 hover:border-slate-200 hover:shadow-sm transition-all"
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
                  <h3 class="font-semibold text-slate-900">
                    {{ change.title }}
                  </h3>
                </div>
                <p class="text-slate-600 text-sm leading-relaxed">
                  {{ change.description }}
                </p>
              </div>
            </div>
          </div>
        </article>
      </div>

      <!-- Empty State -->
      <div v-if="filteredVersionsByCategory.length === 0" class="text-center py-16">
        <svg class="w-16 h-16 mx-auto text-slate-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <p class="text-slate-500">No changes found matching your search.</p>
      </div>

      <!-- Footer Link -->
      <div class="mt-16 text-center">
        <a
          :href="changelog.title ? `https://github.com/xicv/recogniz.ing/blob/main/CHANGELOG.md` : '#'"
          target="_blank"
          rel="noopener"
          class="inline-flex items-center gap-2 text-slate-500 hover:text-slate-700 transition-colors"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82.258 1.094.258.904 0 1.475-.561 1.705-1.074l1.847-.902c.811-.396 1.273-1.102 1.273-1.696 0-.526-.218-1.059-.537-1.595-.346-.805-.725-1.585-1.138-2.344-3.023-5.365-4.938-8.63-4.938-3.395 0-6.236 1.097-8.48 3.285-.596.58-.832 1.374-.832 2.226 0 .839.218 1.68.537 2.468.347.825.725 1.642 1.137 2.457 1.271 1.965 3.595 3.897 8.157 3.897 2.854 0 5.236-.823 7.092-2.283.605-.488.898-1.229.898-1.705 0-.534-.216-1.075-.536-1.642-.349-.841-.726-1.679-1.137-2.524-3.005-5.298-4.877-8.08-4.877zM12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10S2 17.514 2 12 6.486 2 2 6.486 2 12s4.486 10 10 10z"/>
          </svg>
          View on GitHub
        </a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-padding {
  padding-top: 4rem;
  padding-bottom: 4rem;
}

@media (min-width: 640px) {
  .section-padding {
    padding-top: 6rem;
    padding-bottom: 6rem;
  }
}
</style>
