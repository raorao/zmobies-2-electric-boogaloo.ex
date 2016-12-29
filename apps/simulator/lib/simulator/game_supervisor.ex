defmodule Simulator.GameSupervisor do
  use Supervisor
  alias Simulator.{GameManager, JsonInterface, ConsoleInterface}

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: :game_supervisor)
  end

  def for_json(x: x, y: y, humans: humans, zombies: zombies, broadcast_fn: broadcast_fn) do
    Supervisor.start_child(
      :game_supervisor,
      [{x, y, humans, zombies, JsonInterface, [broadcast_fn]}]
    )
  end

  def for_console(x: x, y: y, humans: humans, zombies: zombies) do
    Supervisor.start_child(
      :game_supervisor,
      [{x, y, humans, zombies, ConsoleInterface, []}]
    )
  end

  def init(:ok) do
    children = [ supervisor(GameManager, [], restart: :transient) ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
