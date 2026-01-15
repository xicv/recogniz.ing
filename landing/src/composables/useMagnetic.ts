import { ref, onMounted, onUnmounted } from 'vue'

export interface MagneticOptions {
  strength?: number
  threshold?: number
  disabled?: boolean
}

export function useMagnetic(options: MagneticOptions = {}) {
  const {
    strength = 0.3,
    threshold = 100,
    disabled = false
  } = options

  const targetRef = ref<HTMLElement | null>(null)
  const transform = ref('')
  const isActive = ref(false)

  const isReducedMotion = ref(false)

  const checkReducedMotion = () => {
    isReducedMotion.value = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  }

  const handleMouseMove = (e: MouseEvent) => {
    if (disabled || isReducedMotion.value || !targetRef.value) return

    const rect = targetRef.value.getBoundingClientRect()
    const centerX = rect.left + rect.width / 2
    const centerY = rect.top + rect.height / 2

    const deltaX = e.clientX - centerX
    const deltaY = e.clientY - centerY

    const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY)

    if (distance < threshold) {
      isActive.value = true
      const moveX = deltaX * strength
      const moveY = deltaY * strength
      transform.value = `translate3d(${moveX}px, ${moveY}px, 0)`
    } else {
      isActive.value = false
      transform.value = ''
    }
  }

  const handleMouseLeave = () => {
    isActive.value = false
    transform.value = ''
  }

  onMounted(() => {
    checkReducedMotion()

    if (targetRef.value) {
      targetRef.value.addEventListener('mousemove', handleMouseMove)
      targetRef.value.addEventListener('mouseleave', handleMouseLeave)
    }
  })

  onUnmounted(() => {
    if (targetRef.value) {
      targetRef.value.removeEventListener('mousemove', handleMouseMove)
      targetRef.value.removeEventListener('mouseleave', handleMouseLeave)
    }
  })

  const bind = (el: HTMLElement) => {
    targetRef.value = el
    el.addEventListener('mousemove', handleMouseMove)
    el.addEventListener('mouseleave', handleMouseLeave)
  }

  return {
    targetRef,
    transform,
    isActive,
    bind
  }
}
