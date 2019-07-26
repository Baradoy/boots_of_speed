<template>
  <div>
    <h1>Lobby</h1>
    <button v-on:click="createGame">Create Game</button>
  </div>
</template>

<script>
export default {
  name: "Lobby",
  data() {
    return {};
  },
  mounted() {
    console.log("Lobby Mounted");
  },
  methods: {
    createGame: function(event) {
      fetch("/api/game", {
        method: "POST"
      })
        .then(response => {
          response.json().then(({ game_name }) => {
            console.log("Game Name", game_name);
            this.$router.push({ path: `/game/${game_name}` });
          });
        })
        .catch(error => console.error(error));
    }
  }
};
</script>

<style>
</style>
