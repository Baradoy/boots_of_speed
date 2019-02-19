<template>
  <div>
    <img
      :src="character.image"
      :alt="character.name"
      class="character-icon"
      v-on:click="openInitiative"
    >
    <h2>{{ character.initiative }}</h2>
    <initiative-select
      v-if="initiativeModalOpen"
      v-on:select="setInitiative"
      v-bind:character="character"
    />
  </div>
</template>

<script>
import InitiativeSelect from "./InitiativeSelect";

export default {
  props: ["character"],
  components: {
    "initiative-select": InitiativeSelect
  },
  data() {
    return {
      initiative: null,
      initiativeModalOpen: false
    };
  },
  methods: {
    openInitiative: function(event) {
      this.initiativeModalOpen = true;
    },
    setInitiative: function(event) {
      this.initiative = event;
      this.initiativeModalOpen = false;
      this.$emit("set-initiative", { ...this.character, initiative: event });
    }
  }
};
</script>

<style>
.character-icon {
  max-width: 100px;
  max-height: 100px;
}
</style>
