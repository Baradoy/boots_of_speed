<template>
  <div v-on:click="$emit('select', { name: name, image, type})">
    <img :src="image" :alt="name">
  </div>
</template>

<script>
export default {
  props: ["image", "name", "type"]
};
</script>

<style scoped>
img {
  max-width: 100px;
  max-height: 100px;
}
</style>
