import { ref, onMounted, onUnmounted } from 'vue'

export interface IntersectionOptions {
  threshold?: number | number[]
  rootMargin?: string
  triggerOnce?: boolean
}

export function useIntersection(options: IntersectionOptions = {}) {
  const {
    threshold = 0.1,
    rootMargin = '0px 0px -50px 0px',
    triggerOnce = false
  } = options

  const targetRef = ref<HTMLElement | null>(null)
  const isVisible = ref(false)
  const hasEntered = ref(false)

  let observer: IntersectionObserver | null = null

  const checkReducedMotion = () => {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  }

  const observe = (el: HTMLElement) => {
    targetRef.value = el

    observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            isVisible.value = true
            hasEntered.value = true

            if (triggerOnce && observer) {
              observer.unobserve(entry.target)
            }
          } else if (!triggerOnce) {
            isVisible.value = false
          }
        })
      },
      {
        threshold,
        rootMargin
      }
    )

    observer.observe(el)
  }

  onMounted(() => {
    if (targetRef.value) {
      observe(targetRef.value)
    }
  })

  onUnmounted(() => {
    if (observer && targetRef.value) {
      observer.unobserve(targetRef.value)
    }
  })

  return {
    targetRef,
    isVisible,
    hasEntered,
    observe
  }
}

export function useIntersectionList(
  selector: string,
  options: IntersectionOptions = {}
) {
  const { threshold = 0.1, rootMargin = '0px 0px -50px 0px' } = options

  const elements = ref<HTMLElement[]>([])
  const visibleIndices = ref<Set<number>>(new Set())

  let observer: IntersectionObserver | null = null

  onMounted(() => {
    const els = document.querySelectorAll(selector)
    elements.value = Array.from(els) as HTMLElement[]

    observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          const index = elements.value.indexOf(entry.target as HTMLElement)
          if (index !== -1) {
            if (entry.isIntersecting) {
              visibleIndices.value.add(index)
            } else {
              visibleIndices.value.delete(index)
            }
          }
        })
      },
      { threshold, rootMargin }
    )

    elements.value.forEach((el) => observer?.observe(el))
  })

  onUnmounted(() => {
    if (observer) {
      elements.value.forEach((el) => observer?.unobserve(el))
      observer.disconnect()
    }
  })

  return {
    elements,
    visibleIndices,
    isAnyVisible: (index: number) => visibleIndices.value.has(index)
  }
}

export function useStaggeredIntersection(
  count: number,
  options: IntersectionOptions & { staggerDelay?: number } = {}
) {
  const { staggerDelay = 100 } = options
  const visibleStates = ref<boolean[]>(Array(count).fill(false))

  const observe = (container: HTMLElement) => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            visibleStates.value.forEach((_, i) => {
              setTimeout(() => {
                visibleStates.value[i] = true
              }, i * staggerDelay)
            })
            observer.disconnect()
          }
        })
      },
      { threshold: 0.1, rootMargin: options.rootMargin }
    )

    observer.observe(container)
  }

  return {
    visibleStates,
    observe
  }
}
