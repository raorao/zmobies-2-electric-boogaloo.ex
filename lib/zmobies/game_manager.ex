defmodule Zmobies.GameManager do
  use Supervisor
  alias Zmobies.{WorldManager, CharacterSupervisor, StatsManager, ConsoleInterface}

  def for_console(x: x, y: y, humans: humans, zombies: zombies) do
    Supervisor.start_link(
      __MODULE__,
      {x, y, humans, zombies, ConsoleInterface},
      name: :game_manager
    )
  end

  def stop do
    GenServer.stop(:game_manager)
  end

  def finish do
    Zmobies.CharacterSupervisor.stop_children
  end

  def init({x, y, humans, zombies, interface_module}) do
    children = [
      supervisor(CharacterSupervisor, []),
      worker(WorldManager, [{x, y}, {humans, zombies}]),
      worker(StatsManager, []),
      worker(interface_module, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
