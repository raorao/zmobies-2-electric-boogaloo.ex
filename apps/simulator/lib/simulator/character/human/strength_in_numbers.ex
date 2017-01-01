defmodule Simulator.Character.Human.StrengthInNumbers do
  use Human

  alias Simulator.{Character.Helpers, Being}

  def act(proximity_stream, self, _) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Helpers.nearest_enemy(self)

    case adjacent_enemy do
      {enemy_location, _enemy} ->
        {:attack, enemy_location}
      nil ->
        nearest = proximity_stream
        |> Stream.drop(1)
        |> Stream.take(6)
        |> Helpers.nearest_being

        moves = case nearest do
          nil ->
            Helpers.random(self.location)
          {location, %Being{type: :zombie}} ->
            Helpers.away_from(location, self.location)
          {location, %Being{type: :human}} ->
            Helpers.towards(location, self.location)
        end

        {:move, moves}
    end
  end
end
