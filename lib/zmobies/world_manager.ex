defmodule Zmobies.WorldManager do
  use GenServer
  alias Zmobies.World

  @doc ~S"""
    Module for managing global locations of beings.

    ## Examples

        iex> Zmobies.WorldManager.start_link(10, 10)
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
        iex> Zmobies.WorldManager.insert(Zmobies.Location.at(x: 1, y: 1), :human)
        {:ok, :human}
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 1))
        {:occupied, :human}
        iex> Zmobies.WorldManager.insert(Zmobies.Location.at(x: 1, y: 1), :zombie)
        {:occupied, :human}
        iex> Zmobies.WorldManager.move(Zmobies.Location.at(x: 1, y: 1), Zmobies.Location.at(x: 1, y: 2))
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 2))
        {:occupied, :human}
        iex> Zmobies.WorldManager.remove(Zmobies.Location.at(x: 1, y: 1))
        iex> Zmobies.WorldManager.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
    """

  alias Zmobies.Location

  def start_link(x_lim, y_lim) do
    World.init

    GenServer.start_link(
      __MODULE__,
      {x_lim, y_lim},
      name: :world
    )
  end

  def stop do
    GenServer.stop(:world)
  end

  def at(%Location{} = location) do
    GenServer.call(:world, {:at, location})
  end

  def insert(%Location{} = location, value) do
    GenServer.call(:world, {:insert, location, value})
  end

  def remove(%Location{} = location) do
    GenServer.call(:world, {:remove, location})
  end

  def move(%Location{} = from, %Location{} = to) do
    GenServer.call(:world, {:move, from, to})
  end

  def handle_call({:at, location}, _, state) do
    {:reply, World.at(location, state), state}
  end

  def handle_call({:insert, location, value}, _, state) do
    {:reply, World.insert(location, value, state), state}
  end

  def handle_call({:remove, location}, _, state) do
    {:reply, World.remove(location, state), state}
  end

  def handle_call({:move, from, to}, _, state) do
    {:reply, World.move(from, to, state), state}
  end
end
