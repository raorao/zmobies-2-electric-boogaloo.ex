defmodule Zmobies.WorldManager do
  use GenServer
  alias Zmobies.{World, Being, CharacterSupervisor, StatsManager}

  @doc ~S"""
    Module for managing global locations of beings.

    ## Examples

        iex> Zmobies.WorldManager.start_link({10,10},{0,0})
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
        iex> Zmobies.WorldManager.insert(Zmobies.Location.at(x: 1, y: 1), :human)
        {:ok, %Zmobies.Being{location: %Zmobies.Location{x: 1, y: 1}, type: :human}}
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 1))
        {:occupied, %Zmobies.Being{location: %Zmobies.Location{x: 1, y: 1}, type: :human}}
        iex> Zmobies.WorldManager.insert(Zmobies.Location.at(x: 1, y: 1), :zombie)
        {:occupied, %Zmobies.Being{location: %Zmobies.Location{x: 1, y: 1}, type: :human}}
        iex> Zmobies.WorldManager.move(Zmobies.Location.at(x: 1, y: 1), Zmobies.Location.at(x: 1, y: 2))
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 2))
        {:occupied, %Zmobies.Being{location: %Zmobies.Location{x: 1, y: 2}, type: :human}}
        iex> Zmobies.WorldManager.remove(Zmobies.Location.at(x: 1, y: 1))
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
    """

  alias Zmobies.Location

  def start_link(limits, beings) do
    GenServer.start_link(
      __MODULE__,
      {limits, beings},
      name: :world
    )
  end

  def init({limits, beings}) do
    send(self, :initialize_table)
    send(self, {:place, beings})
    {:ok, limits}
  end

  # to avoid read contention, we skip GenServer and delegate directly to ETS table.
  @spec at(%Location{}) :: World.unbounded_lookup
  def at(%Location{} = location) do
    World.at(location)
  end

  # to avoid read contention, we skip GenServer and delegate directly to ETS table.
  @spec all() :: [%Being{}]
  def all, do: World.all

  @spec insert(%Location{}, Being.character_type) :: {:ok, %Being{}} | World.bounded_lookup
  def insert(%Location{} = location, type) do
    GenServer.call(:world, {:insert, location, type})
  end

  @spec remove(%Location{}) :: :ok
  def remove(%Location{} = location) do
    GenServer.call(:world, {:remove, location})
  end

  @spec update(%Being{}) :: :ok
  def update(being) do
    GenServer.cast(:world, {:update, being})
  end

  @spec move(%Location{}, %Location{}) :: {:ok, %Being{}} | World.bounded_lookup
  def move(%Location{} = from, %Location{} = to) do
    GenServer.call(:world, {:move, from, to})
  end

  def insert_random(type) do
    GenServer.cast(:world, {:insert_random, type})
  end

  def handle_info(:initialize_table, limits) do
    World.init
    {:noreply, limits}
  end

  def handle_info({:place, {humans, zombies}}, limits) do
    Stream.repeatedly(fn -> :zombie end)
    |> Enum.take(zombies)
    |> Enum.each(&insert_random/1)

    Stream.repeatedly(fn -> :human end)
    |> Enum.take(humans)
    |> Enum.each(&insert_random/1)

    if humans > 0 and zombies > 0 do
      send(self, :start_stats)
    end

    {:noreply, limits}
  end

  def handle_info(:start_stats, limits) do
    StatsManager.start
    {:noreply, limits}
  end

  def handle_cast({:update, being}, limits) do
    World.update(being)
    {:noreply, limits}
  end

  def handle_cast({:insert_random, type}, limits) do
    do_insert_random(type, limits)
    {:noreply, limits}
  end

  def handle_call({:insert, location, type}, _, limits) do
    {:reply, World.insert(location, type, limits), limits}
  end

  def handle_call({:remove, location}, _, limits) do
    {:reply, World.remove(location, limits), limits}
  end

  def handle_call({:move, from, to}, _, limits) do
    {:reply, World.move(from, to, limits), limits}
  end

  defp do_insert_random(type, limits = {x_lim, y_lim}) do
    location = Location.at(x: :rand.uniform(x_lim ), y: :rand.uniform(y_lim))
    being = type
    |> Being.new(location)
    |> Being.set_traits

    case World.insert(location, being, limits) do
      {:ok, being} -> CharacterSupervisor.start_child(being)
      {:occupied, _} -> do_insert_random(type, limits)
    end
  end
end
