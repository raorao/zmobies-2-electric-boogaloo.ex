defmodule ZmobiesBeingTest do
  use ExUnit.Case
  alias Zmobies.{Location, Being}
  doctest Being

  describe "neighbors" do
    test "returns an empty list with a range of zero" do
      being = Being.new(:zombie, x: 5, y: 5)
      assert Being.neighbors(being, range: 0) == []
    end

    test "returns a list of locations visible given range" do
      being = Being.new(:zombie, x: 5, y: 5)
      locations = [
        Location.at(x: 3, y: 3),
        Location.at(x: 3, y: 4),
        Location.at(x: 3, y: 5),
        Location.at(x: 3, y: 6),
        Location.at(x: 3, y: 7),
        Location.at(x: 4, y: 3),
        Location.at(x: 4, y: 4),
        Location.at(x: 4, y: 5),
        Location.at(x: 4, y: 6),
        Location.at(x: 4, y: 7),
        Location.at(x: 5, y: 3),
        Location.at(x: 5, y: 4),
        Location.at(x: 5, y: 6),
        Location.at(x: 5, y: 7),
        Location.at(x: 6, y: 3),
        Location.at(x: 6, y: 4),
        Location.at(x: 6, y: 5),
        Location.at(x: 6, y: 6),
        Location.at(x: 6, y: 7),
        Location.at(x: 7, y: 3),
        Location.at(x: 7, y: 4),
        Location.at(x: 7, y: 5),
        Location.at(x: 7, y: 6),
        Location.at(x: 7, y: 7),
      ]
      assert Being.neighbors(being, range: 2) == locations
    end
  end
end
