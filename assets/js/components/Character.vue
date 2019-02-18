<template>
  <div>
    <img :src="`/images/classes/${name}.jpg`" :alt="name" class="character-icon">
    {{ name }}
    <button v-on:click="$emit('remove', { characterName: name })">X</button>
  </div>
</template>

<script>
export default {
  props: ["name"]
};
</script>

<style>
.character-icon {
  max-width: 50px;
  max-height: 50px;
}
</style>
