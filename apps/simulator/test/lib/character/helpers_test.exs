defmodule CharacterHelpersTest do
  use ExUnit.Case
  alias Simulator.{Proximity, WorldManager, Location, Character.Helpers}
  doctest Helpers

  describe "nearest_enemy" do
    test "returns nil if there are no nearby beings" do
      WorldManager.start_link({10,10},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_enemy(stream, human) == nil
    end

    test "returns nil if there are no nearby allies" do
      WorldManager.start_link({10,10},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      ally_location = Location.at(x: 1, y: 2)
      WorldManager.insert(ally_location, :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_enemy(stream, human) == nil
    end

    test "returns nil if the nearest enemy is too far away" do
      WorldManager.start_link({100,100},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      enemy_location = Location.at(x: 1, y: 99)
      WorldManager.insert(enemy_location, :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_enemy(stream, human) == nil
    end

    test "returns the nearest enemy" do
      WorldManager.start_link({10,10},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      near_enemy_location = Location.at(x: 3, y: 3)
      {:ok, near_enemy} = WorldManager.insert(near_enemy_location, :zombie)
      far_enemy_location = Location.at(x: 4, y: 4)
      WorldManager.insert(far_enemy_location, :zombie)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_enemy(stream, human) == {near_enemy_location, near_enemy}
    end
  end

  describe "nearest_being" do
    test "returns nil if there are no nearby beings" do
      WorldManager.start_link({10,10},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_being(stream) == nil
    end

    test "returns ally if there are no nearby being" do
      WorldManager.start_link({10,10},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      ally_location = Location.at(x: 1, y: 2)
      {:ok, ally} = WorldManager.insert(ally_location, :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_being(stream) == {ally_location, ally}
    end

    test "returns nil if the nearest being is too far away" do
      WorldManager.start_link({100,100},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      enemy_location = Location.at(x: 1, y: 99)
      WorldManager.insert(enemy_location, :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_being(stream) == nil
    end

    test "returns the nearest being" do
      WorldManager.start_link({10,10},{0,0})
      human_location = Location.at(x: 1, y: 1)
      {:ok, human} = WorldManager.insert(human_location, :human)
      near_enemy_location = Location.at(x: 3, y: 3)
      {:ok, near_enemy} = WorldManager.insert(near_enemy_location, :zombie)
      far_enemy_location = Location.at(x: 4, y: 4)
      WorldManager.insert(far_enemy_location, :zombie)

      stream = Proximity.proximity_stream(human)

      assert Helpers.nearest_being(stream) == {near_enemy_location, near_enemy}
    end
  end

  describe "visible_beings" do
    test "returns two empty arrays if there are no beings on the board" do
      WorldManager.start_link({10,10},{0,0})
      {:ok, human} = WorldManager.insert(Location.at(x: 1, y: 1), :human)

      stream = Proximity.proximity_stream(human)

      assert Helpers.visible_beings(stream, human) == {[],[]}
    end

    test "returns two arrays of beings ordered by distance" do
      WorldManager.start_link({10,10},{0,0})
      {:ok, human}   = WorldManager.insert(Location.at(x: 1, y: 1), :human)
      {:ok, human1}  = WorldManager.insert(Location.at(x: 2, y: 2), :human)
      {:ok, human2}  = WorldManager.insert(Location.at(x: 3, y: 3), :human)
      {:ok, zombie1} = WorldManager.insert(Location.at(x: 1, y: 2), :zombie)
      {:ok, zombie2} = WorldManager.insert(Location.at(x: 2, y: 3), :zombie)

      stream = Proximity.proximity_stream(human)

      assert Helpers.visible_beings(stream, human) == {[human1, human2],[zombie1, zombie2]}
    end
  end

  describe "towards" do
    test "returns a list of possible moves that do not move away from target (0 directions)" do
      WorldManager.start_link({10,10},{0,0})
      location = Location.at(x: 1, y: 1)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 1, y: 1)

      assert Helpers.towards(target_location, location) == []
    end

    test "returns a list of possible moves that do not move away from target (1 direction)" do
      WorldManager.start_link({10,10},{0,0})
      location = Location.at(x: 1, y: 1)
      WorldManager.insert(location, :human)
      target_location = Location.at(x: 1, y: 3)

      possible_moves = [
        Location.at(x: 0, y: 2),
        Location.at(x: 2, y: 2),
        Location.at(x: 1, y: 2)
      ] |> Enum.sort

      assert Helpers.towards(target_location, location) |> Enum.sort == possible_moves
    end

    test "returns a list of possible moves that do not move away from target (2 directions)" do
      WorldManager.start_link({10,10},{0,0})
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

      assert Helpers.towards(target_location, location) |> Enum.sort == possible_moves
    end
  end

  describe "away_from" do
    test "returns a list of possible moves that do not move towards target (0 directions)" do
      WorldManager.start_link({10,10},{0,0})
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

      assert Helpers.away_from(target_location, location) |> Enum.sort == possible_moves
    end

    test "returns a list of possible moves that do not move towards target (1 direction)" do
      WorldManager.start_link({10,10},{0,0})
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

      assert Helpers.away_from(target_location, location) |> Enum.sort == possible_moves
    end

    test "returns a list of possible moves that do not move towards target (2 directions)" do
      WorldManager.start_link({10,10},{0,0})
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

      assert Helpers.away_from(target_location, location) |> Enum.sort == possible_moves
    end
  end
end
