defmodule Zmobies.World do
  alias Zmobies.{Location, Being}

  def init do
    :ets.new(:world, [:set, :named_table])
  end

  defmacro out_of_bounds(x, y, x_lim, y_lim) do
    quote do: 0 >= unquote(x) or unquote(x) > unquote(x_lim) or 0 >= unquote(y) or unquote(y) > unquote(y_lim)
  end

  def at(location) do
    at(location, nil)
  end

  def at(%Location{x: x, y: y}, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim),
    do: :out_of_bounds

  def at(location, _limits) do
    case :ets.lookup(:world, location) do
      [{^location, being}] -> {:occupied, being}
      [] -> :vacant
    end
  end

  def all do
    :ets.match(:world, :'$1')
    |> List.flatten
    |> Enum.map(&elem(&1, 1))
  end

  def insert(%Location{x: x, y: y}, _, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim),
    do: :out_of_bounds

  def insert(location, being = %Being{}, limits) do
    case :ets.insert_new(:world, {location, being}) do
      true -> {:ok, being}
      false -> at(location, limits)
    end
  end

  def insert(location, type, limits) do
    being = Being.new(type, location)
    case :ets.insert_new(:world, {location, being}) do
      true -> {:ok, being}
      false -> at(location, limits)
    end
  end

  def remove(%Location{x: x, y: y}, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim),
    do: :out_of_bounds

  def remove(location, _limits) do
    case :ets.delete(:world, location) do
      true -> :ok
      false -> :vacant
    end
  end

  def move(%Location{x: x, y: y}, %Location{x: new_x, y: new_y}, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim)
    or out_of_bounds(new_x, new_y, x_lim, y_lim),
    do: :out_of_bounds

  def move(from, to, state) do
    {:occupied, being} = at(from, state)

    case insert(to, (%{being | :location => to}), state) do
      {:ok, _} -> remove(from, state)
      {:occupied, being} -> {:occupied, being}
    end
  end
end
