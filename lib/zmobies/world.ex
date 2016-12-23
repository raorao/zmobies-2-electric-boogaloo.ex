defmodule Zmobies.World do
  alias Zmobies.Location

  def init do
    :ets.new(:world, [:set, :named_table, :public])
  end

  defmacro out_of_bounds(x, y, x_lim, y_lim) do
    quote do: 0 > unquote(x) or unquote(x) >= unquote(x_lim) or 0 > unquote(y) or unquote(y) >= unquote(y_lim)
  end

  def at(%Location{x: x, y: y}, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) do
    :out_of_bounds
  end

  def at(location, _limits) do
    case :ets.lookup(:world, location) do
      [{^location, value}] -> {:occupied, value}
      [] -> :vacant
    end
  end

  def insert(%Location{x: x, y: y}, _, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) do
    :out_of_bounds
  end

  def insert(location, value, limits) do
    case :ets.insert_new(:world, {location, value}) do
      true -> {:ok, value}
      false -> at(location, limits)
    end
  end

  def remove(%Location{x: x, y: y}, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) do
    :out_of_bounds
  end

  def remove(location, _limits) do
    case :ets.delete(:world, location) do
      true -> :ok
      false -> :vacant
    end
  end

  def move(%Location{x: x, y: y}, %Location{x: new_x, y: new_y}, {x_lim, y_lim}) when out_of_bounds(x, y, x_lim, y_lim) or out_of_bounds(new_x, new_y, x_lim, y_lim)   do
    :out_of_bounds
  end

  def move(from, to, state) do
    {:occupied, value} = at(from, state)

    case insert(to, value, state) do
      {:ok, ^value} -> remove(from, state)
      {:occupied, value} -> {:occupied, value}
    end
  end
end
