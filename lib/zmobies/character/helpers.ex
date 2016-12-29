defmodule Zmobies.Character.Helpers do
  alias Zmobies.{Being, Location}

  def run(proximity_stream, being = %Being{location: current_location}) do
    nearest_enemy = proximity_stream
    |> nearest_enemy(being)

    moves = case nearest_enemy do
      {enemy_location, _enemy} -> away_from(enemy_location, current_location)
      nil -> random(current_location)
    end

    {:move, moves}
  end

  def chase(proximity_stream, being = %Being{location: current_location}) do
    nearest_enemy = proximity_stream
    |> nearest_enemy(being)

    moves = case nearest_enemy do
      {enemy_location, _} -> towards(enemy_location, current_location)
      nil -> random(current_location)
    end

    {:move, moves}
  end

  @spec towards(%Location{}, %Location{}) :: [%Location{}]
  def towards(target, current) do
    all_possible_locations(current)
    |> Enum.filter(fn(location) -> distance(current, target) >= distance(location, target) end)
    |> Enum.shuffle
  end

  @spec away_from(%Location{}, %Location{}) :: [%Location{}]
  def away_from(target, current) do
    all_possible_locations(current)
    |> Enum.filter(fn(location) -> distance(current, target) <= distance(location, target) end)
    |> Enum.shuffle
  end

  @spec random(%Location{}) :: [%Location{}]
  def random(current) do
    all_possible_locations(current)
    |> Enum.shuffle
  end

  def all_possible_locations(current = %Location{x: x, y: y}) do
    all_locations  = for new_x <- (x - 1)..(x + 1), new_y <- (y - 1)..(y + 1) do
      Location.at(x: new_x, y: new_y)
    end

    all_locations -- [current]
  end

  def distance(%Location{x: target_x, y: target_y}, %Location{x: current_x, y: current_y}) do
    abs(target_x - current_x) + abs(target_y - current_y)
  end

  @spec nearest_enemy(Enumerable.t, %Being{}) :: {%Location{}, %Being{}} | nil
  def nearest_enemy(proximity_stream, being) do
    proximity_stream
    |> Stream.take(10)
    |> do_nearest_enemy(Being.type(being))
  end

  def do_nearest_enemy(stream, being_type) do
    case Enum.take(stream, 1) do
      [] -> nil
      [ring] ->
        case Enum.find(ring, & is_enemy(&1, being_type)) do
          {location, {:occupied, enemy}} -> {location, enemy}
          nil -> do_nearest_enemy(Stream.drop(stream, 1), being_type)
        end
    end
  end

  def is_enemy({_, :vacant}, _type), do: false
  def is_enemy({_, {:occupied, %Being{type: type}}}, type), do: false
  def is_enemy({_, {:occupied, %Being{}}}, _type), do: true
end
