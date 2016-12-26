defmodule Zmobies.Being do
  @enforce_keys [:location, :type]
  defstruct [:location, :type, :uuid]
  alias Zmobies.{Location, Being, WorldManager}

  def new(type, x: x, y: y) when x != nil and y != nil do
    %__MODULE__{location: Location.at(x: x, y: y), type: type}
  end

  def new(type, location = %Location{}) do
    %__MODULE__{location: location, type: type}
  end

  def set_uuid(being = %Being{}) do
    %{ being | :uuid => UUID.uuid1() }
  end

  def x(%Being{location: %Location{x: x}}), do: x
  def y(%Being{location: %Location{y: y}}), do: y

  def type(%Being{type: type}), do: type

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

  defimpl String.Chars, for: Zmobies.Being do
    def to_string(%{type: type}) do
      case type do
        :zombie -> "Z"
        :human  -> "H"
      end
    end
  end
end
