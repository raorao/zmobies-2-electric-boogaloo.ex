defmodule Simulator.Character.Zombie do
  alias Simulator.{Being, Proximity, Character.Helpers, Action}

  @spec act([Proximity.ring], %Being{}) :: Action.t
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
        |> Helpers.chase_nearest_being(being)
    end
  end
end
