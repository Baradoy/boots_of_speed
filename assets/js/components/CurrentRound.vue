<template>
  <div class="round-container">
    <div class="round-header">Header</div>
    <div class="round-body">
      <div class="round-players">
        <charcater
          v-for="character in playerCharcters"
          v-bind:key="character.name"
          v-bind:character="character"
          v-on:set-initiative="setInitiative"
        />
      </div>
      <div class="round-initiatives">
        <charcater
          v-for="character in initiativeCharcters"
          v-bind:key="character.name"
          v-bind:character="character"
          v-on:set-initiative="setInitiative"
        />
      </div>
      <div class="round-monsters">
        <charcater
          v-for="character in monsterCharcters"
          v-bind:key="character.name"
          v-bind:character="character"
          v-on:set-initiative="setInitiative"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Character from "./Character";
import { objectToArray } from "../util/Character";

export default {
  name: "CurrentRound",
  props: ["round"],
  components: {
    charcater: Character
  },
  computed: {
    characters: function() {
      const { characters } = this.round;
      return objectToArray(characters);
    },
    playerCharcters: function() {
      return this.characters.filter(({ type }) => type === "player");
    },
    monsterCharcters: function() {
      return this.characters.filter(({ type }) => type === "monster");
    },
    initiativeCharcters: function() {
      return this.characters.filter(
        ({ initiative }) => initiative !== null && initiative !== undefined
      );
    }
  },
  methods: {
    setInitiative: function(event) {
      this.$emit("set-initiative", event);
    }
  }
};
</script>

<style scoped>
.round-container {
  display: flex;
  flex-flow: column nowrap;
}

.round-header {
  flex-shrink: 0;
}

.round-body {
  display: flex;
  flex-flow: row nowrap;
  flex-shrink: 0;
}

.round-players {
  flex: 1;
}

.round-initiatives {
  flex: 2;
}

.round-monsters {
  flex: 1;
}
</style>
