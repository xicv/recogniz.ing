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

// Navigation guard for title updates
router.beforeEach((to) => {
  if (to.meta?.title) {
    document.title = to.meta.title as string
  }
})

export default router