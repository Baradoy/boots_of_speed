<template>
  <div v-on:click="$emit('select', { characterName: name, image })">
    <img :src="image" :alt="name">
  </div>
</template>

<script>
export default {
  props: ["image", "name"]
};
</script>

<style scoped>
img {
  max-width: 100px;
  max-height: 100px;
}
</style>
