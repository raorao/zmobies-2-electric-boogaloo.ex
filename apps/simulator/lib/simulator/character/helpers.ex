defmodule Simulator.Character.Helpers do
  alias Simulator.{Being, Location}

  def run_from_nearest_being(proximity_stream, being = %Being{location: current_location}) do
    nearest_enemy = proximity_stream
    |> nearest_enemy(being)

    moves = case nearest_enemy do
      {enemy_location, _enemy} -> away_from(enemy_location, current_location)
      nil -> random(current_location)
    end

    {:move, moves}
  end

  def chase_nearest_being(proximity_stream, being = %Being{location: current_location}) do
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

  @spec visible_beings(Enumerable.t, %Being{}) :: {[%Being{}], [%Being{}]}
  def visible_beings(proximity_stream, %Being{type: ally_type}) do
    proximity_stream
    |> Enum.to_list
    |> List.flatten
    |> Enum.reduce({[],[]}, fn({_location, lookup}, {allies, enemies}) ->
      case lookup do
        :vacant ->
          {allies, enemies}
        {:occupied, being = %Being{type: ^ally_type}} ->
          {allies ++ [being], enemies}
        {:occupied, being} ->
          {allies, enemies ++ [being]}
      end
    end)
  end

  @spec nearest_enemy(Enumerable.t, %Being{}) :: {%Location{}, %Being{}} | nil
  def nearest_enemy(proximity_stream, being) do
    proximity_stream
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

  @spec nearest_being(Enumerable.t) :: {%Location{}, %Being{}} | nil
  def nearest_being(stream) do
    case Enum.take(stream, 1) do
      [] -> nil
      [ring] ->
        case Enum.find(ring, &is_being/1) do
          {location, {:occupied, enemy}} -> {location, enemy}
          nil -> nearest_being(Stream.drop(stream, 1))
        end
    end
  end

  def is_enemy({_, :vacant}, _type), do: false
  def is_enemy({_, {:occupied, %Being{type: type}}}, type), do: false
  def is_enemy({_, {:occupied, %Being{}}}, _type), do: true

  def is_being({_, :vacant}), do: false
  def is_being({_, {:occupied, %Being{}}}), do: true
end
