<script setup lang="ts">
import { useScrollAnimations } from '@/composables/useScrollAnimations'
import { computed, ref } from 'vue'
import {
  FileEdit, CheckCircle, List, Mail, ClipboardList, MessageSquare,
  Globe, Cpu, Building, Heart, Scale, DollarSign,
  Zap, KeyRound, PieChart, Languages, BarChart3, Code,
  Moon, Clipboard, Bell, Download
} from 'lucide-vue-next'

useScrollAnimations()

type TabType = 'prompts' | 'vocabulary' | 'settings'
const activeTab = ref<TabType>('prompts')

const tabConfig = {
  prompts: {
    label: 'Smart Prompts',
    bg: 'bg-violet-100 dark:bg-violet-900/40',
    text: 'text-violet-600 dark:text-violet-400',
    activeBg: 'bg-violet-100 dark:bg-violet-900/50 text-violet-700 dark:text-violet-300'
  },
  vocabulary: {
    label: 'Vocabulary Sets',
    bg: 'bg-emerald-100 dark:bg-emerald-900/40',
    text: 'text-emerald-600 dark:text-emerald-400',
    activeBg: 'bg-emerald-100 dark:bg-emerald-900/50 text-emerald-700 dark:text-emerald-300'
  },
  settings: {
    label: 'Settings',
    bg: 'bg-slate-100 dark:bg-slate-800',
    text: 'text-slate-600 dark:text-slate-400',
    activeBg: 'bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-300'
  }
}

const prompts = [
  { title: 'Clean Transcription', description: 'Removes filler words and fixes grammar automatically', icon: FileEdit, badge: 'Popular' },
  { title: 'Formal Writing', description: 'Converts casual speech into professional text', icon: CheckCircle },
  { title: 'Bullet Points', description: 'Organizes content into concise, scannable bullets', icon: List },
  { title: 'Email Draft', description: 'Creates professional email templates', icon: Mail },
  { title: 'Meeting Notes', description: 'Structures meeting summaries and action items', icon: ClipboardList },
  { title: 'Social Media Post', description: 'Optimizes content for social platforms', icon: MessageSquare }
]

const vocabulary = [
  { title: 'General', description: 'Common words: AI, API, UI/UX, GitHub, Flutter, JavaScript', icon: Globe, badge: 'Default' },
  { title: 'Technology', description: 'Industry terms: Kubernetes, Docker, AWS, CI/CD', icon: Cpu },
  { title: 'Business', description: 'Corporate terms: ROI, KPI, SaaS, stakeholders', icon: Building },
  { title: 'Medical', description: 'Healthcare terms: diagnosis, therapy, radiology', icon: Heart },
  { title: 'Legal', description: 'Legal terms: liability, litigation, jurisprudence', icon: Scale },
  { title: 'Finance', description: 'Financial terms: portfolio, dividend, equity, IPO', icon: DollarSign }
]

const settings = [
  { title: 'Multi-API Key Management', description: 'Add multiple keys with smart failover — cascades through all available keys before falling back', icon: Zap, badge: 'New' },
  { title: 'API Configuration', description: 'Manage your Gemini API key for transcription', icon: KeyRound },
  { title: 'Per-Key Usage Tracking', description: 'Dashboard shows per-key stats, quota percentage, and remaining requests', icon: PieChart, badge: 'New' },
  { title: 'Transcription Language', description: 'Auto-detect or choose from 20+ languages', icon: Languages },
  { title: 'Usage Projections', description: 'See days until free tier exhaustion based on usage', icon: BarChart3 },
  { title: 'Global Hotkey', description: 'Set up global hotkeys for quick recording access', icon: Code },
  { title: 'Theme Preferences', description: 'Choose between light and dark themes', icon: Moon },
  { title: 'Auto-copy to Clipboard', description: 'Automatically copy transcription results', icon: Clipboard },
  { title: 'Show Notifications', description: 'Get notified when transcription completes', icon: Bell }
]

const activeItems = computed(() => {
  if (activeTab.value === 'prompts') return prompts
  if (activeTab.value === 'vocabulary') return vocabulary
  return settings
})

const activeConfig = computed(() => tabConfig[activeTab.value])
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="pt-28 sm:pt-36 pb-16 lg:pb-20">
      <div class="container-custom text-center max-w-3xl mx-auto">
        <h1
          class="text-4xl sm:text-5xl font-bold tracking-tight mb-5 text-slate-950 dark:text-slate-50 scroll-reveal"
          style="line-height: 1.1"
        >
          Powerful Features for
          <span class="text-sky-500">Voice Typing</span>
        </h1>
        <p class="text-lg sm:text-xl text-slate-600 dark:text-slate-400 scroll-reveal">
          Everything you need to transform your voice into perfect text, tailored to your workflow
        </p>
      </div>
    </section>

    <!-- Interactive Tabs -->
    <section class="py-16 lg:py-24">
      <div class="container-custom">
        <div class="max-w-2xl mx-auto text-center mb-12 scroll-reveal">
          <h2 class="text-3xl sm:text-4xl font-bold mb-4 text-slate-950 dark:text-slate-50">
            Tailor It to Your Needs
          </h2>
          <p class="text-lg text-slate-600 dark:text-slate-400">
            Create custom prompts, vocabulary sets, and configure settings
          </p>
        </div>

        <div class="max-w-5xl mx-auto">
          <!-- Tab Navigation -->
          <div class="flex justify-center mb-10 scroll-reveal">
            <div class="inline-flex rounded-xl border border-slate-200 dark:border-slate-700 p-1 bg-white dark:bg-slate-900">
              <button
                v-for="(config, tab) in tabConfig"
                :key="tab"
                @click="activeTab = tab as TabType"
                class="px-5 py-2.5 rounded-lg text-sm font-medium transition-all duration-200"
                :class="[
                  activeTab === tab
                    ? config.activeBg
                    : 'text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-300'
                ]"
              >
                {{ config.label }}
              </button>
            </div>
          </div>

          <!-- Tab Content -->
          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <transition name="tab-content" mode="out-in">
              <div :key="activeTab" class="contents">
                <div
                  v-for="item in activeItems"
                  :key="item.title"
                  class="card group"
                >
                  <span
                    v-if="item.badge"
                    class="inline-block px-2 py-0.5 rounded-full text-xs font-medium mb-3"
                    :class="`${activeConfig.bg} ${activeConfig.text}`"
                  >
                    {{ item.badge }}
                  </span>

                  <div
                    class="w-10 h-10 rounded-lg flex items-center justify-center mb-3"
                    :class="`${activeConfig.bg} ${activeConfig.text}`"
                  >
                    <component :is="item.icon" :size="18" />
                  </div>

                  <h3 class="text-base font-semibold mb-1.5 text-slate-950 dark:text-slate-50">
                    {{ item.title }}
                  </h3>
                  <p class="text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
                    {{ item.description }}
                  </p>
                </div>
              </div>
            </transition>
          </div>
        </div>

        <!-- Simple CTA -->
        <div class="text-center mt-14 scroll-reveal">
          <p class="text-slate-600 dark:text-slate-400 mb-4">
            Ready to try these features?
          </p>
          <RouterLink to="/downloads" class="btn-primary inline-flex items-center gap-2">
            <Download :size="16" />
            Download Now
          </RouterLink>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.tab-content-enter-active,
.tab-content-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.tab-content-enter-from,
.tab-content-leave-to {
  opacity: 0;
  transform: translateY(8px);
}
</style>
