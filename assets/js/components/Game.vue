<template>
  <div>
    <charcater
      v-for="character in characters"
      v-bind:key="character.name"
      v-bind:name="character.name"
    />
    <manage-characters
      v-on:add="addCharacter"
      v-on:remove="removeCharacter"
      v-bind:selectedCharacters="characters"
    />
  </div>
</template>

<script>
import ManageCharacters from "./ManageCharacters";
import Character from "./Character";
import { Socket } from "phoenix";
import { objectToArray } from "../util/Character";

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
      gameState: { characters: {} }
    };
  },
  computed: {
    characters: function() {
      const {
        gameState: { characters }
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
      console.log(payload.body);
      this.gameState = payload.body;
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
      this.channel.push("add_character", { body: event });
    },
    removeCharacter: function(event) {
      this.channel.push("remove_character", { body: event });
    }
  }
};
</script>

<style scoped>
div {
  color: blue;
}
</style>
