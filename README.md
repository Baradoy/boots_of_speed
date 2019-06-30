# BootsOfSpeed

`Boots of Speed` refers to an Item Card in the popular legacy style board game [Gloomhaven](https://boardgamegeek.com/boardgame/174430/gloomhaven). The item allows the user to adjust their initiative.

Keeping track of initiative in Gloomhaven is tricky and error prone. BootsOfSpeed aims to reduce the difficulty of tracking initiative while playing Gloomhaven by providing a shared space for players to simultaneously track their initiatives.

## Current Status

[![CircleCI](https://circleci.com/gh/Baradoy/boots_of_speed/tree/master.svg?style=svg)](https://circleci.com/gh/Baradoy/boots_of_speed/tree/master)

This project has basic functionality for a single game. Next steps will likely include:

- Game management - The ability to add a game, have that game represented by a code that other players can join, and have that game clean itself up after it is no longer used.

- Error handling - Having a happy path is nice, but if you go off that path you will loose the current state of the game. That is not fun at all.

- Deployment - A path for deployment and hopefully even a sample server to run the game.

- Magic Tracking - Magic wax and wanes during a game of Gloomhaven. This should be included in the app.

- Current Initiative Tracking - As characters take their turn, there should be a big visual cue as to which characters have gone and who is next.

## Vue and Elixir Websockets

One of the main motivating factors for this project was to build something in Elixir and Vue using websockets.

## Build and Install

To start your Phoenix server:

- Install Erlang and Elixir Versions `asdf install`
- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000/#/game/basegame`](http://localhost:4000/#/game/basegame) from your browser.
