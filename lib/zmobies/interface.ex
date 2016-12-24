defmodule Zmobies.Interface do
  alias Zmobies.{WorldSupervisor, WorldManager}

  def start do
    start(x: 50, y: 50, humans: 500, zombies: 10)
  end

  def start(x: x, y: y, humans: humans, zombies: zombies) do
    WorldSupervisor.start_child({x, y})

    human_messages = for _ <- 1..humans do
      WorldManager.insert_random(:human)
    end

    zombie_messages = for _ <- 1..zombies do
      WorldManager.insert_random(:zombie)
    end

    human_messages ++ zombie_messages
  end

  def print do
    Zmobies.WorldManager.all
    |> Zmobies.Presenter.to_s
    |> IO.puts
  end
end
