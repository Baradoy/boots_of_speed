defmodule BootsOfSpeed.Server do
  use GenServer

  defmodule State do
    defstruct supervisor: nil, games: %{}, game_state_supervisor: nil, monitors: nil, workers: nil
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      name: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  # API
  def start_link() do
    IO.puts("start_link/0")
  end

  def start_link(_, _) do
    IO.puts("start_link/0")
  end

  def start_link([supervisor]) do
    GenServer.start_link(__MODULE__, supervisor, name: __MODULE__)
  end

  def fetch_game_state_server(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:fetch_game_state_server, game_name})
  end

  def start_game_state_server(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:start_game_state_server, game_name})
  end

  def get_state(pid \\ __MODULE__) do
    GenServer.call(pid, :get_state)
  end

  # Callbacks

  def init(supervisor) when is_pid(supervisor) do
    Process.flag(:trap_exit, true)
    monitors = :ets.new(:monitors, [:private])
    send(self(), :start_game_state_supervisor)
    {:ok, %State{supervisor: supervisor, monitors: monitors}}
  end

  def handle_info(:start_game_state_supervisor, %State{supervisor: supervisor} = state) do
    child_opts = [restart: :temporary]
    child_spec = Supervisor.child_spec(BootsOfSpeed.GameStateSupervisor, child_opts)
    {:ok, worker_sup} = Supervisor.start_child(supervisor, child_spec)

    {:noreply, %{state | game_state_supervisor: worker_sup}}
  end

  def handle_call({:fetch_game_state_server, game_name}, _, %{games: games} = state) do
    case Map.get(games, game_name) do
      pid when is_pid(pid) ->
        {:reply, {:ok, pid}, state}

      _ ->
        {:reply, {:error, "Game does not exist"}, state}
    end
  end

  def handle_info({:DOWN, ref, _, _, _} = arg, %State{} = state) do
    IO.inspect(arg, label: handle_info)
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, _reason} = arg, %State{} = state) do
    IO.inspect(arg, label: handle_info)
    {:noreply, state}
  end

  def handle_call({:start_game_state_server, game_name}, _, %{games: games, game_state_supervisor: worker_sup} = state) do
    # TODO Handle game already existing
    child_spec = {BootsOfSpeed.GameStateAgent, game_name}

    {:ok, game_state_agent} = DynamicSupervisor.start_child(worker_sup, child_spec)

    # TODO monitor so we can remove the game if it dies
    games = Map.put(games, game_name, game_state_agent)

    {:reply, {:ok, game_state_agent}, %{state | games: games}}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end
end
