defmodule BootsOfSpeed.GameStateTest do
  use ExUnit.Case

  alias BootsOfSpeed.GameState

  defp test_state do
    %{"test_game" => %{round_stack: [%{characters: %{}}]}}
  end

  defp current_round(state) do
    get_in(state, ["test_game", :round_stack, Access.at(0)])
  end

  test "Adds a Character to a state" do
    round =
      test_state()
      |> GameState.add_character("test_game", "name", "image.png", "monster")
      |> current_round

    assert round == %{characters: %{"name" => %{image: "image.png", type: "monster"}}}
  end

  test "Removes a Character from a state" do
    round =
      test_state()
      |> GameState.add_character("test_game", "name", "image.png", "monster")
      |> GameState.remove_character("test_game", "name")
      |> current_round

    assert round == %{characters: %{}}
  end

  test "Sets a Characters Initiative" do
    round =
      test_state()
      |> GameState.add_character("test_game", "name", "image.png", "monster")
      |> GameState.set_character_initiative("test_game", "name", 20)
      |> current_round

    assert round == %{characters: %{"name" => %{image: "image.png", type: "monster", initiative: 20}}}
  end
end
