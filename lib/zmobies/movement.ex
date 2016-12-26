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

  def move([], being), do: being.location

  def move([ new_location | backups ], being) do
    case WorldManager.move(being.location, new_location) do
      {:ok, moved_being} -> moved_being
      _ -> move(backups, being)
    end
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
