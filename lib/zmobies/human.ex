defmodule Zmobies.Human do
  use GenServer
  alias Zmobies.{Movement, Being, Movement}

  def start_link(being) do
    GenServer.start_link(
      __MODULE__,
      being,
      name: via_tuple(being)
    )
  end

  def init(being) do
    schedule_next_move
    {:ok, being}
  end

  def stop(being) do
    GenServer.stop(via_tuple(being))
  end

  def via_tuple(being) do
    {:via, :gproc, {:n, :l, being.uuid}}
  end

  def handle_info(:move, being) do
    new_being = being
    |> Movement.proximity_stream
    |> calculate_next_move(being)
    |> Movement.move(being)

    schedule_next_move
    {:noreply, new_being}
  end

  defp calculate_next_move(proximity_stream, being = %Being{location: current_location}) do
    nearest_enemy = proximity_stream
    |> Stream.take(5)
    |> Movement.nearest_enemy(being)

    case nearest_enemy do
      {enemy_location, _enemy} -> Movement.away_from(enemy_location, current_location)
      nil -> []
    end
  end

  defp schedule_next_move do
    Process.send_after(self, :move, 200)
  end
end
