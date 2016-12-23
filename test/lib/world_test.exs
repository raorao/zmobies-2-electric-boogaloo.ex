defmodule ZmobiesWorldTest do
  use ExUnit.Case
  alias Zmobies.{World, Location}
  doctest World

  test "correctly idenfies vacant spaces" do
    World.init
    assert World.at(Location.at(x: 1, y: 1)) == :vacant
  end

  test "can insert and read entry from map" do
    World.init
    World.upsert Location.at(x: 1, y: 1), :zombie
    assert World.at(Location.at(x: 1, y: 1)) == {:occupied, :zombie}
  end

  test "can update entry from map" do
    World.init
    World.upsert Location.at(x: 1, y: 1), :zombie
    World.upsert Location.at(x: 1, y: 1), :human
    assert World.at(Location.at(x: 1, y: 1)) == {:occupied, :human}
  end

  test "can delete entry from map" do
    World.init
    World.upsert Location.at(x: 1, y: 1), :zombie
    World.remove Location.at(x: 1, y: 1)
    assert World.at(Location.at(x: 1, y: 1)) == :vacant
  end

  test "can move being from one location to another" do
    World.init
    World.upsert Location.at(x: 1, y: 1), :zombie
    World.move Location.at(x: 1, y: 1), Location.at(x: 1, y: 2)
    assert World.at(Location.at(x: 1, y: 1)) == :vacant
    assert World.at(Location.at(x: 1, y: 2)) == {:occupied, :zombie}
  end
end
