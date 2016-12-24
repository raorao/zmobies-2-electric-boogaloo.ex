defmodule Zmobies.Interface do
  alias Zmobies.{WorldSupervisor, WorldManager, Interface, Being, Location}

  def start do
    start(x: 40, y: 40, humans: 50, zombies: 30)
  end

  def start(x: x, y: y, humans: humans, zombies: zombies) do
    WorldSupervisor.start_child({x, y})

    human_messages = if humans > 0 do
      for _ <- 1..humans do
        WorldManager.place(:human)
      end
    else
      []
    end

    zombie_messages = if zombies > 0 do
       for _ <- 1..zombies do
        WorldManager.place(:zombie)
      end
    else
      []
    end

    human_messages ++ zombie_messages
  end

  def print do
    Zmobies.Presenter.to_s
    |> IO.puts
  end

  def tick do
    Zmobies.WorldManager.all
    |> Enum.map( &Task.async(Interface, :random_move, [&1]) )
    |> Enum.map(&Task.await(&1))
  end

  def random_move(being = %Being{}) do
    old = being.location
    new = Location.at(x: (Being.x(being) + additive), y: (Being.y(being) + additive))
    Zmobies.WorldManager.move(old, new)
  end

  def additive do
    :rand.uniform(3) - 2
  end

  def run do
    start
    for _ <- 1..100 do
      tick
      IEx.Helpers.clear
      print
      :timer.sleep(1000)
    end
  end

end
