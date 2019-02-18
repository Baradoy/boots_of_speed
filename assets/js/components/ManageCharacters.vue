<template>
  <div>
    <button v-on:click="showModal = true">Manage Characters</button>
    <div v-if="showModal" class="character-management">
      <h2>Current Roster:</h2>
      <div class="character-select">
        <charcater-select
          v-for="character in selectedCharacters"
          v-bind:key="character.name"
          v-bind:name="character.name"
          v-bind:image="character.image"
          v-bind:type="character.type"
          v-on:select="event => $emit('remove', event)"
        />
        <div class="spacer"></div>
      </div>
      <h2>Character to Choose From:</h2>
      <div class="character-select">
        <charcater-select
          v-for="character in unselectedCharacters"
          v-bind:key="character.name"
          v-bind:name="character.name"
          v-bind:image="character.image"
          v-bind:type="character.type"
          v-on:select="event => $emit('add', event)"
        />

        <div class="spacer"></div>
      </div>
      <button v-on:click="showModal = false">Done</button>
    </div>
  </div>
</template>

<script>
import CharcaterSelect from "./CharacterSelect";
import { allCharacters } from "../definitions";
import { minus } from "../util/Character";

export default {
  name: "ManageCharacters",
  props: ["selectedCharacters"],
  components: {
    "charcater-select": CharcaterSelect
  },
  data() {
    return {
      showModal: false
    };
  },
  computed: {
    unselectedCharacters: function() {
      return minus(allCharacters, this.selectedCharacters);
    }
  }
};
</script>

<style scoped>
.character-management {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
}

.character-select {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}

.spacer {
  min-height: 100px;
}
</style>
