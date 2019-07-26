defmodule BootsOfSpeedWeb.LobbyController do
  use BootsOfSpeedWeb, :controller

  alias BootsOfSpeed.Lobbies
  alias BootsOfSpeed.Server

  def create(conn, _params) do
    game_name = Lobbies.create_game_name()
    Server.start_game_state_server(game_name)

    render(conn, "create.json", %{game_name: game_name})
  end
end
