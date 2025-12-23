import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import MainLayout from '@/components/layout/MainLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: MainLayout,
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/HomeView.vue'),
        meta: { title: 'Recogniz.ing - AI Voice Typing' }
      },
      {
        path: 'features',
        name: 'Features',
        component: () => import('@/views/FeaturesView.vue'),
        meta: { title: 'Features - Recogniz.ing' }
      },
      {
        path: 'downloads',
        name: 'Downloads',
        component: () => import('@/views/DownloadsView.vue'),
        meta: { title: 'Download - Recogniz.ing' }
      },
      {
        path: 'changelog',
        name: 'Changelog',
        component: () => import('@/views/ChangelogView.vue'),
        meta: { title: 'Changelog - Recogniz.ing' }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory('/'),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else if (to.hash) {
      return { el: to.hash, behavior: 'smooth' }
    } else {
      return { top: 0 }
    }
  }
})

// Handle GitHub Pages SPA fallback
// Check if we're coming from the 404.html redirect
if (window.location.search && window.location.search.includes('/')) {
  const path = window.location.search.slice(1).split('&')[0].replace(/\//g, '/')
  const newPath = path.replace(/~and~/g, '&')
  window.history.replaceState({}, '', newPath + window.location.hash)
}

// Navigation guard for title updates
router.beforeEach((to) => {
  if (to.meta?.title) {
    document.title = to.meta.title as string
  }
})

export default router