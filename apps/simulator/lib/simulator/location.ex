defmodule Simulator.Location do
  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def at(x: x, y: y) when x != nil and y != nil do
    %__MODULE__{x: x, y: y}
  end
end
