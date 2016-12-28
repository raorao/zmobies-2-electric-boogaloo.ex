defmodule Zmobies.CharacterSupervisor do
  use Supervisor
  alias Zmobies.Character

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :character_supervisor)
  end

  def start_child(being) do
    Supervisor.start_child(:character_supervisor, [being])
  end

  def stop do
    Supervisor.stop(:character_supervisor)
  end

  def init(_) do
    children = [
      worker(Character, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
