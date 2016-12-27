defmodule Zmobies.Interface do
  alias Zmobies.{WorldSupervisor, WorldManager, GameManager, Character}

  def start do
    start(x: 10, y: 10, humans: 20, zombies: 3)
  end

  def start(x: x, y: y, humans: humans, zombies: zombies) do
    WorldSupervisor.start_child({x, y})
    GameManager.start_link

    human_messages = if humans > 0 do
      for _ <- 1..humans do
        case WorldManager.place(:human) do
          {:ok, being} -> Character.start_link(being)
          {:occupied, _} -> WorldManager.place(:human)
        end
      end
    else
      []
    end

    zombie_messages = if zombies > 0 do
       for _ <- 1..zombies do
        case WorldManager.place(:zombie) do
          {:ok, being} -> Character.start_link(being)
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
    do_run
  end

  def print do
    new_board =  Zmobies.Presenter.to_s
    IEx.Helpers.clear
    IO.puts new_board
  end

  def do_run do
    print
    :timer.sleep(100)
    do_run
  end
end
