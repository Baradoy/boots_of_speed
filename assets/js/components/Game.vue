<template>
  <div>
    <charcater
      v-for="character in charactersWithoutInitiatives"
      v-bind:key="character.name"
      v-bind:character="character"
      v-on:set-initiative="setInitiative"
    />
    <h2>Initiative Set:</h2>
    <charcater
      v-for="character in charactersWithInitiatives"
      v-bind:key="character.name"
      v-bind:character="character"
      v-on:set-initiative="setInitiative"
    />
    <manage-characters
      v-on:add="addCharacter"
      v-on:remove="removeCharacter"
      v-bind:selectedCharacters="characters"
    />

    <button v-on:click="previousRound">Previous Round</button>
    <button v-on:click="nextRound">Next Round</button>
  </div>
</template>

<script>
import ManageCharacters from "./ManageCharacters";
import Character from "./Character";
import { Socket } from "phoenix";
import { minus, objectToArray } from "../util/Character";

export default {
  name: "Game",
  components: {
    "manage-characters": ManageCharacters,
    charcater: Character
  },
  data() {
    return {
      socket: null,
      channel: null,
      gameState: { characters: {}, round_stack: [{ characters: {} }] }
    };
  },
  computed: {
    characters: function() {
      const {
        gameState: { characters },
        charactersWithInitiatives
      } = this;

      return objectToArray(characters);
    },
    charactersWithInitiatives: function() {
      const {
        gameState: { round_stack }
      } = this;

      const { characters } = round_stack[0];

      return objectToArray(characters).sort(
        ({ initiative: a }, { initiative: b }) => a - b
      );
    },
    charactersWithoutInitiatives: function() {
      const { characters, charactersWithInitiatives } = this;

      return minus(characters, charactersWithInitiatives);
    }
  },
  mounted() {
    console.log("Mounted");
    this.socket = new Socket("/socket", {
      params: { token: window.userToken }
    });
    this.socket.connect();
    this.channel = this.socket.channel("game:" + this.$route.params.id, {});
    this.channel.on("state", payload => {
      console.log("New Game State:");
      console.log(payload);
      this.gameState = payload;
    });
    this.channel
      .join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp);
      })
      .receive("error", resp => {
        console.log("Unable to join", resp);
      });
    this.channel.push("get_state");
  },
  methods: {
    addCharacter: function(event) {
      this.channel.push("add_character", event);
    },
    removeCharacter: function(event) {
      this.channel.push("remove_character", event);
    },
    setInitiative: function(event) {
      this.channel.push("set_character_initiative", event);
    },
    nextRound: function(event) {
      this.channel.push("next_round");
    },
    previousRound: function(event) {
      this.channel.push("previous_round");
    }
  }
};
</script>

<style scoped>
div {
  color: purple;
}
</style>
