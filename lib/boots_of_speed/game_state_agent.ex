defmodule BootsOfSpeed.GameStateAgent do
  use Agent

  defmodule State do
    defstruct name: ""
  end

  def start_link(name) do
    Agent.start_link(fn -> %State{name: name} end)
  end

  def get_state(agent) do
    Agent.get(agent, fn
      %State{} = state -> state
    end)
  end
end
