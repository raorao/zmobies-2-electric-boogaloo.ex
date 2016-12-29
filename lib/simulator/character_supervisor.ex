defmodule Simulator.CharacterSupervisor do
  use Supervisor
  alias Simulator.Character

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :character_supervisor)
  end

  def start_child(being) do
    Supervisor.start_child(:character_supervisor, [being])
  end

  def stop_children do
    Supervisor.which_children(:character_supervisor)
    |> Enum.map(& elem(&1, 1))
    |> Enum.map(& Supervisor.terminate_child(:character_supervisor, &1))
  end

  def init(_) do
    children = [
      worker(Character, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
