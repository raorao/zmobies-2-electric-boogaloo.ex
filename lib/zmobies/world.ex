defmodule Zmobies.World do
  @doc ~S"""
    Module for managing global locations of beings.

    ## Examples

        iex> Zmobies.World.init
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
        iex> Zmobies.World.insert(Zmobies.Location.at(x: 1, y: 1), :human)
        {:ok, :human}
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        {:occupied, :human}
        iex> Zmobies.World.insert(Zmobies.Location.at(x: 1, y: 1), :zombie)
        {:occupied, :human}
        iex> Zmobies.World.move(Zmobies.Location.at(x: 1, y: 1), Zmobies.Location.at(x: 1, y: 2))
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 2))
        {:occupied, :human}
        iex> Zmobies.World.remove(Zmobies.Location.at(x: 1, y: 1))
        iex> Zmobies.World.at(Zmobies.Location.at(x: 1, y: 1))
        :vacant
    """

  alias Zmobies.Location

  def init do
    :ets.new(:world, [:set, :named_table])
  end

  def insert(%Location{} = location, value) do
    case :ets.insert_new(:world, {location, value}) do
      true -> {:ok, value}
      false -> at(location)
    end
  end

  def at(%Location{} = location) do
    case :ets.lookup(:world, location) do
      [{^location, value}] -> {:occupied, value}
      [] -> :vacant
    end
  end

  def remove(%Location{} = location) do
    case :ets.delete(:world, location) do
      true -> :ok
      false -> :vacant
    end
  end

  def move(%Location{} = from, %Location{} = to) do
    {:occupied, value} = at(from)
    case insert(to, value) do
      {:ok, ^value} -> remove(from)
      {:occupied, value} -> {:occupied, value}
    end
  end
end
