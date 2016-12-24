defmodule Zmobies.Presenter do
  alias Zmobies.{Being, World}

  def to_s do
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
        |> Enum.map(&row_to_s/1)
        |> Enum.join("\n")
    end
  end

  defp generate_sorted(table) do
    do_generate_sorted(table, :ets.first(table), %{})
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

  defp row_to_s(nil), do: ""

  defp row_to_s({_, row}) do
    x_max = row
    |> List.last
    |> Being.x

    (1..x_max)
    |> Enum.map(&find_being(row, &1))
    |> Enum.map(&being_to_string/1)
    |> Enum.join(" ")
  end

  defp find_being(row, target) do
    Enum.find(row, fn(being) -> Being.x(being) == target end)
  end

  def being_to_string(nil),   do: " "
  def being_to_string(being), do: to_string(being)
end
