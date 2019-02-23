defmodule BootsOfSpeed.GameState do
  @moduledoc """
  Context for changing game state.
  """

  @type state :: %{optional(String.t()) => game}
  @type game :: %{round_stack: [round, ...]}
  @type round :: %{characters: map()}
  @type character :: %{name: String.t(), type: character_type, image: String.t()}
  @type character_type :: String.t()
  @type game_name :: String.t()

  @spec default_state() :: %{optional(String.t()) => game}
  def default_state do
    %{"basegame" => %{round_stack: [default_round()]}}
  end

  @spec default_round() :: %{characters: %{}}
  def default_round do
    %{characters: %{}}
  end

  @spec add_character(state, game_name, String.t(), String.t(), character_type) :: game
  def add_character(state, game_name, name, image, type) do
    update_in(state, [game_name, :round_stack, Access.at(0), :characters], fn
      characters ->
        Map.put(characters, name, %{
          image: image,
          type: type
        })
    end)
  end

  @spec remove_character(state, game_name, String.t()) :: game
  def remove_character(state, game_name, name) do
    update_in(state, [game_name, :round_stack, Access.at(0), :characters], fn
      characters -> Map.delete(characters, name)
    end)
  end

  @spec set_character_initiative(state, game_name, String.t(), integer()) :: game
  def set_character_initiative(state, game_name, name, initiative) do
    update_in(state, [game_name, :round_stack, Access.at(0), :characters, name], fn
      character -> character |> Map.put(:initiative, initiative)
    end)
  end

  @spec next_round(state, game_name) :: game
  def next_round(state, game_name) do
    update_in(state, [game_name, :round_stack], fn
      [current_round | round_stack] ->
        [transform_round(current_round) | [current_round | round_stack]]
    end)
  end

  defp transform_round(current_round) do
    update_in(current_round, [:characters], fn
      characters ->
        Map.new(characters, fn
          {name, character} -> {name, Map.delete(character, :initiative)}
        end)
    end)
  end

  @spec previous_round(state, game_name) :: game
  def previous_round(state, game_name) do
    update_in(state, [game_name, :round_stack], fn
      [_] ->
        [default_round()]

      [_poped_round_stack | round_stack] ->
        round_stack
    end)
  end
end
