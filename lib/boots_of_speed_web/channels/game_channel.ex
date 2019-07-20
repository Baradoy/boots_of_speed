defmodule BootsOfSpeedWeb.GameChannel do
  @moduledoc """
  Channel for messages around games and game state
  """

  use Phoenix.Channel
  alias BootsOfSpeed.Server
  alias BootsOfSpeed.GameStateAgent

  def join("game:lobby", _message, socket) do
    {:ok, "You joined!", socket}
  end

  def join("game:" <> game_name, _params, socket) do
    game_name
    |> Server.fetch_game_state_server()
    |> case do
      {:ok, game_state_agent} ->
        socket = assign(socket, :game_state_agent, game_state_agent)

        {:ok, "Joined #{game_name}!", socket}

      _ ->
        {:error, %{reason: "No such game!"}}
    end
  end

  def handle_in(
        "get_state",
        _,
        %{topic: "game:" <> _game_name, assigns: %{game_state_agent: game_state_agent}} = socket
      ) do
    {:ok, game_state} = GameStateAgent.get_state(game_state_agent)

    broadcast!(socket, "state", game_state)
    {:noreply, socket}
  end

  def handle_in(
        "add_character",
        %{"name" => character_name, "image" => image, "type" => type},
        %{topic: "game:" <> _game_name, assigns: %{game_state_agent: game_state_agent}} = socket
      ) do
    {:ok, game_state} =
      GameStateAgent.add_character(
        character_name,
        image,
        type,
        game_state_agent
      )

    broadcast!(socket, "state", game_state)
    {:noreply, socket}
  end

  def handle_in(
        "remove_character",
        %{"name" => character_name},
        %{topic: "game:" <> _game_name, assigns: %{game_state_agent: game_state_agent}} = socket
      ) do
    {:ok, game_state} = GameStateAgent.remove_character(character_name, game_state_agent)
    broadcast!(socket, "state", game_state)
    {:noreply, socket}
  end

  def handle_in(
        "set_character_initiative",
        %{
          "name" => character_name,
          "initiative" => initiative
        },
        %{topic: "game:" <> _game_name, assigns: %{game_state_agent: game_state_agent}} = socket
      ) do
    {:ok, game_state} =
      GameStateAgent.set_character_initiative(
        character_name,
        initiative,
        game_state_agent
      )

    broadcast!(socket, "state", game_state)
    {:noreply, socket}
  end

  def handle_in(
        "next_round",
        _,
        %{topic: "game:" <> _game_name, assigns: %{game_state_agent: game_state_agent}} = socket
      ) do
    {:ok, game_state} = GameStateAgent.next_round(game_state_agent)

    broadcast!(socket, "state", game_state)
    {:noreply, socket}
  end

  def handle_in(
        "previous_round",
        _,
        %{topic: "game:" <> _game_name, assigns: %{game_state_agent: game_state_agent}} = socket
      ) do
    {:ok, game_state} = GameStateAgent.previous_round(game_state_agent)

    broadcast!(socket, "state", game_state)
    {:noreply, socket}
  end

  def handle_in(message, _, socket) do
    IO.puts("Unhandled message: ")
    IO.puts(message)
    {:noreply, socket}
  end
end
