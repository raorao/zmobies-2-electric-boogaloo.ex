defmodule Simulator.Action do
  alias Simulator.{WorldManager, Location, Being, Character}

  @type t :: {:attack, %Location{}} | {:move, [%Location{}]} | {:talk, [%Location{}], any()}

  def move([], being), do: being

  @spec move([%Location{}], %Being{}) :: %Being{}
  def move([ new_location | backups ], being) do
    case WorldManager.move(being.location, new_location) do
      {:ok, moved_being} -> moved_being
      _ -> move(backups, being)
    end
  end

  @spec attack(%Being{}, %Location{}, (%Being{}, %Being{} -> %Being{})) :: %Being{}
  def attack(attacker, location, resolve_attack_fn \\ &Character.resolve_attack/2) do
    case WorldManager.at(location) do
      {:occupied, victim} ->
        resolve_attack_fn.(attacker, victim)
      :vacant -> nil
    end

    attacker
  end

  @spec talk(
    %Being{},
    [%Location{}],
    any(),
    (%Being{}, %Being{}, any() -> %Being{}))
    :: %Being{}
  def talk(speaker, locations, message, resolve_fn \\ &Character.resolve_talk/3) do
    Enum.each(locations, fn (location) ->
      case WorldManager.at(location) do
        {:occupied, listener} -> resolve_fn.(speaker, listener, message)
        :vacant -> nil
      end
    end)

    speaker
  end
end
