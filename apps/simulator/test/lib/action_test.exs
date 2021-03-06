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
      WorldManager.insert(victim_location, :human)

      resolve_fn = fn(_, _) ->
        send self, :resolved_attack
      end

      assert Action.attack(attacker, Location.at(x: 2, y: 2), resolve_fn) == attacker

      refute_receive :resolved_attack
    end
  end

  describe "talk" do
    test "communicates to all given locations if valid" do
      WorldManager.start_link({10,10},{0,0})

      location = Location.at(x: 2, y: 2)
      {:ok, speaker} = WorldManager.insert(location, :human)
      first_listener_location = Location.at(x: 1, y: 2)
      {:ok, first_listener} = WorldManager.insert(first_listener_location, :human)
      second_listener_location = Location.at(x: 2, y: 1)
      {:ok, second_listener} = WorldManager.insert(second_listener_location, :human)
      third_listener_location = Location.at(x: 1, y: 1)
      {:ok, third_listener} = WorldManager.insert(third_listener_location, :human)
      bad_listener_location = Location.at(x: 3, y: 3)

      message = {:run!, Location.at(x: 1, y: 1)}

      resolve_fn = fn(^speaker, listener, ^message) ->
        cond do
          listener == first_listener ->
            send self, :resolved_talk_for_first_listener
          listener == second_listener ->
            send self, :resolved_talk_for_second_listener
          listener == third_listener ->
            send self, :resolved_talk_for_third_listener
        end
      end

      assert Action.talk(
        speaker,
        [first_listener_location, second_listener_location, bad_listener_location],
        message,
        resolve_fn
      ) == speaker

      assert_receive :resolved_talk_for_first_listener
      assert_receive :resolved_talk_for_second_listener
      refute_receive :resolved_talk_for_third_listener
    end
  end
end
