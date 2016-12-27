defmodule Zmobies.Interface do
  use GenServer
  alias Zmobies.{WorldSupervisor, WorldManager, GameManager, Character}

  def start_link(printing) do
    GenServer.start_link(
      __MODULE__,
      %{printing: printing},
      name: :interface
    )
  end

  def init(state) do
    start(x: 40, y: 40, humans: 400, zombies: 10)
    schedule_next_print
    {:ok, state}
  end

  def toggle_print do
    GenServer.cast(:interface, :toggle_print)
  end

  def start(x: x, y: y, humans: humans, zombies: zombies) do
    WorldSupervisor.start_child({x, y})
    GameManager.start_link

    human_messages = if humans > 0 do
      for _ <- 1..humans do
        Character.start_link WorldManager.place(:human)
      end
    else
      []
    end

    zombie_messages = if zombies > 0 do
       for _ <- 1..zombies do
        Character.start_link WorldManager.place(:zombie)
      end
    else
      []
    end

    human_messages ++ zombie_messages
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
    Process.send_after(self, :print, 100)
  end
end
