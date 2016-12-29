defmodule Zmobies.StatsManager do
  use GenServer
  alias Zmobies.{World, GameManager}

  def start_link do
    GenServer.start_link(
      __MODULE__,
      {:ongoing, 5},
      name: :stats_manager
    )
  end

  def start, do: send(:stats_manager, :check_status)

  def async_read(requester, message) do
    GenServer.cast(:stats_manager, {:async_read, requester, message})
  end

  def handle_info(:check_status, {old_status, checks}) do
    new_status = World.status

    new_checks = cond do
      new_status == :ongoing || new_status == :empty ->
        send(self, :check_status)
        5
      old_status == new_status && checks == 0 ->
        GameManager.finish
        0
      old_status == new_status ->
        send(self, :check_status)
        checks - 1
      true ->
        send(self, :check_status)
        # something is wrong. flush state and start over.
        5
    end

    {:noreply, {new_status, new_checks}}
  end

  def handle_cast({:async_read, requester, message}, state = {status, _}) do
    send(requester, {message, status})
    {:noreply, state}
  end
end
