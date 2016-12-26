defmodule Zmobies.Zombie do
  alias Zmobies.{Being, Movement}

  def act(proximity_stream, being) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Movement.nearest_enemy(being)

    case adjacent_enemy do
      {enemy_location, _enemy} ->
        {:attack, enemy_location}
      nil -> {:move, chase(proximity_stream, being)}
    end
  end

  defp chase(proximity_stream, being = %Being{location: current_location}) do
    nearest_enemy = proximity_stream
    |> Stream.drop(1)
    |> Stream.take(2)
    |> Movement.nearest_enemy(being)

    case nearest_enemy do
      {enemy_location, _} -> Movement.away_from(enemy_location, current_location)
      nil -> Movement.random(current_location)
    end
  end
end
