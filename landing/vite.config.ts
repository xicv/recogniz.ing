import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'
import { resolve } from 'path'

export default defineConfig({
  base: '/', // Using custom domain, so use root path
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@root': resolve(__dirname, '..'),
    },
  },
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
      // Add build timestamp to bust browser cache of service worker registration
      injectRegister: process.env.VITE_GIT_SHA ? false : 'script',
      inline: false, // Generate separate sw.js file
      workbox: {
        // CRITICAL: Don't include .html in globPatterns to exclude HTML from precache
        // HTML files will be fetched fresh from network, not served from service worker cache
        // This ensures users always get the latest index.html with updated script hashes
        globPatterns: ['**/*.{js,css,ico,png,svg,woff2}'],
        // Don't cache the 404.html for SPA routing
        navigateFallback: null,
        // Exclude downloads folder from PWA precaching (contains large Flutter web builds)
        globIgnores: ['**/downloads/**'],
        // Increase max file size to 10MB for larger assets
        maximumFileSizeToCacheInBytes: 10 * 1024 * 1024,
        // More aggressive update checking
        cleanupOutdatedCaches: true,
        // Clients claim ensures new SW takes control immediately
        clientsClaim: true,
        // Skip waiting ensures new SW activates immediately
        skipWaiting: true
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
            src: 'pwa-192x192.svg',
            sizes: '192x192',
            type: 'image/svg+xml'
          },
          {
            src: 'pwa-512x512.svg',
            sizes: '512x512',
            type: 'image/svg+xml'
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
        },
        // Ensure proper file extensions for GitHub Pages
        entryFileNames: 'assets/[name]-[hash].js',
        chunkFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]'
      }
    }
  },
  // Define global constants for build time
  define: {
    __BUILD_TIMESTAMP__: JSON.stringify(Date.now()),
    __GIT_SHA__: JSON.stringify(process.env.VITE_GIT_SHA || 'dev')
  },
  server: {
    headers: {
      'Cache-Control': 'no-store'
    }
  },
})