defmodule BootsOfSpeed.GameStateAgent do
  use Agent

  @type game_state :: %{round_stack: [round, ...]}
  @type round :: %{characters: map()}
  @type character :: %{name: String.t(), type: character_type, image: String.t()}
  @type character_type :: String.t()
  @type game_name :: String.t()

  defmodule State do
    @derive {Jason.Encoder, only: [:name, :round_stack]}
    defstruct name: "", round_stack: []

    defdelegate fetch(term, key), to: Map
    defdelegate get_and_update(data, key, function), to: Map
  end

  def start_link(name) do
    Agent.start_link(fn -> empty_state(name) end)
  end

  def get_state(agent) do
    Agent.get(agent, fn %State{} = state ->
      {:ok, state}
    end)
  end

  def empty_state(name) do
    %State{name: name, round_stack: [default_round()]}
  end

  def default_round do
    %{characters: %{}}
  end

  @spec add_character(String.t(), String.t(), character_type, Agent.t()) :: game_state
  def add_character(character_name, image, type, agent) do
    Agent.update(agent, fn %State{} = state ->
      update_in(state, [:round_stack, Access.at(0), :characters], fn
        characters ->
          Map.put(characters, character_name, %{
            image: image,
            type: type
          })
      end)
    end)

    get_state(agent)
  end

  @spec remove_character(String.t(), Agent.t()) :: game_state
  def remove_character(name, agent) do
    Agent.update(agent, fn %State{} = state ->
      update_in(state, [:round_stack, Access.at(0), :characters], fn
        characters -> Map.delete(characters, name)
      end)
    end)

    get_state(agent)
  end

  @spec set_character_initiative(String.t(), integer(), Agent.t()) :: game_state
  def set_character_initiative(name, initiative, agent) do
    Agent.update(agent, fn %State{} = state ->
      update_in(state, [:round_stack, Access.at(0), :characters, name], fn
        character -> Map.put(character, :initiative, initiative)
      end)
    end)

    get_state(agent)
  end

  @spec next_round(Agent.t()) :: game_state
  def next_round(agent) do
    Agent.update(agent, fn %State{} = state ->
      update_in(state, [:round_stack], fn
        [current_round | round_stack] -> [new_round(current_round) | [current_round | round_stack]]
      end)
    end)

    get_state(agent)
  end

  @spec previous_round(Agent.t()) :: game_state
  def previous_round(agent) do
    Agent.update(agent, fn %State{} = state ->
      update_in(state, [:round_stack], fn
        [_] ->
          [default_round()]

        [_popped_round_stack | round_stack] ->
          round_stack
      end)
    end)

    get_state(agent)
  end

  defp new_round(current_round) do
    update_in(current_round, [:characters], fn
      characters ->
        Map.new(characters, fn
          {name, character} -> {name, Map.delete(character, :initiative)}
        end)
    end)
  end
end
