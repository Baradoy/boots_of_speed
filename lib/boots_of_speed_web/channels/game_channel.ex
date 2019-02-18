defmodule BootsOfSpeedWeb.GameChannel do
  @moduledoc """
  Channel for messages around games and game state
  """

  use Phoenix.Channel

  @spec join(<<_::40, _::_*8>>, any(), any()) ::
          {:error, %{reason: <<_::96>>}} | {:ok, <<_::64, _::_*8>>, any()}
  def join("game:lobby", _message, socket) do
    {:ok, "You joined!", socket}
  end

  def join("game:" <> game_name, _params, socket) do
    BootsOfSpeed.GameState.get_game(game_name)
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
    game = BootsOfSpeed.GameState.get_game(game_name)
    broadcast!(socket, "state", %{body: game})
    {:noreply, socket}
  end

  def handle_in(
        "add_character",
        %{"body" => %{"characterName" => character_name}},
        %{topic: "game:" <> game_name} = socket
      ) do
    game = BootsOfSpeed.GameState.add_character(game_name, character_name)
    broadcast!(socket, "state", %{body: game})
    {:noreply, socket}
  end

  def handle_in(
        "remove_character",
        %{"body" => %{"characterName" => character_name}},
        %{topic: "game:" <> game_name} = socket
      ) do
    game = BootsOfSpeed.GameState.remove_character(game_name, character_name)
    broadcast!(socket, "state", %{body: game})
    {:noreply, socket}
  end

  def handle_in("add_game", %{"body" => body}, socket) do
    state = BootsOfSpeed.GameState.add_game(body)
    broadcast!(socket, "state", %{body: state})
    {:noreply, socket}
  end

  def handle_in("remove_game", %{"body" => body}, socket) do
    state = BootsOfSpeed.GameState.remove_game(body)
    broadcast!(socket, "state", %{body: state})
    {:noreply, socket}
  end
end
