defmodule BootsOfSpeed.GameServer do
  @moduledoc """
  GenServer for Gloomhaven Game State
  """

  use GenServer

  alias BootsOfSpeed.GameState

  # Client

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link([]) do
    GenServer.start_link(__MODULE__, GameState.default_state(), name: __MODULE__)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  ## Game Management
  def get_game(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_game, game_name})
  end

  # Character Management
  def add_character(game_name, %{character_name: character_name, image: image, type: type}, pid \\ __MODULE__) do
    GenServer.call(pid, {:add_character, game_name, character_name, image, type})
  end

  def remove_character(game_name, character_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:remove_character, game_name, character_name})
  end

  def set_character_initiative(
        game_name,
        %{
          character_name: character_name,
          initiative: initiative
        },
        pid \\ __MODULE__
      ) do
    GenServer.call(
      pid,
      {:set_character_initiative, game_name, character_name, initiative}
    )
  end

  def next_round(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:next_round, game_name})
  end

  def previous_round(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:previous_round, game_name})
  end

  # Server (callbacks)

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:list_game, _from, state) do
    game_names = state |> Map.keys()

    {:reply, game_names, state}
  end

  def handle_call({:get_game, game_name}, _from, state) do
    game = state |> Map.get(game_name, %{})
    {:reply, game, state}
  end

  def handle_call({:remove_game, game_name}, _from, state) do
    state = state |> Map.delete(game_name)
    {:reply, state, state}
  end

  def handle_call({:add_game, game_name}, _from, state) do
    state = state |> Map.put(game_name, %{})
    {:reply, state, state}
  end

  def handle_call({:add_character, game_name, character_name, image, type}, _from, state) do
    state
    |> GameState.add_character(game_name, character_name, image, type)
    |> reply(game_name)
  end

  def handle_call({:remove_character, game_name, character_name}, _from, state) do
    state
    |> GameState.remove_character(game_name, character_name)
    |> reply(game_name)
  end

  def handle_call({:set_character_initiative, game_name, character_name, initiative}, _from, state) do
    state
    |> GameState.set_character_initiative(game_name, character_name, initiative)
    |> reply(game_name)
  end

  def handle_call({:next_round, game_name}, _from, state) do
    state
    |> GameState.next_round(game_name)
    |> reply(game_name)
  end

  def handle_call({:previous_round, game_name}, _from, state) do
    state
    |> GameState.previous_round(game_name)
    |> reply(game_name)
  end

  defp reply(state, game_name) do
    game = Map.get(state, game_name)

    {:reply, game, state}
  end
end
