defmodule Simulator.Character.Human.DontLookBack do
  use Human

  alias Simulator.{Character.Helpers}

  def initial_state(_), do: :watching

  def act(proximity_stream, self, custom_state) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Helpers.nearest_enemy(self)

    case adjacent_enemy do
      {enemy_location, _enemy} ->
        { {:attack, enemy_location}, custom_state }
      nil ->
        {moves, new_custom_state} = case custom_state do
          {:running, from, 0} ->
            {
             Helpers.away_from(from, self.location),
              :watching
            }
          {:running, from, count} ->
            {
              Helpers.away_from(from, self.location),
              {:running, from, count - 1}
            }
          :watching ->
            nearest_enemy = proximity_stream
            |> Stream.drop(1)
            |> Stream.take(6)
            |> Helpers.nearest_enemy(self)

            case nearest_enemy do
              {enemy_location, _} ->
                {
                  Helpers.away_from(enemy_location, self.location),
                  {:running, enemy_location, 3}
                }
              nil ->
                {
                  Helpers.random(self.location),
                  :watching
                }
            end
        end

        { {:move, moves}, new_custom_state }
    end
  end
end
