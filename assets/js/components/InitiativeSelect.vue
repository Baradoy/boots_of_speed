<template>
  <modal>
    <div slot="header">
      <img :src="character.image" :alt="character.name">
      <h2>Set Initiative</h2>
    </div>
    <div slot="body" class="selector">
      <div class="tens">
        <div v-for="t in range" v-bind:key="t" v-bind:tens="t">
          <button
            v-on:click="setTens(t)"
            v-bind:class="{ unselected: (tens !== null && tens !== t) }"
          >{{ t }}0</button>
        </div>
      </div>
      <div class="ones">
        <div v-if="tens!=null">
          <div v-for="o in range" v-bind:key="o" v-bind:tens="o">
            <button v-on:click="setOnes(o)">{{ tens }}{{ o }}</button>
          </div>
        </div>
      </div>
    </div>
    <div slot="footer"></div>
  </modal>
</template>

<script>
import Modal from "./Modal";

export default {
  props: ["character"],
  components: {
    modal: Modal
  },
  data() {
    return {
      tens: null,
      ones: null,
      range: Array.from(new Array(10), (val, i) => i)
    };
  },
  methods: {
    setTens: function(tens) {
      this.tens = tens;
    },
    setOnes: function(ones) {
      this.ones = ones;
      this.$emit("select", this.tens * 10 + ones);
    }
  }
};
</script>

<style scoped>
.selector {
  display: flex;
  flex-flow: row nowrap;
  justify-content: center;
  flex-basis: 1 1 300px;
  width: 300px;
}

button.unselected {
  background-color: lightgray;
}

.ones {
  flex-basis: 125px;
  transition: all 0.3s ease;
}

.tens {
  flex-basis: 125px;
  transition: all 0.3s ease;
}

img {
  max-width: 100px;
  max-height: 100px;
}
</style>
