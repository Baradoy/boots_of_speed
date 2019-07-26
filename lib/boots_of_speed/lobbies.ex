defmodule BootsOfSpeed.Lobbies do
  @moduledoc """
  Context For Lobbies
  """

  @alphabet 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

  def create_game_name() do
    1..5
    |> Enum.reduce([], fn _, acc -> [Enum.random(@alphabet) | acc] end)
    |> to_string
  end
end
