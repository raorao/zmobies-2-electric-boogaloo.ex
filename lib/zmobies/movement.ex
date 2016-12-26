defmodule Zmobies.Movement do
  alias Zmobies.{Location, WorldManager, Being}

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

  def move(being, []), do: being.location

  def move(being, [ new_location | backups ]) do
    case WorldManager.move(being.location, new_location) do
      :ok -> new_location
      _ -> move(being, backups)
    end
  end
end
