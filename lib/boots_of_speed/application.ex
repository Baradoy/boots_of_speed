defmodule BootsOfSpeed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      BootsOfSpeedWeb.Endpoint,
      BootsOfSpeed.Supervisor
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

    BootsOfSpeed.Server.start_game_state_server("basegame")
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BootsOfSpeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
