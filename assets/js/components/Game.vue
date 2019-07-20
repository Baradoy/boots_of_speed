<template>
  <div v-if="gameState">
    <current-round v-bind:round="currentRound" v-on:set-initiative="setInitiative" />
    <manage-characters
      v-on:add="addCharacter"
      v-on:remove="removeCharacter"
      v-bind:selectedCharacters="characters"
    />

    <button v-on:click="previousRound">Previous Round</button>
    <button v-on:click="nextRound">Next Round</button>
  </div>
  <div v-else-if="loading">Loading</div>
  <div v-else-if="error">{{ error }}</div>
  <div v-else>Uncaught Error</div>
</template>

<script>
import ManageCharacters from "./ManageCharacters";
import Character from "./Character";
import Modal from "./Modal";
import CurrentRound from "./CurrentRound";
import { Socket } from "phoenix";
import { minus, objectToArray } from "../util/Character";

export default {
  name: "Game",
  components: {
    "manage-characters": ManageCharacters,
    "current-round": CurrentRound,
    charcater: Character,
    modal: Modal
  },
  data() {
    return {
      socket: null,
      channel: null,
      gameState: null,
      loading: true,
      error: null
    };
  },
  computed: {
    currentRound: function() {
      const {
        gameState: { round_stack }
      } = this;

      return round_stack[0];
    },
    characters: function() {
      const {
        currentRound: { characters }
      } = this;

      return objectToArray(characters);
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
      this.loading = false;
      this.gameState = payload;
    });
    this.channel
      .join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp);
        this.loading = false;
      })
      .receive("error", resp => {
        console.log("Unable to join", resp);
        this.loading = false;
        this.error = resp.message;
        console.log("join error", this.error);
      });
    this.channel.push("get_state");
  },
  methods: {
    addCharacter: function(event) {
      this.loading = true;
      console.log(this.channel.push("add_character", event));
    },
    removeCharacter: function(event) {
      this.loading = true;
      console.log(this.channel.push("remove_character", event));
    },
    setInitiative: function(event) {
      this.loading = true;
      console.log(this.channel.push("set_character_initiative", event));
    },
    nextRound: function(event) {
      this.loading = true;
      console.log(this.channel.push("next_round"));
    },
    previousRound: function(event) {
      this.loading = true;
      console.log(this.channel.push("previous_round"));
    }
  }
};
</script>

<style scoped>
div {
  color: purple;
}
</style>
