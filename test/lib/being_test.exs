defmodule BeingTest do
  use ExUnit.Case
  alias Simulator.Being
  doctest Being

  describe "attack" do
    test "humans have no effect on each other" do
      attacker = Being.new(:human, x: 5, y: 5)
      victim   = Being.new(:human, x: 6, y: 6)

      assert Being.attack(attacker, victim) == {:error, :allies}
    end

    test "zombies turn humans" do
      attacker = Being.new(:zombie, x: 5, y: 5)
      victim   = Being.new(:human, x: 6, y: 6)

      new_victim = Being.turn(victim)

      assert Being.attack(attacker, victim) |> elem(0) == :attacked
      assert Being.attack(attacker, victim) |> elem(1) |> Map.put(:speed, new_victim.speed) == new_victim
      assert Being.attack(attacker, victim) |> elem(2) == :feed
    end

    test "zombies eat other zombies" do
      attacker = Being.new(:zombie, x: 5, y: 5) |> Being.set_traits
      victim   = Being.new(:zombie, x: 6, y: 6) |> Being.set_traits

      new_victim = Being.hurt(attacker, victim)

      assert Being.attack(attacker, victim) |> elem(0) == :attacked
      assert Being.attack(attacker, victim) |> elem(1) == new_victim
      assert Being.attack(attacker, victim) |> elem(2) == :feed
    end

    test "humans hurt zombies" do
      attacker = Being.new(:human, x: 5, y: 5) |> Being.set_traits
      victim   = Being.new(:zombie, x: 6, y: 6) |> Being.set_traits

      new_victim = Being.hurt(attacker, victim)

      assert Being.attack(attacker, victim) == {:attacked, new_victim}
    end
  end
end
