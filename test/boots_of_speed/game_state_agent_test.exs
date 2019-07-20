defmodule BootsOfSpeed.GameStateAgentTest do
  use ExUnit.Case

  alias BootsOfSpeed.GameStateAgent
  alias BootsOfSpeed.GameStateAgent.State

  defp current_round(state) do
    get_in(state, [:round_stack, Access.at(0)])
  end

  defp add_cragheart(pid) do
    GameStateAgent.add_character("cragheart", "image", "player", pid)
  end

  defp get_cragheart({:ok, state}), do: get_cragheart(state)

  defp get_cragheart(state) do
    state
    |> current_round()
    |> get_in([:characters, "cragheart"])
  end

  setup do
    {:ok, pid} = GameStateAgent.start_link("test_game")
    {:ok, pid: pid}
  end

  describe "get_state/1" do
    test "returns a state", %{pid: pid} do
      assert {:ok, %{round_stack: [%{characters: %{}}]}} = GameStateAgent.get_state(pid)
    end
  end

  describe "add_character/4" do
    test "Adds a Character to a state", %{pid: pid} do
      {:ok, state} = GameStateAgent.add_character("name", "image.png", "monster", pid)

      assert current_round(state) == %{characters: %{"name" => %{image: "image.png", type: "monster"}}}
    end
  end

  describe "remove_character/2" do
    test "Removes a Character from a state", %{pid: pid} do
      {:ok, _} = GameStateAgent.add_character("name", "image.png", "monster", pid)
      {:ok, state} = GameStateAgent.remove_character("name", pid)

      assert current_round(state) == %{characters: %{}}
    end
  end

  # TODO describe "set_character_initiative/2" do
  #   test "Sets a Characters Initiative", %{pid: pid} do
  #     {:ok, _} = GameStateAgent.add_character("name", "image.png", "monster", pid)
  #     {:ok, state} = GameStateAgent.set_character_initiative("name", 20, pid)

  #     assert current_round(state) == %{characters: %{"name" => %{image: "image.png", type: "monster", initiative: 20}}}
  #   end
  # end

  describe "next_round/1" do
    test "next_round creates a new round", %{pid: pid} do
      assert GameStateAgent.next_round(pid) ==
               {:ok, %State{name: "test_game", round_stack: [%{characters: %{}}, %{characters: %{}}]}}
    end

    test "next_round copies characters but not initiatives over", %{pid: pid} do
      assert pid |> add_cragheart() |> get_cragheart() == %{image: "image", type: "player"}

      assert GameStateAgent.set_character_initiative("cragheart", 71, pid)
             |> get_cragheart() == %{image: "image", type: "player", initiative: 71}

      assert GameStateAgent.next_round(pid) |> get_cragheart() == %{image: "image", type: "player"}
    end
  end

  describe "previous_round/1" do
    test "removes current round", %{pid: pid} do
      assert GameStateAgent.next_round(pid) ==
               {:ok, %State{name: "test_game", round_stack: [%{characters: %{}}, %{characters: %{}}]}}

      assert GameStateAgent.previous_round(pid) ==
               {:ok, %State{name: "test_game", round_stack: [%{characters: %{}}]}}
    end

    test "returns previous initiatives", %{pid: pid} do
      assert pid |> add_cragheart() |> get_cragheart() == %{image: "image", type: "player"}

      assert GameStateAgent.set_character_initiative("cragheart", 23, pid)
             |> get_cragheart() == %{image: "image", type: "player", initiative: 23}

      assert GameStateAgent.next_round(pid) |> get_cragheart() == %{image: "image", type: "player"}

      assert GameStateAgent.previous_round(pid) |> get_cragheart() == %{
               image: "image",
               type: "player",
               initiative: 23
             }
    end
  end
end
