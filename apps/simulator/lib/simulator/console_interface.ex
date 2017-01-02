defmodule Simulator.ConsoleInterface do
  alias Simulator.{StatsManager, Being, World, ConsoleInterface.Presenter}
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
    new_board =  Presenter.to_s(colors: true)
    IEx.Helpers.clear
    IO.puts new_board
  end

  defmodule Presenter do
    def to_s(colors: colors) do
      sorted = :world
      |> generate_sorted
      |> Enum.to_list
      |> List.keysort(0)

      case sorted do
        [] -> ""
        _ ->
          y_max = sorted
          |> List.last
          |> elem(1)
          |> List.last
          |> Being.y

          (1..y_max)
          |> Enum.map(&find_row(sorted, &1))
          |> Enum.map(& row_to_s(&1, colors))
          |> Enum.join("\n")
      end
    end

    defp generate_sorted(table) do
      :ets.safe_fixtable(:world, true)
      sorted = do_generate_sorted(table, :ets.first(table), %{})
      :ets.safe_fixtable(:world, false)

      sorted
    end

    defp do_generate_sorted(_table, :"$end_of_table", result), do: result

    defp do_generate_sorted(table, key, result) do
      case :ets.next(table, key) do
        :'$end_of_table' -> insert_into_result(table, key, result)
        next -> do_generate_sorted(table, next, insert_into_result(table, key, result))
      end
    end

    defp insert_into_result(_table, location, result) do
      case World.at(location) do
        {:occupied, new_being} ->
          Map.update(result, location.y, [new_being], fn(row) ->
            target_x = Being.x(new_being)
            {head, tail} = Enum.split_while(row, fn(being) -> Being.x(being) < target_x end)
            head ++ [new_being] ++ tail
          end)
        :vacant -> result
      end
    end

    defp find_row(rows, target) do
      Enum.find(rows, fn({y, _}) -> y == target end)
    end

    defp row_to_s(nil, _colors), do: ""

    defp row_to_s({_, row}, colors) do
      x_max = row
      |> List.last
      |> Being.x

      (1..x_max)
      |> Enum.map(&find_being(row, &1))
      |> Enum.map(& being_to_string(&1, colors))
      |> Enum.join(" ")
    end

    defp find_being(row, target) do
      Enum.find(row, fn(being) -> Being.x(being) == target end)
    end

    def being_to_string(nil, _colors),   do: " "
    def being_to_string(being, colors), do: Being.to_s(being, colors: colors)
  end
end
