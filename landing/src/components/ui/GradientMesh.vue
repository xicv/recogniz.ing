<script setup lang="ts">
import { ref, onMounted } from 'vue'

const props = withDefaults(
  defineProps<{
    colors?: string[]
    speed?: number
    opacity?: number
  }>(),
  {
    colors: () => [
      'rgba(14, 165, 233, 0.15)', // sky-500
      'rgba(6, 182, 212, 0.12)',  // cyan-500
      'rgba(20, 184, 166, 0.1)',  // teal-500
      'rgba(139, 92, 246, 0.08)'  // violet-500
    ],
    speed: 20,
    opacity: 0.6
  }
)

const meshId = ref(`gradient-mesh-${Math.random().toString(36).substr(2, 9)}`)
</script>

<template>
  <div
    class="gradient-mesh-container pointer-events-none absolute inset-0 overflow-hidden"
    :style="{ opacity }"
  >
    <svg
      class="gradient-mesh-svg absolute inset-0 w-full h-full"
      :style="{ animationDuration: `${speed}s` }"
      preserveAspectRatio="xMidYMid slice"
    >
      <defs>
        <filter :id="`${meshId}-blur`">
          <feGaussianBlur in="SourceGraphic" stdDeviation="80" />
        </filter>
      </defs>

      <!-- Animated gradient blobs -->
      <g :filter="`url(#${meshId}-blur)`">
        <!-- Blob 1 - Top center -->
        <circle
          cx="50%"
          cy="20%"
          r="25%"
          :fill="colors[0]"
          class="gradient-blob gradient-blob-1"
        />

        <!-- Blob 2 - Bottom left -->
        <circle
          cx="20%"
          cy="70%"
          r="30%"
          :fill="colors[1]"
          class="gradient-blob gradient-blob-2"
        />

        <!-- Blob 3 - Bottom right -->
        <circle
          cx="80%"
          cy="75%"
          r="28%"
          :fill="colors[2]"
          class="gradient-blob gradient-blob-3"
        />

        <!-- Blob 4 - Center right -->
        <circle
          cx="75%"
          cy="45%"
          r="22%"
          :fill="colors[3]"
          class="gradient-blob gradient-blob-4"
        />
      </g>
    </svg>

    <!-- Grid overlay -->
    <div class="gradient-mesh-grid absolute inset-0" />
  </div>
</template>

<style scoped>
.gradient-mesh-svg {
  animation: mesh-shift 30s ease-in-out infinite;
}

.gradient-blob {
  transform-origin: center;
  animation: blob-pulse 8s ease-in-out infinite;
}

.gradient-blob-1 {
  animation-delay: 0s;
}

.gradient-blob-2 {
  animation-delay: -2s;
}

.gradient-blob-3 {
  animation-delay: -4s;
}

.gradient-blob-4 {
  animation-delay: -6s;
}

@keyframes mesh-shift {
  0%, 100% {
    transform: scale(1) translate(0, 0);
  }
  25% {
    transform: scale(1.05) translate(-2%, 1%);
  }
  50% {
    transform: scale(1.02) translate(1%, -1%);
  }
  75% {
    transform: scale(1.03) translate(-1%, 2%);
  }
}

@keyframes blob-pulse {
  0%, 100% {
    r: 22%;
    opacity: 0.8;
  }
  50% {
    r: 28%;
    opacity: 1;
  }
}

.gradient-mesh-grid {
  background-image:
    linear-gradient(to right, rgba(0, 0, 0, 0.02) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(0, 0, 0, 0.02) 1px, transparent 1px);
  background-size: 64px 64px;
}

.dark .gradient-mesh-grid {
  background-image:
    linear-gradient(to right, rgba(255, 255, 255, 0.02) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(255, 255, 255, 0.02) 1px, transparent 1px);
}
</style>
