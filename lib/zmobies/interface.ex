defmodule Zmobies.Interface do
  alias Zmobies.{WorldSupervisor, WorldManager, Human, GameManager, Zombie}

  def start do
    start(x: 40, y: 40, humans: 50, zombies: 30)
  end

  def start(x: x, y: y, humans: humans, zombies: zombies) do
    WorldSupervisor.start_child({x, y})
    GameManager.start_link

    human_messages = if humans > 0 do
      for _ <- 1..humans do
        case WorldManager.place(:human) do
          {:ok, being} -> Human.start_link(being)
          {:occupied, _} -> WorldManager.place(:human)
        end
      end
    else
      []
    end

    zombie_messages = if zombies > 0 do
       for _ <- 1..zombies do
        case WorldManager.place(:zombie) do
          {:ok, being} -> Zombie.start_link(being)
          {:occupied, _} -> WorldManager.place(:zombie)
        end
      end
    else
      []
    end

    human_messages ++ zombie_messages
  end

  def run do
    start
    for _ <- 1..100 do
      new_board =  Zmobies.Presenter.to_s
      IEx.Helpers.clear
      IO.puts new_board
      :timer.sleep(100)
    end
  end

end
