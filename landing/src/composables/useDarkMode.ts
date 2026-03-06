import { ref, watch, onMounted, onUnmounted } from 'vue'

export function useDarkMode() {
  // Sync initial state with DOM (dark class may already be set by inline script in index.html)
  const isDark = ref(document.documentElement.classList.contains('dark'))

  // Watch for changes and update DOM + localStorage
  watch(isDark, () => {
    updateTheme()
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
  })

  // Listen for system theme changes
  let mediaQuery: MediaQueryList | null = null
  const handleChange = (e: MediaQueryListEvent) => {
    // Only update if user hasn't set a preference
    if (!localStorage.getItem('theme')) {
      isDark.value = e.matches
    }
  }

  onMounted(() => {
    mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    mediaQuery.addEventListener('change', handleChange)
  })

  onUnmounted(() => {
    mediaQuery?.removeEventListener('change', handleChange)
  })

  function updateTheme() {
    if (isDark.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  function toggle() {
    isDark.value = !isDark.value
  }

  return {
    isDark,
    toggle
  }
}
