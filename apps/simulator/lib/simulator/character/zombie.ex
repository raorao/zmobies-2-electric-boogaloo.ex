defmodule Zombies.Character.Zombie do
  alias Simulator.{Being, Movement, Character.Helpers}

  @spec act([Movement.ring], %Being{}) :: Movement.t
  def act(proximity_stream, being) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Helpers.nearest_enemy(being)

    case adjacent_enemy do
      {enemy_location, _enemy} -> {:attack, enemy_location}
      nil ->
        proximity_stream
        |> Stream.drop(1)
        |> Stream.take(2)
        |> Helpers.chase(being)
    end
  end
end
