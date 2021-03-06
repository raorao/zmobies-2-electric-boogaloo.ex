defmodule Simulator.Proximity do
  alias Simulator.{Location, WorldManager, World, Being}

  @type ring :: { %Location{}, World.bounded_lookup }

  # not sure how to describe streams with dialyzer :sweatsmile:
  # @spec proximity_stream(%Being{}) :: Stream.t(ring)
  def proximity_stream(being = %Being{}) do
    Stream.unfold({1, being.location}, &next_ring/1) |> Stream.take(10)
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
end
