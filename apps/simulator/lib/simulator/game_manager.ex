defmodule Simulator.GameManager do
  use Supervisor
  alias Simulator.{WorldManager, CharacterSupervisor, StatsManager}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: :game_manager)
  end

  def stop do
    GenServer.stop(:game_manager)
  end

  def finish do
    Simulator.CharacterSupervisor.stop_children
  end

  def init({x, y, humans, zombies, interface_module, interface_args, strategy}) do
    children = [
      supervisor(CharacterSupervisor, [strategy]),
      worker(WorldManager, [{x, y}, {humans, zombies}]),
      worker(StatsManager, []),
      worker(interface_module, interface_args),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
