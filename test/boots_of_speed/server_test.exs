defmodule BootsOfSpeed.ServerTest do
  use ExUnit.Case

  alias BootsOfSpeed.Server

  describe "server" do
    test "start_game_state_server/1 returns a state" do
      assert {:ok, _pid} = Server.start_game_state_server("test")
    end

    test "fetch_game_state_server/1 gets an existing state" do
      Server.start_game_state_server("test")

      assert {:ok, _pid} = Server.fetch_game_state_server("test")
    end

    test "fetch_game_state_server/1 returns an error if the agent does not exist" do
      assert {:error, "Game does not exist"} = Server.fetch_game_state_server("test2")
    end
  end
end
