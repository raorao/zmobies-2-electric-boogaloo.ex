defmodule Zmobies.Presenter do
  alias Zmobies.Being

  def to_s([]), do: ""

  def to_s(beings) do
    sorted = beings
    |> Enum.group_by(&Being.y/1)
    |> Enum.sort_by(& elem(&1, 0))
    |> Enum.map(&sort_row/1)

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

  defp sort_row({col_number, row}) do
    {col_number, Enum.sort_by(row, &Being.x/1)}
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
