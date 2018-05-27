defmodule Simulator.Character do
  use GenServer
  alias Simulator.{Proximity, Being, Proximity, Action, WorldManager}

  def start_link(strategy, being) do
    GenServer.start_link(
      __MODULE__,
      {strategy, being},
      name: via_tuple(being)
    )
  end

  def init({strategy, being}) do
    schedule_next_move(being)
    initial_custom_state = character_module({strategy, being}).initial_state(being)
    {:ok, {strategy, being, initial_custom_state}}
  end

  def stop(being) do
    GenServer.stop(via_tuple(being))
  end

  def resolve_attack(attacker, victim) do
    GenServer.cast(via_tuple(victim), {:resolve_attack, attacker})
  end

  def resolve_talk(speaker, listener, message) do
    GenServer.cast(via_tuple(listener), {:listen, speaker, message})
  end

  def read(being) do
    GenServer.call(via_tuple(being), :read)
  end

  def via_tuple(being) do
    {:via, :gproc, {:n, :l, being.uuid}}
  end

  def handle_cast({:resolve_attack, attacker}, {strategy, victim, custom_state}) do
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

    {:noreply, {strategy, new_being, custom_state}}
  end

  def handle_cast({:listen, speaker, message}, {strategy, being, custom_state}) do
    new_custom_state = character_module({strategy, being}).listen(message, speaker, being, custom_state)

    {:noreply, {strategy, being, new_custom_state}}
  end

  def handle_cast(:feed, {strategy, being, custom_state}) do
    new_being = Being.feed(being)
    WorldManager.update new_being
    {:noreply, {strategy, being, custom_state}}
  end

  def handle_call(:read, _, state) do
    {:reply, state, state}
  end

  def handle_info(:move, {strategy, being = %Being{health: health}, custom_state}) when health <= 0 do
    WorldManager.remove(being.location)
    {:stop, :normal, {strategy, being, custom_state}}
  end

  def handle_info(:move, {strategy, being, custom_state}) do
    {new_being, new_custom_state} = being
    |> Proximity.proximity_stream
    |> character_module({strategy, being}).act(being, custom_state)
    |> execute_action(being, custom_state)

    new_being = Being.age new_being

    WorldManager.update new_being
    schedule_next_move new_being
    {:noreply, {strategy, new_being, new_custom_state}}
  end

  defp character_module({strategy, being}) do
    case Being.type(being) do
      :human -> strategy
      :zombie -> Simulator.Character.Zombie
    end
  end

  defp schedule_next_move(%Being{speed: speed}) do
    interval = 400 - (3 * speed)
    Process.send_after(self, :move, interval)
  end

  defp execute_action({:move, moves}, being, custom_state) do
    { Action.move(moves, being), custom_state }
  end

  defp execute_action({:attack, enemy_location}, being, custom_state) do
    { Action.attack(being, enemy_location), custom_state }
  end

  defp execute_action({:talk, ally_locations, message}, being, custom_state) do
    { Action.talk(being, ally_locations, message), custom_state }
  end

  defp execute_action({action, new_custom_state}, being, _) do
    execute_action(action, being, new_custom_state)
  end
end
