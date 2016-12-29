defmodule Zmobies.GameManager do
  use Supervisor
  alias Zmobies.{WorldManager, CharacterSupervisor, StatsManager, ConsoleInterface, JsonInterface}

  def for_json(x: x, y: y, humans: humans, zombies: zombies, broadcast_fn: broadcast_fn) do
    Supervisor.start_link(
      __MODULE__,
      {x, y, humans, zombies, JsonInterface, [broadcast_fn]},
      name: :game_manager
    )
  end

  def for_console(x: x, y: y, humans: humans, zombies: zombies) do
    Supervisor.start_link(
      __MODULE__,
      {x, y, humans, zombies, ConsoleInterface, []},
      name: :game_manager
    )
  end

  def stop do
    GenServer.stop(:game_manager)
  end

  def finish do
    Zmobies.CharacterSupervisor.stop_children
  end

  def init({x, y, humans, zombies, interface_module, interface_args}) do
    children = [
      supervisor(CharacterSupervisor, []),
      worker(WorldManager, [{x, y}, {humans, zombies}]),
      worker(StatsManager, []),
      worker(interface_module, interface_args)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
