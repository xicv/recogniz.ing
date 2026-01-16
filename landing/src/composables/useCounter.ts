import { ref, watch, onMounted } from 'vue'

export interface CounterOptions {
  duration?: number
  startDelay?: number
  easing?: (t: number) => number
  formatFn?: (value: number) => string | number
}

// Easing function: ease-out quart
const easeOutQuart = (t: number): number => {
  return 1 - Math.pow(1 - t, 4)
}

export function useCounter(target: number, options: CounterOptions = {}) {
  const {
    duration = 2000,
    startDelay = 0,
    easing = easeOutQuart,
    formatFn
  } = options

  const current = ref(0)
  const isVisible = ref(false)
  const isAnimating = ref(false)

  let startTime: number | null = null
  let animationFrame: number | null = null
  let timeoutId: number | null = null

  const animate = () => {
    if (startTime === null) {
      startTime = performance.now()
    }

    const elapsed = performance.now() - startTime
    const progress = Math.min(elapsed / duration, 1)
    const easedProgress = easing(progress)

    current.value = target * easedProgress

    if (progress < 1) {
      animationFrame = requestAnimationFrame(animate)
    } else {
      isAnimating.value = false
    }
  }

  const start = () => {
    if (isAnimating.value || current.value === target) return

    isAnimating.value = true
    current.value = 0

    timeoutId = window.setTimeout(() => {
      startTime = null
      animate()
    }, startDelay)
  }

  const stop = () => {
    if (animationFrame !== null) {
      cancelAnimationFrame(animationFrame)
      animationFrame = null
    }
    if (timeoutId !== null) {
      clearTimeout(timeoutId)
      timeoutId = null
    }
    isAnimating.value = false
  }

  const reset = () => {
    stop()
    current.value = 0
    startTime = null
  }

  watch(isVisible, (visible) => {
    if (visible) {
      start()
    } else {
      reset()
    }
  })

  const formattedValue = ref(formatFn ? formatFn(current.value) : current.value)

  watch(current, (val) => {
    formattedValue.value = formatFn ? formatFn(val) : val
  })

  onMounted(() => {
    // Auto-start on mount
    start()
  })

  return {
    current,
    formattedValue,
    isVisible,
    isAnimating,
    start,
    stop,
    reset
  }
}

export function useCounterGroup(configs: Array<{ target: number } & CounterOptions>) {
  const counters = configs.map(config => useCounter(config.target, config))

  const startAll = () => counters.forEach(c => c.start())
  const stopAll = () => counters.forEach(c => c.stop())
  const resetAll = () => counters.forEach(c => c.reset())

  return {
    counters,
    startAll,
    stopAll,
    resetAll
  }
}
