defmodule BootsOfSpeed.GameServerTest do
  use ExUnit.Case

  alias BootsOfSpeed.GameServer

  defp test_state do
    %{"test_game" => %{round_stack: [%{characters: %{}}]}}
  end

  defp current_round(state) do
    get_in(state, [:round_stack, Access.at(0)])
  end

  defp get_cragheart(state) do
    state
    |> current_round()
    |> get_in([:characters, "cragheart"])
  end

  defp add_cragheart(pid) do
    GameServer.add_character("test_game", %{character_name: "cragheart", image: "image", type: "player"}, pid)
  end

  setup do
    {:ok, pid} = GameServer.start_link(test_state())
    {:ok, pid: pid}
  end

  test "get_game returns a game", %{pid: pid} do
    assert GameServer.get_game("test_game", pid) == %{round_stack: [%{characters: %{}}]}
  end

  test "add_character adds a character", %{pid: pid} do
    assert add_cragheart(pid) ==
             %{round_stack: [%{characters: %{"cragheart" => %{image: "image", type: "player"}}}]}
  end

  test "remove_character removes an added character", %{pid: pid} do
    assert add_cragheart(pid) ==
             %{round_stack: [%{characters: %{"cragheart" => %{image: "image", type: "player"}}}]}

    assert GameServer.remove_character("test_game", "cragheart", pid) == %{
             round_stack: [%{characters: %{}}]
           }
  end

  test "set_character_initiative sets a character initiative", %{pid: pid} do
    assert add_cragheart(pid) ==
             %{round_stack: [%{characters: %{"cragheart" => %{image: "image", type: "player"}}}]}

    assert GameServer.set_character_initiative("test_game", %{character_name: "cragheart", initiative: 90}, pid) ==
             %{round_stack: [%{characters: %{"cragheart" => %{image: "image", type: "player", initiative: 90}}}]}
  end

  test "next_round creates a new round", %{pid: pid} do
    assert GameServer.next_round("test_game", pid) ==
             %{round_stack: [%{characters: %{}}, %{characters: %{}}]}
  end

  test "next_round copies characters over", %{pid: pid} do
    assert pid |> add_cragheart() |> get_cragheart() == %{image: "image", type: "player"}

    assert GameServer.next_round("test_game", pid) |> get_cragheart() == %{image: "image", type: "player"}
  end

  test "next_round copies characters but not initiatives over", %{pid: pid} do
    assert pid |> add_cragheart() |> get_cragheart() == %{image: "image", type: "player"}

    assert GameServer.set_character_initiative("test_game", %{character_name: "cragheart", initiative: 71}, pid)
           |> get_cragheart() == %{image: "image", type: "player", initiative: 71}

    assert GameServer.next_round("test_game", pid) |> get_cragheart() == %{image: "image", type: "player"}
  end

  test "previous_round removes current round", %{pid: pid} do
    assert GameServer.next_round("test_game", pid) ==
             %{round_stack: [%{characters: %{}}, %{characters: %{}}]}

    assert GameServer.previous_round("test_game", pid) ==
             %{round_stack: [%{characters: %{}}]}
  end

  test "previous_round returns even initiatives", %{pid: pid} do
    assert pid |> add_cragheart() |> get_cragheart() == %{image: "image", type: "player"}

    assert GameServer.set_character_initiative("test_game", %{character_name: "cragheart", initiative: 23}, pid)
           |> get_cragheart() == %{image: "image", type: "player", initiative: 23}

    assert GameServer.next_round("test_game", pid) |> get_cragheart() == %{image: "image", type: "player"}

    assert GameServer.previous_round("test_game", pid) |> get_cragheart() == %{
             image: "image",
             type: "player",
             initiative: 23
           }
  end
end
