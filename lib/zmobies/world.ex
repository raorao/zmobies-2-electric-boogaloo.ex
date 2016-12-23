defmodule Zmobies.World do
  use GenServer
  @doc ~S"""
    Module for managing global locations of beings.

    ## Examples

        iex> Zmobies.World.start_link(10, 10)
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

  def start_link(x_lim, y_lim) do
    :ets.new(:world, [:set, :named_table, :public])

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
    {:reply, get(location, state), state}
  end

  def handle_call({:insert, location, value}, _, state) do
    {:reply, create(location, value, state), state}
  end

  def handle_call({:remove, location}, _, state) do
    {:reply, delete(location, state), state}
  end

  def handle_call({:move, from, to}, _, state) do
    {:reply, update(from, to, state), state}
  end

  defmacro out_of_bounds(x, y, x_lim, y_lim) do
    quote do: 0 > unquote(x) or unquote(x) >= unquote(x_lim) or 0 > unquote(y) or unquote(y) >= unquote(y_lim)
  end

  defp get(%Location{x: x, y: y}, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) do
    :out_of_bounds
  end

  defp get(location, _limits) do
    case :ets.lookup(:world, location) do
      [{^location, value}] -> {:occupied, value}
      [] -> :vacant
    end
  end

  defp create(%Location{x: x, y: y}, _, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) do
    :out_of_bounds
  end

  defp create(location, value, limits) do
    case :ets.insert_new(:world, {location, value}) do
      true -> {:ok, value}
      false -> get(location, limits)
    end
  end

  defp delete(%Location{x: x, y: y}, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) do
    :out_of_bounds
  end

  defp delete(location, _limits) do
    case :ets.delete(:world, location) do
      true -> :ok
      false -> :vacant
    end
  end

  defp update(%Location{x: x, y: y}, %Location{x: new_x, y: new_y}, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) or out_of_bounds(new_x, new_y, x_lim, y_lim)   do
    :out_of_bounds
  end

  defp update(from, to, state) do
    {:occupied, value} = get(from, state)

    case create(to, value, state) do
      {:ok, ^value} -> delete(from, state)
      {:occupied, value} -> {:occupied, value}
    end
  end
end
