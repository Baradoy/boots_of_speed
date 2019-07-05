defmodule BootsOfSpeed.ServerCopy do
  use GenServer
  import Supervisor.Spec

  defmodule State do
    defstruct sup: nil, games: %{}, game_state_supervisor: nil, monitors: nil, size: nil, mfa: nil, workers: nil
  end

  # API
  def start_link(sup, pool_config) do
    GenServer.start_link(__MODULE__, [sup, pool_config], name: __MODULE__)
  end

  def fetch_game_state_server(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:fetch_game_state_server, game_name})
  end

  def start_game_state_server(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:start_game_state_server, game_name})
  end

  def checkout do
    GenServer.call(__MODULE__, :checkout)
  end

  def checkin(worker_pid) do
    GenServer.cast(__MODULE__, {:checkin, worker_pid})
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Callbacks

  def init([sup, pool_config]) when is_pid(sup) do
    Process.flag(:trap_exit, true)
    monitors = :ets.new(:monitors, [:private])
    init(pool_config, %State{sup: sup, monitors: monitors})
  end

  def init([{:mfa, mfa} | rest], state) do
    init(rest, %{state | mfa: mfa})
  end

  def init([{:size, size} | rest], state) do
    init(rest, %{state | size: size})
  end

  def init([_ | rest], state) do
    init(rest, state)
  end

  def init([], state) do
    send(self(), :start_game_state_supervisor)
    {:ok, state}
  end

  def handle_info(:start_game_state_supervisor, %{sup: sup, mfa: mfa, size: size} = state) do
    {:ok, worker_sup} = Supervisor.start_child(sup, supervisor_spec(mfa))
    workers = prepopulate(size, worker_sup)
    {:noreply, %{state | game_state_supervisor: worker_sup, workers: workers}}
  end

  def handle_info({:DOWN, ref, _, _, _}, %{monitors: monitors, workers: workers} = state) do
    case :ets.match(monitors, {:"$1", ref}) do
      [[pid]] ->
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [pid | workers]}
        {:noreply, new_state}

      [[]] ->
        {:noreply, state}
    end
  end

  def handle_info({:EXIT, pid, _reason}, %{monitors: monitors, workers: workers, worker_sup: worker_sup} = state) do
    case :ets.lookup(monitors, pid) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [new_worker(worker_sup) | workers]}
        {:noreply, new_state}

      [[]] ->
        {:noreply, state}
    end
  end

  def handle_call({:fetch_game_state_server, game_name}, _, %{games: games} = state) do
    case Map.get(games, game_name) do
      pid when is_pid(pid) ->
        {:reply, {:ok, pid}, state}

      _ ->
        {:reply, {:error, "Game does not exist"}, state}
    end
  end

  def handle_call({:start_game_state_server, game_name}, _, %{games: games, game_state_supervisor: worker_sup} = state) do
    {:ok, worker} = Supervisor.start_child(worker_sup, [[]])

    case Map.get(games, game_name) do
      pid when is_pid(pid) ->
        {:reply, {:ok, pid}, state}

      _ ->
        {:reply, {:error, "Game does not exist"}, state}
    end
  end

  def handle_call(:checkout, {from_pid, _ref}, %{workers: workers, monitors: monitors} = state) do
    case workers do
      [worker | rest] ->
        ref = Process.monitor(from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | worker: rest}}

      [] ->
        {:reply, :no_proc, state}
    end
  end

  def handle_call(:status, _from, %{worker: workers, monitors: monitors} = state) do
    {:reply, {length(workers), :ets.info(monitors, :size)}, state}
  end

  def handle_cast({:checkin, worker}, %{workers: workers, monitors: monitors} = state) do
    case :ets.lookup(monitors, worker) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        {:noreply, %{state | workers: [pid | workers]}}

      [] ->
        {:noreply, state}
    end
  end

  # Private

  defp supervisor_spec(mfa) do
    # TODO: Will need some custom recovery logic.
    opts = [restart: :temporary]
    supervisor(BootsOfSpeed.GameStateSupervisor, [mfa], opts)
  end

  defp prepopulate(size, sup) do
    prepopulate(size, sup, [])
  end

  defp prepopulate(size, _sup, workers) when size < 1 do
    workers
  end

  defp prepopulate(size, sup, workers) do
    prepopulate(size - 1, sup, [new_worker(sup) | workers])
  end

  defp new_worker(sup) do
    sup
  end
end
