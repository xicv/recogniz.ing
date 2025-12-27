import { onMounted, onUnmounted } from 'vue'

export function useScrollAnimations() {
  let observer: IntersectionObserver | null = null

  const addVisibleClass = (entry: IntersectionObserverEntry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible')
    }
  }

  onMounted(() => {
    // Small delay to ensure DOM is ready
    setTimeout(() => {
      observer = new IntersectionObserver(
        (entries) => {
          entries.forEach(addVisibleClass)
        },
        {
          threshold: 0.1,
          rootMargin: '0px 0px -50px 0px'
        }
      )

      // Observe all elements with scroll-reveal class
      document.querySelectorAll('.scroll-reveal').forEach((el) => {
        observer?.observe(el)
      })
    }, 100)
  })

  onUnmounted(() => {
    observer?.disconnect()
  })
}
