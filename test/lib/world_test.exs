defmodule ZmobiesWorldTest do
  use ExUnit.Case
  alias Zmobies.{World, Location}
  doctest World

  test "correctly idenfies vacant spaces" do
    World.init
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == :vacant
  end

  test "can insert into vacant entry" do
    World.init
    assert World.insert(Location.at(x: 1, y: 1), :zombie, {10, 10}) == {:ok, :zombie}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == {:occupied, :zombie}
  end

  test "cannot insert into occupied entry" do
    World.init
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    assert World.insert(Location.at(x: 1, y: 1), :human, {10, 10}) == {:occupied, :zombie}
  end

  test "cannot insert into out of bounds area" do
    World.init
    assert World.at(Location.at(x: 11, y: 1), {10, 10})  == :out_of_bounds
    assert World.at(Location.at(x: 1, y: 11), {10, 10}) == :out_of_bounds
    assert World.at(Location.at(x: -1, y: 1), {10, 10}) == :out_of_bounds
    assert World.at(Location.at(x: 1, y: -1), {10, 10}) == :out_of_bounds
    assert World.insert(Location.at(x: 11, y: 1), :zombie, {10, 10}) == :out_of_bounds
    assert World.remove(Location.at(x: 11, y: 1), {10, 10}) == :out_of_bounds
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 11, y: 1), {10, 10}) == :out_of_bounds
    assert World.move(Location.at(x: 1, y: 11), Location.at(x: 1, y: 1), {10, 10}) == :out_of_bounds
  end

  test "can delete entry" do
    World.init
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    World.remove Location.at(x: 1, y: 1), {10, 10}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == :vacant
  end

  test "can move entry from one location to another" do
    World.init
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 1, y: 2), {10, 10}) == :ok
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == :vacant
    assert World.at(Location.at(x: 1, y: 2), {10, 10}) == {:occupied, :zombie}
  end

  test "can't move entry to occupied location" do
    World.init
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    World.insert Location.at(x: 1, y: 2), :human, {10, 10}
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 1, y: 2), {10, 10}) == {:occupied, :human}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == {:occupied, :zombie}
    assert World.at(Location.at(x: 1, y: 2), {10, 10}) == {:occupied, :human}
  end
end
