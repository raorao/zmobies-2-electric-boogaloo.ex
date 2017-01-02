defmodule Simulator.Interface.FlatFileGenerator do
  alias Simulator.{Being, WorldManager, StatsManager}
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      {:file, :status},
      name: :flat_file_generator
    )
  end

  def init(state) do
    send self, :generate_file
    schedule_next_save
    {:ok, state}
  end

  def stop do
    GenServer.stop(:flat_file_generator)
  end

  def handle_info(:generate_file, _state) do
    filename =  Path.absname("apps/simulator/game_logs/#{:os.system_time(:millisecond)}.json")
    {:ok, file} = File.open filename, [:write, :utf8]

    {:noreply, {file, :ongoing}}
  end

  def handle_info(:save, {file, status}) do
    StatsManager.async_read(self, :handle_stats_update)

    json = %{snapshot: snapshot, status: status}
    |> Poison.encode!

    IO.puts file, json

    if status == :ongoing || status == :empty do
      schedule_next_save
    else
      IO.puts("file generated.")
      File.close file
    end

    {:noreply, {file, status}}
  end

  def handle_info({:handle_stats_update, status}, {file, _status}) do
    {:noreply, {file, status}}
  end

  defp schedule_next_save do
    Process.send_after(self, :save, 60)
  end

  def snapshot do
    WorldManager.all
    |> Enum.map(&Being.as_json/1)
  end
end
