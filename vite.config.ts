import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  base: '/', // Using custom domain, so use root path
  plugins: [
    vue({
      template: {
        compilerOptions: {
          // Treat any tag that starts with k- as a custom element
          isCustomElement: (tag) => tag.includes('-')
        }
      }
    }),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}']
      },
      includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
      manifest: {
        name: 'Recogniz.ing - AI Voice Typing',
        short_name: 'Recogniz.ing',
        description: 'Free AI-powered voice typing application with customizable prompts and vocabulary',
        theme_color: '#1e293b',
        background_color: '#ffffff',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      }
    })
  ],
  build: {
    target: 'esnext',
    minify: 'terser',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue']
        }
      }
    }
  },
  server: {
    headers: {
      'Cache-Control': 'no-store'
    }
  },
  })