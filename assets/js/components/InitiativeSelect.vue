<template>
  <div class="selector">
    <div class="tens">
      <div v-for="t in range" v-bind:key="t" v-bind:tens="t">
        <button
          v-on:click="setTens(t)"
          v-bind:class="{ unselected: (tens !== null && tens !== t) }"
        >{{ t }}0</button>
      </div>
    </div>
    <div v-if="tens!=null" class="ones">
      <div v-for="o in range" v-bind:key="o" v-bind:tens="o">
        <button v-on:click="setOnes(o)">{{ tens }}{{ o }}</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      showModal: false,
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
}

button.unselected {
  background-color: lightgray;
}
</style>
