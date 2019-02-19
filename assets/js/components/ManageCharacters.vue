<template>
  <div>
    <button v-on:click="showModal = true">Manage Characters</button>
    <modal v-if="showModal" v-on:close="showModal = false">
      <div slot="header" class="character-header">
        <div class="character-header-player">
          <h2>Player Roster:</h2>
          <div class="player-select">
            <charcater-select
              v-for="character in selectedPlayers"
              v-bind:key="character.name"
              v-bind:character="character"
              v-on:select="event => $emit('remove', event)"
            />
            <div class="spacer"></div>
          </div>
        </div>
        <div class="character-header-monster">
          <h2>Monster Roster:</h2>
          <div class="monster-select">
            <charcater-select
              v-for="character in selectedMonster"
              v-bind:key="character.name"
              v-bind:character="character"
              v-on:select="event => $emit('remove', event)"
            />
            <div class="spacer"></div>
          </div>
        </div>
      </div>
      <div slot="body" class="character-body">
        <div class="character-body-player">
          <h2>Select Player:</h2>
          <div class="player-select">
            <charcater-select
              v-for="character in unselectedPlayer"
              v-bind:key="character.name"
              v-bind:character="character"
              v-on:select="event => $emit('add', event)"
            />
            <div class="spacer"></div>
          </div>
        </div>
        <div class="character-body-monster">
          <h2>Slect Monsters:</h2>
          <div class="monster-select">
            <charcater-select
              v-for="character in unselectedMonster"
              v-bind:key="character.name"
              v-bind:character="character"
              v-on:select="event => $emit('add', event)"
            />
            <div class="spacer"></div>
          </div>
        </div>
      </div>
    </modal>
  </div>
</template>

<script>
import CharcaterSelect from "./CharacterSelect";
import Modal from "./Modal";
import { allCharacters } from "../definitions";
import { minus } from "../util/Character";

export default {
  name: "ManageCharacters",
  props: ["selectedCharacters"],
  components: {
    "charcater-select": CharcaterSelect,
    modal: Modal
  },
  data() {
    return {
      showModal: false
    };
  },
  computed: {
    selectedPlayers: function() {
      return this.selectedCharacters.filter(({ type }) => type === "player");
    },
    selectedMonster: function() {
      return this.selectedCharacters.filter(({ type }) => type === "monster");
    },
    unselectedPlayer: function() {
      return this.unselectedCharacters.filter(({ type }) => type === "player");
    },
    unselectedMonster: function() {
      return this.unselectedCharacters.filter(({ type }) => type === "monster");
    },
    unselectedCharacters: function() {
      return minus(allCharacters, this.selectedCharacters);
    }
  }
};
</script>

<style scoped>
.character-header {
  display: flex;
  flex-flow: row nowrap;
  width: 100%;
  flex-shrink: 0;
}

.character-body {
  display: flex;
  flex-flow: row nowrap;
  width: 100%;
  flex-shrink: 0;
}

.character-header-player {
  flex: 1;
}

.character-header-monster {
  flex: 2;
}

.character-body-player {
  flex: 1;
}

.character-body-monster {
  flex: 2;
}

.player-select {
  display: flex;
  flex-flow: row wrap;
}

.monster-select {
  display: flex;
  flex-flow: row-reverse wrap;
}

.spacer {
  min-height: 100px;
}
</style>
