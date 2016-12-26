defmodule ZmobiesBeingTest do
  use ExUnit.Case
  alias Zmobies.{Being, World}
  doctest Being

  describe "proximity_stream" do
    test "returns a stream of rings" do
      World.init
      human  = Being.new(:zombie, x: 5, y: 5)
      World.insert(human.location, human, nil)
      zombie = Being.new(:human, x: 4, y: 3)
      World.insert(zombie.location, zombie, nil)

      stream = Being.proximity_stream(human)

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
end
