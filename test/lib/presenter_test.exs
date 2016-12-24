defmodule ZmobiesPresenterTest do
  use ExUnit.Case
  alias Zmobies.{Being, Presenter}
  doctest Presenter

  describe "to_s" do
    test "can print an empty list" do
      assert Presenter.to_s([]) == ""
    end

    test "can print a being on a one-by-one grid" do
      assert Presenter.to_s([Being.new(:zombie, x: 1, y: 1)]) == "Z"
    end

    test "can print two beings on a two-by-two grid" do
      beings = [Being.new(:zombie, x: 1, y: 1), Being.new(:human, x: 2, y: 2)]
      assert Presenter.to_s(beings) == "Z\n  H"
    end

    test "can print a large grid" do
      beings = [
        Being.new(:zombie, x: 2, y: 1),
        Being.new(:human,  x: 3, y: 1),
        Being.new(:zombie, x: 1, y: 2),
        Being.new(:zombie, x: 3, y: 2),
        Being.new(:human,  x: 4, y: 2),
        Being.new(:human,  x: 1, y: 4),
        Being.new(:zombie, x: 4, y: 4),
      ]

      assert Presenter.to_s(beings) == "  Z H\nZ   Z H\n\nH     Z"
    end
  end
end
