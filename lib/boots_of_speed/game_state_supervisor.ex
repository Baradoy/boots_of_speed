defmodule BootsOfSpeed.GameStateSupervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, _args)
  end

  def start_child(foo, bar, baz) do
    # spec = {MyWorker, foo: foo, bar: bar, baz: baz}
    # DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
