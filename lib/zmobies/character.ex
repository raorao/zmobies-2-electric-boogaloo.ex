defmodule Zmobies.Character do
  use GenServer
  alias Zmobies.{Movement, Being, Movement, Action}

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

  def attack(attacker, victim) do
    GenServer.cast(via_tuple(victim), {:attack, attacker})
  end

  def via_tuple(being) do
    {:via, :gproc, {:n, :l, being.uuid}}
  end

  def  handle_cast({:attack, _attacker}, being) do
    case Being.turn(being) do
      {:ok, new_being} -> {:noreply, new_being}
      {:error, _} -> {:noreply, being}
    end
  end

  def handle_info(:move, being) do
    action = being
    |> Movement.proximity_stream
    |> character_module(being).act(being)

    new_being = case action do
      {:move, moves} -> Action.move(moves, being)
      {:attack, enemy_location} -> Action.attack(being, enemy_location)
    end

    schedule_next_move

    {:noreply, new_being}
  end

  defp character_module(being) do
    case Being.type(being) do
      :human -> Zmobies.Human
      :zombie -> Zmobies.Zombie
    end
  end

  defp schedule_next_move do
    Process.send_after(self, :move, 200)
  end
end
