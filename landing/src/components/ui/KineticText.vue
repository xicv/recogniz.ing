<script setup lang="ts">
import { ref, onMounted } from 'vue'

const props = withDefaults(
  defineProps<{
    text: string
    delay?: number
    stagger?: number
    class?: string
  }>(),
  {
    delay: 0,
    stagger: 50
  }
)

const words = ref<string[]>([])
const isAnimating = ref(false)

onMounted(() => {
  // Split text into words while preserving structure
  words.value = props.text.split(' ')
})
</script>

<template>
  <span :class="props.class">
    <template v-for="(word, index) in words" :key="index">
      <span
        class="kinetic-word inline-block transition-all duration-700 ease-out"
        :style="{
          animationDelay: `${delay + (index * stagger)}ms`,
          opacity: isAnimating ? 1 : 0,
          transform: isAnimating ? 'translateY(0)' : 'translateY(100%)'
        }"
        v-html="word + (index < words.length - 1 ? ' ' : '')"
      />
    </template>
  </span>
</template>

<style scoped>
.kinetic-word {
  display: inline-block;
  animation: word-reveal 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  opacity: 0;
  transform: translateY(100%);
}

@keyframes word-reveal {
  from {
    opacity: 0;
    transform: translateY(100%);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .kinetic-word {
    animation: none;
    opacity: 1;
    transform: none;
  }
}
</style>
