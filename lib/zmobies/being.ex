defmodule Zmobies.Being do
  @enforce_keys [:location, :type]
  defstruct [:location, :type, :uuid]
  alias Zmobies.{Location, Being}

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

  def visible_locations(_being, range: 0), do: []

  def visible_locations(%Being{location: current_location}, range: range) do
    %Location{x: current_x, y: current_y} = current_location
    x_range = (current_x - range)..(current_x + range)
    y_range = (current_y - range)..(current_y + range)

    (for x <- x_range, y <-  y_range, do: Location.at(x: x, y: y))
    |> Enum.sort_by(fn(location) -> Location.distance(current_location, location) end)
    |> Enum.drop(1)
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
