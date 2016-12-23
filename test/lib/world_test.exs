defmodule ZmobiesWorldTest do
  use ExUnit.Case
  alias Zmobies.{World, Location}
  doctest World

  test "correctly idenfies vacant spaces" do
    World.start_link(10, 10)
    assert World.at(Location.at(x: 1, y: 1)) == :vacant
    World.stop
  end

  test "can insert into vacant entry" do
    World.start_link(10, 10)
    assert World.insert(Location.at(x: 1, y: 1), :zombie) == {:ok, :zombie}
    assert World.at(Location.at(x: 1, y: 1)) == {:occupied, :zombie}
  end

  test "cannot insert into occupied entry" do
    World.start_link(10, 10)
    World.insert Location.at(x: 1, y: 1), :zombie
    assert World.insert(Location.at(x: 1, y: 1), :human) == {:occupied, :zombie}
    World.stop
  end

  test "cannot insert into out of bounds area" do
    World.start_link(10, 10)
    assert World.at(Location.at(x: 11, y: 1))  == :out_of_bounds
    assert World.at(Location.at(x: 1, y: 11)) == :out_of_bounds
    assert World.at(Location.at(x: -1, y: 1)) == :out_of_bounds
    assert World.at(Location.at(x: 1, y: -1)) == :out_of_bounds
    assert World.insert(Location.at(x: 11, y: 1), :zombie) == :out_of_bounds
    assert World.remove(Location.at(x: 11, y: 1)) == :out_of_bounds
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 11, y: 1)) == :out_of_bounds
    # assert World.move(Location.at(x: 1, y: 11), Location.at(x: 1, y: 1)) == :out_of_bounds
    World.stop
  end

  test "can delete entry" do
    World.start_link(10, 10)
    World.insert Location.at(x: 1, y: 1), :zombie
    World.remove Location.at(x: 1, y: 1)
    assert World.at(Location.at(x: 1, y: 1)) == :vacant
    World.stop

  end

  test "can move entry from one location to another" do
    World.start_link(10, 10)
    World.insert Location.at(x: 1, y: 1), :zombie
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 1, y: 2)) == :ok
    assert World.at(Location.at(x: 1, y: 1)) == :vacant
    assert World.at(Location.at(x: 1, y: 2)) == {:occupied, :zombie}
    World.stop

  end

  test "can't move entry to occupied location" do
    World.start_link(10, 10)
    World.insert Location.at(x: 1, y: 1), :zombie
    World.insert Location.at(x: 1, y: 2), :human
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 1, y: 2)) == {:occupied, :human}
    assert World.at(Location.at(x: 1, y: 1)) == {:occupied, :zombie}
    assert World.at(Location.at(x: 1, y: 2)) == {:occupied, :human}
    World.stop
  end
end
