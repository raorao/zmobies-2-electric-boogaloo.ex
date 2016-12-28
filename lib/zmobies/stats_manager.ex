defmodule Zmobies.StatsManager do
  use GenServer
  alias Zmobies.{World, GameManager}

  def start_link do
    GenServer.start_link(
      __MODULE__,
      :ongoing,
      name: :stats_manager
    )
  end

  def start, do: send(:stats_manager, :check_status)

  def stop do
    GenServer.stop(:stats_manager)
  end

  def async_read(requester, message) do
    GenServer.cast(:stats_manager, {:async_read, requester, message})
  end

  def handle_info(:check_status, _current_status) do
    new_status = World.status

    if new_status == :ongoing || new_status == :empty do
      send(self, :check_status)
    else
      GameManager.finish
    end

    {:noreply, new_status}
  end

  def handle_cast({:async_read, requester, message}, status) do
    send(requester, {message, status})
    {:noreply, status}
  end
end
