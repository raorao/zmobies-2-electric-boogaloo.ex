defmodule Simulator.Character.Human.StrengthInNumbers do
  alias Simulator.{Being, Proximity, Character.Helpers, Action}

  @spec act([Proximity.ring], %Being{}) :: Action.t
  def act(proximity_stream, self) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Helpers.nearest_enemy(self)

    case adjacent_enemy do
      {enemy_location, _enemy} ->
        {:attack, enemy_location}
      nil ->
        visible_beings = proximity_stream
        |> Stream.take(5)
        |> Helpers.visible_beings(self)

        moves = case visible_beings do
          {[], []} ->
            Helpers.random(self.location)
          {[nearest_human | _], []} ->
            Helpers.towards(nearest_human.location, self.location)
          {_, [nearest_zombie | _ ]} ->
            Helpers.away_from(nearest_zombie.location, self.location)
        end

        {:move, moves}
    end
  end
end
