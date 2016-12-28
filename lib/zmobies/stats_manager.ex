defmodule Zmobies.StatsManager do
  use GenServer
  alias Zmobies.{World}

  def start_link do
    GenServer.start_link(
      __MODULE__,
      :ongoing,
      name: :stats_manager
    )
  end

  def init(status) do
    send(self, :check_status)
    {:ok, status}
  end

  def stop do
    GenServer.stop(:stats_manager)
  end

  def read do
    GenServer.call(:stats_manager, :read)
  end

  def handle_info(:check_status, _current_status) do
    new_status = World.status

    if new_status == :ongoing do
      send(self, :check_status)
    end

    {:noreply, new_status}
  end
end
