defmodule Zmobies.World do
  @doc ~S"""
    Module for managing global locations of beings.

    ## Examples

        iex> Zmobies.World.init
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
        iex> Zmobies.World.upsert(Zmobies.Location.at(x: 1, y: 1), :human)
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        {:occupied, :human}
        iex> Zmobies.World.upsert(Zmobies.Location.at(x: 1, y: 1), :zombie)
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        {:occupied, :zombie}
        iex> Zmobies.World.move(Zmobies.Location.at(x: 1, y: 1), Zmobies.Location.at(x: 1, y: 2))
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 2))
        {:occupied, :zombie}
        iex> Zmobies.World.remove(Zmobies.Location.at(x: 1, y: 1))
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
    """

  alias Zmobies.Location

  def init do
    :ets.new(:world, [:set, :named_table])
  end

  def upsert(%Location{} = location, value) do
    :ets.insert(:world, {location, value})
  end

  def at(%Location{} = location) do
    case :ets.lookup(:world, location) do
      [{^location, value}] -> {:occupied, value}
      [] -> :vacant
    end
  end

  def remove(%Location{} = location) do
    :ets.delete(:world, location)
  end

  def move(%Location{} = from, %Location{} = to) do
    {:occupied, value} = at(from)
    upsert(to, value)
    remove(from)
  end
end
