defmodule Zmobies.Interface do
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

  def handle_info(:print, state = %{printing: false}) do
    schedule_next_print
    {:noreply, state}
  end

  def handle_info(:print, state = %{printing: true}) do
    new_board =  Zmobies.Presenter.to_s
    IEx.Helpers.clear
    IO.puts new_board
    schedule_next_print
    {:noreply, state}
  end

  def handle_cast(:toggle_print, %{printing: printing}) do
    {:noreply, %{printing: !printing}}
  end

  defp schedule_next_print do
    Process.send_after(self, :print, 200)
  end
end
