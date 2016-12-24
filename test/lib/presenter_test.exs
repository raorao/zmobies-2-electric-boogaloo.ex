defmodule ZmobiesPresenterTest do
  use ExUnit.Case
  alias Zmobies.{Being, Presenter, World}
  doctest Presenter

  describe "to_s" do
    test "can print an empty list" do
      World.init
      assert Presenter.to_s == ""
    end

    test "can print a being on a one-by-one grid" do
      World.init
      beings = [Being.new(:zombie, x: 1, y: 1)]
      beings
      |> Enum.map(fn(being) -> World.insert(being.location, being.type, nil) end)
      assert Presenter.to_s == "Z"
    end

    test "can print two beings on a two-by-two grid" do
      World.init
      beings = [Being.new(:zombie, x: 1, y: 1), Being.new(:human, x: 2, y: 2)]
      beings
      |> Enum.map(fn(being) -> World.insert(being.location, being.type, nil) end)
      assert Presenter.to_s == "Z\n  H"

    end

    test "can print a large grid" do
      World.init
      beings = [
        Being.new(:zombie, x: 2, y: 1),
        Being.new(:human,  x: 3, y: 1),
        Being.new(:zombie, x: 1, y: 2),
        Being.new(:zombie, x: 3, y: 2),
        Being.new(:human,  x: 4, y: 2),
        Being.new(:human,  x: 1, y: 4),
        Being.new(:zombie, x: 4, y: 4),
      ]

      beings
      |> Enum.map(fn(being) -> World.insert(being.location, being.type, nil) end)

      assert Presenter.to_s == "  Z H\nZ   Z H\n\nH     Z"
    end
  end
end
