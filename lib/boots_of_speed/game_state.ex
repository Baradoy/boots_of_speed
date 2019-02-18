defmodule BootsOfSpeed.GameState do
  @moduledoc """
  Store Game State for running games
  """

  use GenServer

  # Client

  defp default_state do
    %{"basegame" => %{characters: %{}, round_stack: [%{characters: %{}}]}}
  end

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, default_state(), name: __MODULE__)
  end

  ## Game Management
  def add_game(game_name) do
    GenServer.call(__MODULE__, {:add_game, game_name})
  end

  def remove_game(game_name) do
    GenServer.call(__MODULE__, {:remove_game, game_name})
  end

  def list_game() do
    GenServer.call(__MODULE__, :list_game)
  end

  def get_game(game_name) do
    GenServer.call(__MODULE__, {:get_game, game_name})
  end

  # Character Management
  @spec add_character(any(), any()) :: any()
  def add_character(game_name, %{character_name: character_name, image: image, type: type}) do
    GenServer.call(__MODULE__, {:add_character, game_name, character_name, image, type})
  end

  def remove_character(game_name, character_name) do
    GenServer.call(__MODULE__, {:remove_character, game_name, character_name})
  end

  def set_character_initiative(game_name, %{
        character_name: character_name,
        image: image,
        type: type,
        initiative: initiative
      }) do
    GenServer.call(
      __MODULE__,
      {:set_character_initiative, game_name, character_name, image, type, initiative}
    )
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

  def handle_call(
        {:add_character, game_name, character_name, image, character_type},
        _from,
        state
      ) do
    state =
      update_in(state, [game_name, :characters], fn
        %{^character_name => _} = characters ->
          characters

        characters ->
          Map.put(characters, character_name, %{
            image: image,
            type: character_type
          })
      end)

    reply(game_name, state)
  end

  def handle_call(
        {:set_character_initiative, game_name, character_name, image, character_type, initiative},
        _from,
        state
      ) do
    state =
      update_in(state, [game_name, :round_stack, Access.at(0), :characters, character_name], fn
        _ ->
          %{
            image: image,
            type: character_type,
            initiative: initiative
          }
      end)

    # state =
    #   update_in(state, [game_name, :round_stack], fn
    #     [current_round | previous_rounds] ->
    #       updated_current_round =
    #         update_in(current_round, [:characters, character_name], fn
    #           _ ->
    #             %{
    #               image: image,
    #               type: character_type,
    #               initiative: initiative
    #             }
    #         end)

    # update_in(current_round, [:characters], fn
    #   %{^character_name => _} = characters ->
    #     %{characters | initiative: initiative}

    #   characters ->
    #     Map.put(characters, character_name, %{
    #       image: image,
    #       type: character_type,
    #       initiative: initiative
    #     })
    # end)

    #     [updated_current_round | previous_rounds]
    # end)

    reply(game_name, state)
  end

  def handle_call({:remove_character, game_name, character_name}, _from, state) do
    state =
      update_in(state, [game_name, :characters], fn
        characters -> Map.delete(characters, character_name)
      end)

    reply(game_name, state)
  end

  def handle_call({:get_current_round, game_name}, _from, state) do
    round = state |> Map.get(game_name, %{})

    {:reply, round, state}
  end

  @impl true
  def handle_cast({:remove_game, game_name}, state) do
    state = state |> Map.delete(game_name)
    {:noreply, state}
  end

  def handle_cast({:add_game, game_name}, state) do
    state = state |> Map.put(game_name, %{})
    {:noreply, state}
  end

  :next_round

  :previous_round

  def random_character_color() do
    Enum.random(["#FF00FF", "#FFFF00"])
  end

  def reply(game_name, state) do
    game = Map.get(state, game_name)

    {:reply, game, state}
  end
end
