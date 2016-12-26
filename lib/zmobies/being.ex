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

  defimpl String.Chars, for: Zmobies.Being do
    def to_string(%{type: type}) do
      case type do
        :zombie -> "Z"
        :human  -> "H"
      end
    end
  end
end
