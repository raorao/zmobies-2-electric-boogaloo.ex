defmodule Zmobies.JsonInterface do
  alias Zmobies.{Being, WorldManager, StatsManager}
  use GenServer

  def start_link(broadcast_fn) do
    GenServer.start_link(
      __MODULE__,
      {broadcast_fn, :ongoing},
      name: :json_interface
    )
  end

  def init(state) do
    schedule_next_broadcast
    {:ok, state}
  end

  def stop do
    GenServer.stop(:json_interface)
  end

  def handle_info(:broadcast, {broadcast_fn, status}) do
    StatsManager.async_read(self, :handle_stats_update)
    broadcast_fn.({snapshot, status})
    if status == :ongoing || status == :empty do
      schedule_next_broadcast
    end
    {:noreply, {broadcast_fn, status}}
  end

  def handle_info({:handle_stats_update, status}, {broadcast_fn, _status}) do
    {:noreply, {broadcast_fn, status}}
  end

  defp schedule_next_broadcast do
    Process.send_after(self, :broadcast, 10)
  end

  def snapshot do
    WorldManager.all
    |> Enum.map(&Being.as_json/1)
  end
end
