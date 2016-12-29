defmodule Zmobies.Character do
  use GenServer
  alias Zmobies.{Movement, Being, Movement, Action, WorldManager}

  def start_link(being) do
    GenServer.start_link(
      __MODULE__,
      being,
      name: via_tuple(being)
    )
  end

  def init(being) do
    schedule_next_move(being)
    {:ok, being}
  end

  def stop(being) do
    GenServer.stop(via_tuple(being))
  end

  def attack(attacker, victim) do
    GenServer.cast(via_tuple(victim), {:attack, attacker})
  end

  def read(being) do
    GenServer.call(via_tuple(being), :read)
  end

  def via_tuple(being) do
    {:via, :gproc, {:n, :l, being.uuid}}
  end

  def handle_cast({:attack, attacker}, victim) do
    new_being = case Being.attack(attacker, victim) do
      {:attacked, new_being, response} ->
        WorldManager.update(new_being)
        GenServer.cast(via_tuple(attacker), response)
        new_being
      {:attacked, new_being} ->
        WorldManager.update(new_being)
        new_being
      {:error, _} -> victim
    end

    {:noreply, new_being}
  end

  def handle_cast(:feed, being) do
    new_being = Being.feed(being)
    WorldManager.update new_being
    {:noreply, new_being}
  end

  def handle_call(:read, _, state) do
    {:reply, state, state}
  end

  def handle_info(:move, being = %Being{health: health}) when health <= 0 do
    WorldManager.remove(being.location)
    stop(being)
    {:noreply, being}
  end

  def handle_info(:move, being) do
    new_being = being
    |> Movement.proximity_stream
    |> character_module(being).act(being)
    |> execute_action(being)
    |> Being.age

    WorldManager.update new_being
    schedule_next_move new_being
    {:noreply, new_being}
  end

  defp character_module(being) do
    case Being.type(being) do
      :human -> Zombies.Character.Human.FightOrFlight
      :zombie -> Zombies.Character.Zombie
    end
  end

  defp schedule_next_move(%Being{speed: speed}) do
    interval = 400 - (3 * speed)
    Process.send_after(self, :move, interval)
  end

  defp execute_action(action, being) do
    case action do
      {:move, moves} -> Action.move(moves, being)
      {:attack, enemy_location} -> Action.attack(being, enemy_location)
    end
  end
end
