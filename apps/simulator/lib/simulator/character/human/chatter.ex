defmodule Simulator.Character.Human.Chatter do
  use Human

  alias Simulator.{Character.Helpers}

  def initial_state(_), do: :watching

  def act(proximity_stream, self, custom_state) do
    {adjacent_allies, adjacent_enemies} = proximity_stream
    |> Stream.take(1)
    |> Helpers.visible_beings(self)

    case adjacent_enemies do
      [nearest | _rest] ->
        { {:attack, nearest.location}, custom_state }
      [] ->
        case custom_state do
          {:run, from, 0} ->
            watch_for_enemies(proximity_stream, adjacent_allies, self)
          {:run, from, count} ->
            {
              {:move,  Helpers.away_from(from, self.location)},
              {:run, from, count - 1}
            }
          :watching ->
            watch_for_enemies(proximity_stream, adjacent_allies, self)
        end
    end
  end

  def listen(message, _speaker, _self, :watching), do: message
  def listen(new_message, _speaker, _self, old_message) do
    {:run, _, new_strength} = new_message
    {:run, _, old_strength} = old_message

    cond do
      new_strength > old_strength  -> new_message
      new_strength <= old_strength -> old_message
    end

  end
  defp watch_for_enemies(proximity_stream, adjacent_allies, self) do
    nearest_enemy = proximity_stream
    |> Stream.drop(1)
    |> Stream.take(6)
    |> Helpers.nearest_enemy(self)

    case {nearest_enemy, adjacent_allies} do
      { nil, _ } ->
        {
          {:move, Helpers.random(self.location)},
          :watching
        }
      { {enemy_location, _}, [] } ->
        {
          {:move, Helpers.away_from(enemy_location, self.location)},
          :watching
        }
      { {enemy_location, _}, adjacent_allies } ->
        ally_locations = Enum.map(adjacent_allies, fn(%{location: l}) -> l end)
        {
          {:talk, ally_locations, {:run, enemy_location, 1}},
          {:run, enemy_location, 5}
        }
    end
  end
end
