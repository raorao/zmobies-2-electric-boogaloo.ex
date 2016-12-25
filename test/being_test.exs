defmodule ZmobiesBeingTest do
  use ExUnit.Case
  alias Zmobies.{Location, Being, World}
  doctest Being

  describe "visible_locations" do
    test "returns an empty list with a range of zero" do
      being = Being.new(:zombie, x: 5, y: 5)
      assert Being.visible_locations(being, range: 0) == []
    end

    test "returns a list of locations visible given range sorted by distance" do
      being = Being.new(:zombie, x: 5, y: 5)
      locations = [
        %Zmobies.Location{x: 4, y: 5},
        %Zmobies.Location{x: 5, y: 4},
        %Zmobies.Location{x: 5, y: 6},
        %Zmobies.Location{x: 6, y: 5},
        %Zmobies.Location{x: 4, y: 4},
        %Zmobies.Location{x: 4, y: 6},
        %Zmobies.Location{x: 6, y: 4},
        %Zmobies.Location{x: 6, y: 6},
        %Zmobies.Location{x: 3, y: 5},
        %Zmobies.Location{x: 5, y: 3},
        %Zmobies.Location{x: 5, y: 7},
        %Zmobies.Location{x: 7, y: 5},
        %Zmobies.Location{x: 3, y: 4},
        %Zmobies.Location{x: 3, y: 6},
        %Zmobies.Location{x: 4, y: 3},
        %Zmobies.Location{x: 4, y: 7},
        %Zmobies.Location{x: 6, y: 3},
        %Zmobies.Location{x: 6, y: 7},
        %Zmobies.Location{x: 7, y: 4},
        %Zmobies.Location{x: 7, y: 6},
        %Zmobies.Location{x: 3, y: 3},
        %Zmobies.Location{x: 3, y: 7},
        %Zmobies.Location{x: 7, y: 3},
        %Zmobies.Location{x: 7, y: 7},
      ]
      assert Being.visible_locations(being, range: 2) == locations
    end
  end

  describe "proximity_stream" do
    test "returns an empty stream for a 0 range" do
      being = Being.new(:zombie, x: 5, y: 5)
      assert Being.proximity_stream(being, range: 0) |> Enum.to_list == []
    end

    test "returns a stream of locations ordered by distance" do
      World.init
      human  = Being.new(:zombie, x: 5, y: 5)
      World.insert(human.location, human, nil)
      zombie = Being.new(:human, x: 4, y: 6)
      World.insert(zombie.location, zombie, nil)

      sixth_element = human
      |> Being.proximity_stream(range: 2)
      |> Stream.drop(5)
      |> Enum.take(1)
      |> List.first
      |> elem(1)

      assert sixth_element == zombie
    end
  end
end
