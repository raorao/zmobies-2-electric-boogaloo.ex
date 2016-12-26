defmodule Zmobies.Action do
  alias Zmobies.{WorldManager, Location, Being}

  def move([], being), do: being

  @spec move([%Location{}], %Being{}) :: %Being{}
  def move([ new_location | backups ], being) do
    case WorldManager.move(being.location, new_location) do
      {:ok, moved_being} -> moved_being
      _ -> move(backups, being)
    end
  end

  @spec move(%Being{}, %Location{}) :: %Being{}
  def attack(attacker, location) do
    case WorldManager.at(location) do
      {:occupied, victim} -> attack(attacker, victim.location)
      :vacant -> nil
    end

    attacker
  end
end
