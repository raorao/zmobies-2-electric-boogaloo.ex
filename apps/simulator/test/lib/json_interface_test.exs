defmodule JsonInterfaceTest do
  use ExUnit.Case
  alias Simulator.{WorldManager, Location, JsonInterface}
  doctest JsonInterface

  describe "snapshot" do
    test "for an empty board, returns an empty array" do
      WorldManager.start_link({10, 10}, {0, 0})
      assert JsonInterface.snapshot == []
    end

    test "returns json representation of board" do
      WorldManager.start_link({10, 10}, {0, 0})
      WorldManager.insert(Location.at(x: 1, y: 1), :zombie)
      WorldManager.insert(Location.at(x: 1, y: 2), :human)

      as_json = [
        %{x: 1, y: 1, type: "zombie", uuid: nil},
        %{x: 1, y: 2, type: "human", uuid: nil},
      ]

      assert JsonInterface.snapshot |> Enum.sort == as_json |> Enum.sort
    end
  end
end
