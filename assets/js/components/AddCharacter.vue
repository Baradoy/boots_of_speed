<template>
  <div>
    <button v-on:click="showModal = true">Add Character</button>
    <div v-if="showModal" class="character-select-modal">
      <charcater-select
        v-for="character in charcaters"
        v-bind:key="character.name"
        v-bind:name="character.name"
        v-bind:image="character.image"
        v-on:select="selectCharacter"
      />
      <button v-on:click="showModal = false">Cancel</button>
    </div>
  </div>
</template>

<script>
import AddCharacter from "./AddCharacter";
import CharcaterSelect from "./CharacterSelect";

export default {
  name: "AddCharacter",
  components: {
    "charcater-select": CharcaterSelect
  },
  data() {
    return {
      characterName: "",
      showModal: false,
      charcaters: [
        { image: "/images/classes/angry.jpg", name: "angry" },
        { image: "/images/classes/brain.jpg", name: "brain" },
        { image: "/images/classes/circles.jpg", name: "circles" },
        { image: "/images/classes/fire.jpg", name: "fire" },
        { image: "/images/classes/gear.jpg", name: "gear" },
        { image: "/images/classes/horns.jpg", name: "horns" },
        { image: "/images/classes/knives.jpg", name: "knives" },
        { image: "/images/classes/lightning.jpg", name: "lightning" },
        { image: "/images/classes/link.jpg", name: "link" },
        { image: "/images/classes/moon.jpg", name: "moon" },
        { image: "/images/classes/saw.jpg", name: "saw" },
        { image: "/images/classes/song.jpg", name: "song" },
        { image: "/images/classes/spear.jpg", name: "spear" },
        { image: "/images/classes/squid.jpg", name: "squid" },
        { image: "/images/classes/star.jpg", name: "star" },
        { image: "/images/classes/sun.jpg", name: "sun" },
        { image: "/images/classes/windows.jpg", name: "windows" }
      ]
    };
  },
  methods: {
    selectCharacter: function(event) {
      this.$emit("add", event);
      this.showModal = false;
    }
  }
};
</script>

<style>
.character-select-modal {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}
</style>
