defmodule Simulator.GameSupervisor do
  use Supervisor
  alias Simulator.{Game, Interface}

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: :game_supervisor)
  end

  def for_json(
    x: x,
    y: y,
    humans: humans,
    zombies: zombies,
    broadcast_fn: broadcast_fn,
    strategy: strategy
  ) do
    Supervisor.start_child(
      :game_supervisor,
      [{x, y, humans, zombies, Interface.Json, [broadcast_fn], strategy}]
    )
  end

  def for_console(x: x, y: y, humans: humans, zombies: zombies, strategy: strategy) do
    Supervisor.start_child(
      :game_supervisor,
      [{x, y, humans, zombies, Interface.Console, [], strategy}]
    )
  end

  def to_file(x: x, y: y, humans: humans, zombies: zombies, strategy: strategy) do
    Supervisor.start_child(
      :game_supervisor,
      [{x, y, humans, zombies, Interface.FlatFileGenerator, [], strategy}]
    )
  end

  def from_file(filename, broadcast_fn) do
    Supervisor.start_child(
      :game_supervisor,
      [{filename, broadcast_fn}]
    )
  end

  def init(:ok) do
    children = [ supervisor(Game, [], restart: :transient) ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
