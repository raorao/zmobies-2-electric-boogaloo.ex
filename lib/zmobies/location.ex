defmodule Zmobies.Location do
  alias Zmobies.Location

  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def at(x: x, y: y) when x != nil and y != nil do
    %__MODULE__{x: x, y: y}
  end

  def distance(%Location{x: x1, y: y1}, %Location{x: x2, y: y2}) do
    :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
  end
end
