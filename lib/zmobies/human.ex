defmodule Zmobies.Human do
  alias Zmobies.{Being, Movement, Location}

  @spec act(Enumerable.t, %Being{}) :: {:attack, %Location{}} | {:move, [%Location{}]}
  def act(proximity_stream, being) do
    {:move, run(proximity_stream, being)}
  end

  defp run(proximity_stream, being = %Being{location: current_location}) do
    nearest_enemy = proximity_stream
    |> Stream.take(5)
    |> Movement.nearest_enemy(being)

    case nearest_enemy do
      {enemy_location, _enemy} -> Movement.away_from(enemy_location, current_location)
      nil -> Movement.random(current_location)
    end
  end
end
