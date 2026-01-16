import { ref, onMounted, onUnmounted } from 'vue'

export interface ParallaxOptions {
  speed?: number
  disabled?: boolean
}

export function useParallax(options: ParallaxOptions = {}) {
  const { speed = 0.5, disabled = false } = options
  const scrollY = ref(0)
  const isReducedMotion = ref(false)

  let rafId: number | null = null

  const checkReducedMotion = () => {
    isReducedMotion.value = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  }

  const updateScroll = () => {
    if (disabled || isReducedMotion.value) return
    scrollY.value = window.scrollY
  }

  const throttledUpdate = () => {
    if (rafId !== null) return
    rafId = requestAnimationFrame(() => {
      updateScroll()
      rafId = null
    })
  }

  onMounted(() => {
    checkReducedMotion()
    window.addEventListener('scroll', throttledUpdate, { passive: true })
  })

  onUnmounted(() => {
    window.removeEventListener('scroll', throttledUpdate)
    if (rafId !== null) {
      cancelAnimationFrame(rafId)
    }
  })

  const getTransform = (elementSpeed?: number) => {
    const effectiveSpeed = elementSpeed ?? speed
    return `translate3d(0, ${scrollY.value * effectiveSpeed}px, 0)`
  }

  const getScale = (baseScale = 1, scaleSpeed = 0.0001) => {
    if (disabled || isReducedMotion.value) return baseScale
    return baseScale - (scrollY.value * scaleSpeed)
  }

  return {
    scrollY,
    isReducedMotion,
    getTransform,
    getScale
  }
}
