defmodule JsonTest do
  use ExUnit.Case
  alias Simulator.{WorldManager, Location, Interface.Json}
  doctest Json

  describe "snapshot" do
    test "for an empty board, returns an empty array" do
      WorldManager.start_link({10, 10}, {0, 0})
      assert Json.snapshot == %{}
    end

    test "returns json representation of board" do
      WorldManager.start_link({10, 10}, {0, 0})
      WorldManager.insert(Location.at(x: 1, y: 1), :zombie)
      WorldManager.insert(Location.at(x: 1, y: 2), :human)

      as_json = %{
        "1,1" => %{x: 1, y: 1, type: "zombie", uuid: nil, health: nil},
        "1,2" => %{x: 1, y: 2, type: "human", uuid: nil, health: nil},
      }

      assert Json.snapshot |> Enum.sort == as_json |> Enum.sort
    end
  end
end
