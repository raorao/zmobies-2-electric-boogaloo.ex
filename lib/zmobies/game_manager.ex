defmodule Zmobies.GameManager do
  use Supervisor
  alias Zmobies.{WorldManager, CharacterSupervisor, StatsManager, Interface}

  def start_link(x: x, y: y, humans: humans, zombies: zombies) do
    Supervisor.start_link(__MODULE__, {x, y, humans, zombies}, name: :world_supervisor)
  end

  def start_link do
    start_link(x: 40, y: 40, humans: 400, zombies: 15)
  end

  def finish do
    Supervisor.terminate_child(:world_supervisor, :character_supervisor)
  end

  def init({x, y, humans, zombies}) do
    children = [
      supervisor(CharacterSupervisor, []),
      worker(WorldManager, [{x, y}, {humans, zombies}], restart: :transient),
      worker(StatsManager, [], restart: :transient),
      worker(Interface, [], restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
