defmodule Zmobies.Zombie do
  use GenServer
  alias Zmobies.{World}

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

  def via_tuple(being) do
    {:via, :gproc, {:n, :l, being.uuid}}
  end

  def handle_info(:move, being) do
    schedule_next_move(being)
    {:noreply, being}
  end

  defp schedule_next_move(being) do
    Process.send_after(self, :move, 200)
  end
end
