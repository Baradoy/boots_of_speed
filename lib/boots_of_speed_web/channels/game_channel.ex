defmodule BootsOfSpeedWeb.GameChannel do
  @moduledoc """
  Channel for messages around games and game state
  """

  use Phoenix.Channel
  alias BootsOfSpeed.GameServer

  @spec join(<<_::40, _::_*8>>, any(), any()) ::
          {:error, %{reason: <<_::96>>}} | {:ok, <<_::64, _::_*8>>, any()}
  def join("game:lobby", _message, socket) do
    {:ok, "You joined!", socket}
  end

  def join("game:" <> game_name, _params, socket) do
    GameServer.get_game(game_name)
    |> case do
      %{} ->
        assign(socket, :game_name, game_name)
        {:ok, "Joined #{game_name}!", socket}

      _ ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(
        "get_state",
        _,
        %{topic: "game:" <> game_name} = socket
      ) do
    game = GameServer.get_game(game_name)
    broadcast!(socket, "state", game)
    {:noreply, socket}
  end

  def handle_in(
        "add_character",
        %{"name" => character_name, "image" => image, "type" => type},
        %{topic: "game:" <> game_name} = socket
      ) do
    game =
      GameServer.add_character(game_name, %{
        character_name: character_name,
        image: image,
        type: type
      })

    broadcast!(socket, "state", game)
    {:noreply, socket}
  end

  def handle_in(
        "remove_character",
        %{"name" => character_name},
        %{topic: "game:" <> game_name} = socket
      ) do
    game = GameServer.remove_character(game_name, character_name)
    broadcast!(socket, "state", game)
    {:noreply, socket}
  end

  def handle_in(
        "set_character_initiative",
        %{
          "name" => character_name,
          "image" => image,
          "type" => type,
          "initiative" => initiative
        },
        %{topic: "game:" <> game_name} = socket
      ) do
    game =
      GameServer.set_character_initiative(game_name, %{
        character_name: character_name,
        image: image,
        type: type,
        initiative: initiative
      })

    broadcast!(socket, "state", game)
    {:noreply, socket}
  end

  def handle_in(
        "next_round",
        _,
        %{topic: "game:" <> game_name} = socket
      ) do
    game = GameServer.next_round(game_name)

    broadcast!(socket, "state", game)
    {:noreply, socket}
  end

  def handle_in(
        "previous_round",
        _,
        %{topic: "game:" <> game_name} = socket
      ) do
    game = GameServer.previous_round(game_name)

    broadcast!(socket, "state", game)
    {:noreply, socket}
  end

  def handle_in("add_game", %{"body" => body}, socket) do
    state = GameServer.add_game(body)
    broadcast!(socket, "state", state)
    {:noreply, socket}
  end

  def handle_in("remove_game", %{"body" => body}, socket) do
    state = GameServer.remove_game(body)
    broadcast!(socket, "state", state)
    {:noreply, socket}
  end

  def handle_in(message, _, socket) do
    IO.puts("Unhandled message: ")
    IO.puts(message)
    {:noreply, socket}
  end
end
