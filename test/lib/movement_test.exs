defmodule MovementTest do
  use ExUnit.Case
  alias Zmobies.{Being, World, Movement, WorldManager, Location}
  doctest Movement

  describe "proximity_stream" do
    test "returns a stream of rings" do
      World.init
      human  = Being.new(:zombie, x: 5, y: 5)
      World.insert(human.location, human, nil)
      zombie = Being.new(:human, x: 4, y: 3)
      World.insert(zombie.location, zombie, nil)

      stream = Movement.proximity_stream(human)

      first_ring = stream
      |> Enum.take(1)
      |> List.first
      |> Enum.reject(fn({_, lookup}) -> lookup == :vacant end)

      second_ring = stream
      |> Stream.drop(1)
      |> Enum.take(1)
      |> List.first
      |> Enum.reject(fn({_, lookup}) -> lookup == :vacant end)

      assert first_ring == []
      assert second_ring == [{zombie.location, {:occupied, zombie}}]
    end
  end

  describe "move" do
    test "does not move given an empty list" do
      WorldManager.start_link(10, 10)
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)

      Movement.move(being, [])

      assert WorldManager.at(location) == {:occupied, being}
    end

    test "moves to first location provided if valid" do
      WorldManager.start_link(10, 10)
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      new_location = Location.at(x: 1, y: 2)

      Movement.move(being, [new_location])

      moved_being = %{being | :location => new_location }

      assert WorldManager.at(location) == :vacant
      assert WorldManager.at(new_location) == {:occupied, moved_being}
    end

    test "moves to second location provided if first is invalid" do
      WorldManager.start_link(10, 10)
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      bad_location = Location.at(x: -1, y: -1)
      new_location = Location.at(x: 1, y: 2)

      Movement.move(being, [bad_location, new_location])

      moved_being = %{being | :location => new_location }

      assert WorldManager.at(location) == :vacant
      assert WorldManager.at(new_location) == {:occupied, moved_being}
    end

    test "does not move if all locations are invalid" do
      WorldManager.start_link(10, 10)
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      bad_location = Location.at(x: -1, y: -1)
      occupied_location = Location.at(x: 1, y: 2)
      WorldManager.insert(occupied_location, :human)

      Movement.move(being, [bad_location, occupied_location])

      assert WorldManager.at(location) == {:occupied, being}
    end
  end
end
