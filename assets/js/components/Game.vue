<template>
  <div>
    <charcater
      v-for="character in characters"
      v-bind:key="character.name"
      v-bind:name="character.name"
      v-on:remove="removeCharacter"
    />
    <add-character v-on:add="addCharacter"/>
  </div>
</template>

<script>
import AddCharacter from "./AddCharacter";
import Character from "./Character";
import { Socket } from "phoenix";

export default {
  name: "Game",
  components: {
    "add-character": AddCharacter,
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

      return Object.keys(characters).map(key => ({
        name: key,
        ...characters[key]
      }));
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
