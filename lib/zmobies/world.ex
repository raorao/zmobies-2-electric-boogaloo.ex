defmodule Zmobies.World do
  alias Zmobies.{Location, Being}

  @type bounded_lookup :: {:occupied, %Being{}} | :vacant | :out_of_bounds
  @type unbounded_lookup :: {:occupied, %Being{}} | :vacant

  def init do
    :ets.new(:world, [:set, :named_table])
  end

  defmacro out_of_bounds(x, y, x_lim, y_lim) do
    quote do: 0 >= unquote(x) or unquote(x) > unquote(x_lim) or 0 >= unquote(y) or unquote(y) > unquote(y_lim)
  end

  @spec at(%Location{}) :: unbounded_lookup
  def at(location) do
    at(location, nil)
  end

  def at(%Location{x: x, y: y}, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim),
    do: :out_of_bounds

  @spec at(%Location{}, nil | {number, number}) :: bounded_lookup
  def at(location, _limits) do
    case :ets.lookup(:world, location) do
      [{^location, being}] -> {:occupied, being}
      [] -> :vacant
    end
  end

  def insert(%Location{x: x, y: y}, _, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim),
    do: :out_of_bounds

  @spec insert(%Location{}, %Being{}, {number, number}) :: {:ok, %Being{}} | bounded_lookup
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

  @spec remove(%Location{}, {number, number}) :: :ok
  def remove(location, _limits) do
    :ets.delete(:world, location)
    :ok
  end

  @spec update(%Being{}) :: :not_found | {:ok, %Being{}}
  def update(being = %Being{location: location}) do
    case :ets.update_element(:world, location, {2, being}) do
      true -> {:ok, being}
      false -> :not_found
    end
  end

  @spec move(%Location{}, %Location{}, {number, number}) :: {:ok, %Being{}} | bounded_lookup
  def move(%Location{x: x, y: y}, %Location{x: new_x, y: new_y}, {x_lim, y_lim})
    when out_of_bounds(x, y, x_lim, y_lim)
    or out_of_bounds(new_x, new_y, x_lim, y_lim),
    do: :out_of_bounds

  def move(from, to, state) do
    {:occupied, being} = at(from, state)

    case insert(to, (%{being | :location => to}), state) do
      {:ok, being} ->
        remove(from, state)
        {:ok, being}
      {:occupied, being} ->
        {:occupied, being}
    end
  end

  @spec status() :: :empty | :ongoing | Being.character_type
  def status do
    :ets.safe_fixtable(:world, true)
    status = do_status(:world, :ets.first(:world))
    :ets.safe_fixtable(:world, false)

    status
  end

  defp do_status(_, :"$end_of_table"), do: :empty

  defp do_status(table, key) do
    case at(key) do
      {:occupied, being} -> do_status(table, key, being.type)
      :vacant -> do_status(table, :ets.next(table, key))
    end
  end

  defp do_status(table, key, target_type) do
    case :ets.next(table, key) do
      :'$end_of_table' -> target_type
      next ->
        case at(next) do
          {:occupied, %Being{type: ^target_type}} -> do_status(table, next, target_type)
          {:occupied, _} -> :ongoing
          :vacant -> do_status(table, next, target_type)
        end
    end
  end
end
