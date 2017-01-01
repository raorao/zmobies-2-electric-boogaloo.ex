defmodule Simulator.Character.Human.FightOrFlight do
  alias Simulator.{Being, Proximity, Character.Helpers, Action}

  @spec act([Proximity.ring], %Being{}, any()) :: Action.t | {Action.t, any()}
  def act(proximity_stream, self, _) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Helpers.nearest_enemy(self)

    case adjacent_enemy do
      {enemy_location, _enemy} -> {:attack, enemy_location}
      nil ->
        proximity_stream
        |> Stream.drop(1)
        |> Stream.take(6)
        |> Helpers.run_from_nearest_being(self)
    end
  end
end
