defmodule ZmobiesWorldTest do
  use ExUnit.Case
  alias Zmobies.{World, Location, Being}
  doctest World

  setup do
    World.init
    :ok
  end

  test "correctly idenfies vacant spaces" do
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == :vacant
  end

  test "cannot read out of bounds area" do
    assert World.at(Location.at(x: 11, y: 1), {10, 10})  == :out_of_bounds
    assert World.at(Location.at(x: 1, y: 11), {10, 10}) == :out_of_bounds
    assert World.at(Location.at(x: -1, y: 1), {10, 10}) == :out_of_bounds
    assert World.at(Location.at(x: 1, y: -1), {10, 10}) == :out_of_bounds
  end

  test "can insert into vacant entry" do
    zombie = %Being{location: %Location{x: 1, y: 1}, type: :zombie}
    assert World.insert(Location.at(x: 1, y: 1), :zombie, {10, 10}) == {:ok, zombie}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == {:occupied, zombie}
  end

  test "cannot insert into occupied entry" do
    zombie = %Being{location: %Location{x: 1, y: 1}, type: :zombie}
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    assert World.insert(Location.at(x: 1, y: 1), :human, {10, 10}) == {:occupied, zombie}
  end

  test "cannot insert into out of bounds area" do
    assert World.insert(Location.at(x: 11, y: 1), :zombie, {10, 10}) == :out_of_bounds
  end

  test "can delete entry" do
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    World.remove Location.at(x: 1, y: 1), {10, 10}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == :vacant
  end

  test "cannot delete out of bounds" do
    assert World.remove(Location.at(x: 11, y: 1), {10, 10}) == :out_of_bounds
  end

  test "can move entry from one location to another" do
    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 1, y: 2), {10, 10}) == {:ok, %Being{location: Location.at(x: 1, y: 2), type: :zombie}}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == :vacant

    zombie = %Being{location: %Location{x: 1, y: 2}, type: :zombie}
    assert World.at(Location.at(x: 1, y: 2), {10, 10}) == {:occupied, zombie}
  end

  test "can't move entry to occupied location" do
    zombie = %Being{location: %Location{x: 1, y: 1}, type: :zombie}
    human  = %Being{location: %Location{x: 1, y: 2}, type: :human}

    World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
    World.insert Location.at(x: 1, y: 2), :human, {10, 10}
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 1, y: 2), {10, 10}) == {:occupied, human}
    assert World.at(Location.at(x: 1, y: 1), {10, 10}) == {:occupied, zombie}
    assert World.at(Location.at(x: 1, y: 2), {10, 10}) == {:occupied, human}
  end

  test "cannot move out of bounds" do
    assert World.move(Location.at(x: 1, y: 1), Location.at(x: 11, y: 1), {10, 10}) == :out_of_bounds
    assert World.move(Location.at(x: 1, y: 11), Location.at(x: 1, y: 1), {10, 10}) == :out_of_bounds
  end

  describe "status" do
    test "returns :empty if empty" do
      assert World.status == :empty
    end

    test "returns :human if only humans are on the board" do
      World.insert(%Location{x: 1, y: 1}, :human, nil)
      World.insert(%Location{x: 4, y: 4}, :human, nil)
      assert World.status == :human
    end

    test "returns :zombie if only zombies are on the board" do
      World.insert(%Location{x: 1, y: 1}, :zombie, nil)
      World.insert(%Location{x: 4, y: 4}, :zombie, nil)
      assert World.status == :zombie
    end

    test "returns :ongoing if there is a mix of characters on the board" do
      World.insert(%Location{x: 1, y: 1}, :zombie, nil)
      World.insert(%Location{x: 4, y: 4}, :human, nil)
      assert World.status == :ongoing
    end
  end

  describe "update" do
    test "returns not_found if being is not at location" do
      {:ok, being} = World.insert Location.at(x: 1, y: 1), :zombie, {10, 10}
      new_being = %{being | :location => Location.at(x: 10, y: 10)}
      assert World.update(new_being) == :not_found
      assert World.at(Location.at(x: 1, y: 1), {10, 10}) == {:occupied, being}
    end

    test "updates the being at its location" do
      {:ok, being} = World.insert Location.at(x: 1, y: 1), :human, {10, 10}

      {:ok, new_being} = Being.turn(being)
      assert World.update(new_being) == {:ok, new_being}
      assert World.at(Location.at(x: 1, y: 1), {10, 10}) == {:occupied, new_being}
    end
  end
end
