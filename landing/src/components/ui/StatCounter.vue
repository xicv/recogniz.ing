<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'

export interface StatCounterProps {
  value: number
  label?: string
  suffix?: string
  prefix?: string
  duration?: number
  formatFn?: (value: number) => string
  decimals?: number
}

const props = withDefaults(defineProps<StatCounterProps>(), {
  duration: 2000,
  decimals: 0
})

const isVisible = ref(false)
const animatedValue = ref(0)
const isAnimating = ref(false)

const easeOutQuart = (t: number): number => {
  return 1 - Math.pow(1 - t, 4)
}

const animate = () => {
  if (isAnimating.value) return

  isAnimating.value = true
  const startTime = performance.now()
  const startValue = 0
  const endValue = props.value

  const step = (currentTime: number) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / props.duration, 1)
    const easedProgress = easeOutQuart(progress)

    animatedValue.value = startValue + (endValue - startValue) * easedProgress

    if (progress < 1) {
      requestAnimationFrame(step)
    } else {
      isAnimating.value = false
    }
  }

  requestAnimationFrame(step)
}

const displayValue = ref(
  props.formatFn
    ? props.formatFn(animatedValue.value)
    : animatedValue.value.toFixed(props.decimals)
)

watch(animatedValue, (val) => {
  displayValue.value = props.formatFn
    ? props.formatFn(val)
    : val.toFixed(props.decimals)
})

watch(isVisible, (visible) => {
  if (visible) {
    animate()
  }
})

onMounted(() => {
  // Start animation when element intersects viewport
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          isVisible.value = true
          observer.disconnect()
        }
      })
    },
    { threshold: 0.3 }
  )

  const el = document.currentElement as HTMLElement
  if (el) {
    observer.observe(el)
  }
})

defineExpose({
  start: animate
})
</script>

<template>
  <div class="stat-counter flex flex-col items-center">
    <div class="stat-value flex items-baseline gap-1">
      <span v-if="prefix" class="text-2xl sm:text-3xl font-semibold text-slate-400">
        {{ prefix }}
      </span>
      <span
        class="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-slate-950 dark:text-slate-50 tabular-nums"
      >
        {{ displayValue }}
      </span>
      <span v-if="suffix" class="text-2xl sm:text-3xl font-semibold text-slate-400">
        {{ suffix }}
      </span>
    </div>
    <p v-if="label" class="stat-label mt-2 text-sm sm:text-base text-slate-600 dark:text-slate-400">
      {{ label }}
    </p>
  </div>
</template>

<style scoped>
.tabular-nums {
  font-variant-numeric: tabular-nums;
}
</style>
