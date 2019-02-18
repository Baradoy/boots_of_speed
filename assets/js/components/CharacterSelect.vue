<template>
  <div
    v-on:click="$emit('select', { name: character.name, image: character.image, type: character.type})"
  >
    <img :src="character.image" :alt="character.name">
  </div>
</template>

<script>
export default {
  props: ["character"]
};
</script>

<style scoped>
img {
  max-width: 100px;
  max-height: 100px;
}
</style>
