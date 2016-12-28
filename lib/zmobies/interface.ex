defmodule Zmobies.Interface do
  alias Zmobies.StatsManager
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      %{printing: true},
      name: :interface
    )
  end

  def init(state) do
    schedule_next_print
    {:ok, state}
  end

  def toggle_print do
    GenServer.cast(:interface, :toggle_print)
  end

  def handle_info(:print, state = %{printing: false}), do: {:noreply, state}

  def handle_info(:print, state = %{printing: true}) do
    print
    StatsManager.async_read(self, :handle_stats_update)
    schedule_next_print
    {:noreply, state}
  end

  def handle_info({:handle_stats_update, _}, state = %{printing: false}), do: {:noreply, state}

  def handle_info({:handle_stats_update, status}, state) when status == :ongoing or status == :empty do
    {:noreply, state}
  end

  def handle_info({:handle_stats_update, winner}, _state) do
    print
    IO.puts "The game is over. The #{inspect winner}s have won."
    {:noreply, %{printing: false}}
  end

  def handle_cast(:toggle_print, %{printing: printing}) do
    schedule_next_print
    {:noreply, %{printing: !printing}}
  end

  defp schedule_next_print do
    Process.send_after(self, :print, 10)
  end

  defp print do
    new_board =  Zmobies.Presenter.to_s
    IEx.Helpers.clear
    IO.puts new_board
  end
end
