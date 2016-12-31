defmodule ActionTest do
  use ExUnit.Case
  alias Simulator.{Action, WorldManager, Location}
  doctest Action

  describe "move" do
    test "does not move given an empty list" do
      WorldManager.start_link({10,10},{0,0})
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)

      Action.move([], being)

      assert WorldManager.at(location) == {:occupied, being}
    end

    test "moves to first location provided if valid" do
      WorldManager.start_link({10,10},{0,0})
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      new_location = Location.at(x: 1, y: 2)

      Action.move([new_location], being)

      moved_being = %{being | :location => new_location }

      assert WorldManager.at(location) == :vacant
      assert WorldManager.at(new_location) == {:occupied, moved_being}
    end

    test "moves to second location provided if first is invalid" do
      WorldManager.start_link({10,10},{0,0})
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      bad_location = Location.at(x: -1, y: -1)
      new_location = Location.at(x: 1, y: 2)

      Action.move([bad_location, new_location], being)

      moved_being = %{being | :location => new_location }

      assert WorldManager.at(location) == :vacant
      assert WorldManager.at(new_location) == {:occupied, moved_being}
    end

    test "does not move if all locations are invalid" do
      WorldManager.start_link({10,10},{0,0})
      location = Location.at(x: 1, y: 1)
      {:ok, being} = WorldManager.insert(location, :human)
      bad_location = Location.at(x: -1, y: -1)
      occupied_location = Location.at(x: 1, y: 2)
      WorldManager.insert(occupied_location, :human)

      Action.move([bad_location, occupied_location], being)

      assert WorldManager.at(location) == {:occupied, being}
    end
  end

  describe "attack" do
    test "successfully attacks at a given location" do
      WorldManager.start_link({10,10},{0,0})

      location = Location.at(x: 1, y: 1)
      {:ok, attacker} = WorldManager.insert(location, :zombie)
      victim_location = Location.at(x: 1, y: 2)
      {:ok, victim} = WorldManager.insert(victim_location, :human)

      resolve_fn = fn(attacker_being, victim_being) ->
        assert attacker_being == attacker
        assert victim_being == victim

        send self, :resolved_attack
      end

      assert Action.attack(attacker, victim_location, resolve_fn) == attacker

      assert_receive :resolved_attack
    end

    test "unsuccessfully attacks at a given location" do
      WorldManager.start_link({10,10},{0,0})

      location = Location.at(x: 1, y: 1)
      {:ok, attacker} = WorldManager.insert(location, :zombie)
      victim_location = Location.at(x: 1, y: 2)
      {:ok, victim} = WorldManager.insert(victim_location, :human)

      resolve_fn = fn(_, _) ->
        send self, :resolved_attack
      end

      assert Action.attack(attacker, Location.at(x: 2, y: 2), resolve_fn) == attacker

      refute_receive :resolved_attack
    end
  end
end
