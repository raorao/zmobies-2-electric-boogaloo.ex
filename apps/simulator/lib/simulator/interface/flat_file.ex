defmodule Simulator.Interface.FlatFile do
  alias Simulator.{GameSupervisor}
  use GenServer

  def start_link(filename, broadcast_fn) do
    GenServer.start_link(
      __MODULE__,
      {broadcast_fn, filename},
      name: :flat_file_interface
    )
  end

  def init(state) do
    send self, :open_filestream
    schedule_next_print
    {:ok, state}
  end

  def stop do
    GenServer.stop(:flat_file_interface)
  end

  def handle_info(:open_filestream, {broadcast_fn, filename}) do
    filestream = filename
    |> Path.absname
    |> File.stream!([:utf8])
    {:noreply, {broadcast_fn, filestream}}
  end

  def handle_info(:print, {broadcast_fn, filestream}) do
    case Enum.take(filestream, 1) do
      [current_entry] ->
        %{"status" => status, "snapshot" => snapshot} = current_entry
        |> Poison.decode!

        broadcast_fn.({snapshot, status})
        schedule_next_print
        {:noreply, {broadcast_fn, Stream.drop(filestream, 1)}}


      [] ->
        IO.inspect("stream over.")
        GameSupervisor
        {:noreply, {broadcast_fn, filestream}}
    end
  end

  defp schedule_next_print do
    Process.send_after(self, :print, 60)
  end
end
