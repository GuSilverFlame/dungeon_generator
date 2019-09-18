defmodule DungeonGenerator do
  def test(repetitions \\ 10) do
    Enum.reduce(0..repetitions, [], fn _x, acc ->
      new_room = rectangle()

      if Enum.any?(acc, fn room -> overlap?(room, new_room) end) do
        acc
      else
        [new_room | acc]
      end
    end)
  end

  defp rectangle() do
    left = :random.uniform(300)
    top = :random.uniform(300)
    right = left + :random.uniform(10) + 4
    bottom = top + :random.uniform(10) + 4
    {left, top, right, bottom}
  end

  defp overlap?({left_1, top_1, right_1, bottom_1}, {left_2, top_2, right_2, bottom_2}) do
    if left_1 > right_2 || left_2 > right_1 || top_1 > bottom_2 || top_2 > bottom_1 do
      false
    else
      true
    end
  end

  defp points({x_1, y_1, x_2, y_2}) do
    top_bottom =
      Enum.reduce(y_1..y_2, [], fn y, acc ->
        [{y, x_1} | [{y, x_2} | acc]]
      end)

    left_right =
      Enum.reduce(x_1..x_2, [], fn x, acc ->
        [{y_1, x} | [{y_2, x} | acc]]
      end)

    Enum.concat(top_bottom, left_right) |> Enum.uniq()
  end
end
