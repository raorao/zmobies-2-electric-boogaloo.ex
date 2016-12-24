defmodule Zmobies.WorldSupervisor do
  use Supervisor
  alias Zmobies.WorldManager

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :world_supervisor)
  end

  def start_child({x,y}) do
    Supervisor.start_child(:world_supervisor, [x,y])
  end

  def stop do
    Supervisor.stop(:world_supervisor)
  end

  def init(_) do
    children = [
      worker(WorldManager, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
