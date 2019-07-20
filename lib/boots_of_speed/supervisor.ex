defmodule BootsOfSpeed.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  @impl true
  def init(_arg) do
    children = [
      {BootsOfSpeed.Server, [self()]}
    ]

    opts = [strategy: :rest_for_one]

    Supervisor.init(children, opts)
  end
end
