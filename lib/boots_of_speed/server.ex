defmodule BootsOfSpeed.Server do
  @moduledoc """
    Handles creating and retrieving game agents
  """
  use GenServer

  defmodule State do
    @moduledoc """
      Server state
    """
    defstruct supervisor: nil, games: nil, game_state_supervisor: nil
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      name: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  # API
  def start_link([supervisor]) do
    GenServer.start_link(__MODULE__, supervisor, name: __MODULE__)
  end

  def fetch_game_state_server(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:fetch_game_state_server, game_name})
  end

  def start_game_state_server(game_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:start_game_state_server, game_name})
  end

  # Callbacks

  def init(supervisor) when is_pid(supervisor) do
    Process.flag(:trap_exit, true)
    games = :ets.new(:games, [:private])
    {:ok, %State{supervisor: supervisor, games: games}}
  end

  def handle_call({:fetch_game_state_server, game_name}, _, %{games: games} = state) do
    case :ets.lookup(games, game_name) do
      [{_game_name, game_state_agent}] ->
        {:reply, {:ok, game_state_agent}, state}

      _ ->
        {:reply, {:error, "Game does not exist"}, state}
    end
  end

  def handle_call({:start_game_state_server, game_name}, _, %State{} = state) do
    %State{games: games} = state

    game_state_agent = start_new_game(game_name, games)

    {:reply, {:ok, game_state_agent}, state}
  end

  def handle_info({:DOWN, _ref, _, _, _}, %State{} = state) do
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, _reason}, %State{games: games} = state) do
    case :ets.match(games, {:"$1", pid}) do
      [[game_name]] ->
        true = :ets.delete(games, game_name)
        {:noreply, state}

      [] ->
        {:noreply, state}
    end
  end

  ## Private

  defp start_new_game(game_name, games) do
    {:ok, game_state_agent} = BootsOfSpeed.GameStateAgent.start_link(game_name)
    true = :ets.insert(games, {game_name, game_state_agent})
    game_state_agent
  end
end
