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

      Movement.move([], being)

      assert WorldManager.at(location) == {:occupied, being}
    end

    test "moves to first location provided if valid" do
      WorldManager.start_link(10, 10)
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      new_location = Location.at(x: 1, y: 2)

      Movement.move([new_location], being)

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

      Movement.move([bad_location, new_location], being)

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

      Movement.move([bad_location, occupied_location], being)

      assert WorldManager.at(location) == {:occupied, being}
    end
  end

  describe "nearest_enemy" do
    test "returns nil if there are no nearby beings" do
      WorldManager.start_link(10,10)
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)

      stream = Movement.proximity_stream(human)

      assert Movement.nearest_enemy(stream, human) == nil
    end

    test "returns nil if there are no nearby allies" do
      WorldManager.start_link(10,10)
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      ally_location = Location.at(x: 1, y: 2)
      WorldManager.insert(ally_location, :human)

      stream = Movement.proximity_stream(human)

      assert Movement.nearest_enemy(stream, human) == nil
    end

    test "returns nil if the nearest enemy is too far away" do
      WorldManager.start_link(100,100)
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      enemy_location = Location.at(x: 1, y: 99)
      WorldManager.insert(enemy_location, :human)

      stream = Movement.proximity_stream(human)

      assert Movement.nearest_enemy(stream, human) == nil
    end

    test "returns the nearest enemy" do
      WorldManager.start_link(10,10)
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      near_enemy_location = Location.at(x: 3, y: 3)
      {:ok, near_enemy} = WorldManager.insert(near_enemy_location, :zombie)
      far_enemy_location = Location.at(x: 4, y: 4)
      WorldManager.insert(far_enemy_location, :zombie)

      stream = Movement.proximity_stream(human)

      assert Movement.nearest_enemy(stream, human) == {near_enemy_location, near_enemy}
    end
  end

  describe "towards" do
    test "returns a list of possible moves that do not move away from target (0 directions)" do
      WorldManager.start_link(10,10)
      location = Location.at(x: 1, y: 1)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 1, y: 1)

      assert Movement.towards(target_location, location) == []
    end

    test "returns a list of possible moves that do not move away from target (1 direction)" do
      WorldManager.start_link(10,10)
      location = Location.at(x: 1, y: 1)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 1, y: 3)

      possible_moves = [
        Location.at(x: 0, y: 2),
        Location.at(x: 2, y: 2),
        Location.at(x: 1, y: 2)
      ] |> Enum.sort

      assert Movement.towards(target_location, location) |> Enum.sort == possible_moves
    end

    test "returns a list of possible moves that do not move away from target (2 directions)" do
      WorldManager.start_link(10,10)
      location = Location.at(x: 1, y: 1)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 3, y: 3)

      possible_moves = [
        Location.at(x: 0, y: 2),
        Location.at(x: 1, y: 2),
        Location.at(x: 2, y: 0),
        Location.at(x: 2, y: 1),
        Location.at(x: 2, y: 2),

      ] |> Enum.sort

      assert Movement.towards(target_location, location) |> Enum.sort == possible_moves
    end
  end

  describe "away_from" do
    test "returns a list of possible moves that do not move towards target (0 directions)" do
      WorldManager.start_link(10,10)
      location = Location.at(x: 2, y: 2)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 2, y: 2)

      possible_moves = [
        Location.at(x: 3, y: 3),
        Location.at(x: 2, y: 3),
        Location.at(x: 1, y: 3),
        Location.at(x: 3, y: 2),
        Location.at(x: 1, y: 2),
        Location.at(x: 3, y: 1),
        Location.at(x: 2, y: 1),
        Location.at(x: 1, y: 1),
      ] |> Enum.sort

      assert Movement.away_from(target_location, location) |> Enum.sort == possible_moves
    end

    test "returns a list of possible moves that do not move towards target (1 direction)" do
      WorldManager.start_link(10,10)
      location = Location.at(x: 2, y: 2)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 3, y: 2)

      possible_moves = [
        Location.at(x: 3, y: 3),
        Location.at(x: 2, y: 3),
        Location.at(x: 1, y: 3),
        Location.at(x: 1, y: 2),
        Location.at(x: 3, y: 1),
        Location.at(x: 2, y: 1),
        Location.at(x: 1, y: 1),
      ] |> Enum.sort

      assert Movement.away_from(target_location, location) |> Enum.sort == possible_moves
    end

    test "returns a list of possible moves that do not move towards target (2 directions)" do
      WorldManager.start_link(10,10)
      location = Location.at(x: 2, y: 2)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 3, y: 3)

      possible_moves = [
        Location.at(x: 1, y: 3),
        Location.at(x: 1, y: 2),
        Location.at(x: 3, y: 1),
        Location.at(x: 2, y: 1),
        Location.at(x: 1, y: 1),
      ] |> Enum.sort

      assert Movement.away_from(target_location, location) |> Enum.sort == possible_moves
    end
  end
end
