defmodule Zmobies.Movement do
  alias Zmobies.{Location, WorldManager, Being, Zombie}

  def proximity_stream(being = %Being{}) do
    Stream.unfold({1, being.location}, &next_ring/1)
  end

  defp next_ring({range, location = %Location{x: current_x, y: current_y}}) do
    top = for x <- (current_x - range)..(current_x + range) do
      Location.at x: x, y: (current_y + range)
    end

    bottom = for x <- (current_x - range)..(current_x + range) do
      Location.at x: x, y: (current_y - range)
    end

    left = for y <- (current_y - (range - 1))..(current_y + (range - 1)) do
      Location.at x: (current_x - range), y: y
    end

    right = for y <- (current_y - (range - 1))..(current_y + (range - 1)) do
      Location.at x: (current_x + range), y: y
    end

    ring = (top ++ bottom ++ left ++ right)
    |> Enum.shuffle
    |> Enum.map(& {&1, WorldManager.at(&1)})

    {ring, {range + 1, location}}
  end

  def towards(target, current) do
    all_possible_locations(current)
    |> Enum.filter(fn(location) -> distance(current, target) >= distance(location, target) end)
    |> Enum.shuffle
  end

  def away_from(target, current) do
    all_possible_locations(current)
    |> Enum.filter(fn(location) -> distance(current, target) <= distance(location, target) end)
    |> Enum.shuffle
  end

  def random(current) do
    all_possible_locations(current)
    |> Enum.shuffle
  end

  defp all_possible_locations(current = %Location{x: x, y: y}) do
    all_locations  = for new_x <- (x - 1)..(x + 1), new_y <- (y - 1)..(y + 1) do
      Location.at(x: new_x, y: new_y)
    end

    all_locations -- [current]
  end

  defp distance(%Location{x: target_x, y: target_y}, %Location{x: current_x, y: current_y}) do
    abs(target_x - current_x) + abs(target_y - current_y)
  end

  def nearest_enemy(proximity_stream, being) do
    proximity_stream
    |> Stream.take(10)
    |> do_nearest_enemy(Being.type(being))
  end

  defp do_nearest_enemy(stream, being_type) do
    case Enum.take(stream, 1) do
      [] -> nil
      [ring] ->
        case Enum.find(ring, & is_enemy(&1, being_type)) do
          {location, {:occupied, enemy}} -> {location, enemy}
          nil -> do_nearest_enemy(Stream.drop(stream, 1), being_type)
        end
    end
  end

  defp is_enemy({_, :vacant}, _type), do: false
  defp is_enemy({_, {:occupied, %Being{type: type}}}, type), do: false
  defp is_enemy({_, {:occupied, %Being{}}}, _type), do: true
end
