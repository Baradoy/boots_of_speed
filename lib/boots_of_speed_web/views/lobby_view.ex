defmodule BootsOfSpeedWeb.LobbyView do
  use BootsOfSpeedWeb, :view

  def render("create.json", %{game_name: game_name}), do: %{game_name: game_name}
end
