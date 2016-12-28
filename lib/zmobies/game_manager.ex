defmodule Zmobies.GameManager do
  use Supervisor
  alias Zmobies.{WorldManager, CharacterSupervisor, StatsManager, Interface}

  def start_link(x: x, y: y, humans: humans, zombies: zombies) do
    Supervisor.start_link(__MODULE__, {x, y, humans, zombies}, name: :world_supervisor)
  end

  def finish do
    Zmobies.CharacterSupervisor.stop_children
  end

  def init({x, y, humans, zombies}) do
    children = [
      supervisor(CharacterSupervisor, []),
      worker(WorldManager, [{x, y}, {humans, zombies}]),
      worker(StatsManager, []),
      worker(Interface, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
