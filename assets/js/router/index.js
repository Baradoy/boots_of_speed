import Vue from "vue";
import Router from "vue-router";
import Lobby from "../components/Lobby";
import Game from "../components/Game";

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: "/",
      name: "Lobby",
      component: Lobby
    },
    {
      path: "/game/:id",
      name: "Game",
      component: Game
    }
  ]
});
