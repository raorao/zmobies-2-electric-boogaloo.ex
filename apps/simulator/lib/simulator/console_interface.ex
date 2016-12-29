defmodule Simulator.ConsoleInterface do
  alias Simulator.StatsManager
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      %{printing: true},
      name: :console_interface
    )
  end

  def init(state) do
    schedule_next_print
    {:ok, state}
  end

  def toggle_print do
    GenServer.cast(:console_interface, :toggle_print)
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
    new_board =  Simulator.Presenter.to_s(colors: true)
    IEx.Helpers.clear
    IO.puts new_board
  end
end
