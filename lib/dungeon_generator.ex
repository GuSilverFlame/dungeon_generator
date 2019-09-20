defmodule DungeonGenerator do
  def test(repetitions \\ 10) do
    rooms =
      Enum.reduce(0..repetitions, [], fn _x, acc ->
        new_room = rectangle()

        if Enum.any?(acc, fn room -> overlap?(room, new_room) end) do
          acc
        else
          [new_room | acc]
        end
      end)

    Enum.concat(
      link_rooms(Enum.sort_by(rooms, fn room -> distance({0, 0}, middle_point(room)) end), []),
      Enum.flat_map(rooms, &points/1)
    )
  end

  def link_rooms([_last_room | []], acc) do
    acc
  end

  def link_rooms([current | next_rooms], acc) do
    {start_x, start_y} = start_point = middle_point(current)

    nearest_neighbor =
      Enum.min_by(next_rooms, fn room -> distance(start_point, middle_point(room)) end)

    {end_x, end_y} = middle_point(nearest_neighbor)

    link_rooms(next_rooms, Enum.concat(connect_dots(start_x, start_y, end_x, end_y), acc))
  end

  defp rectangle() do
    left = :random.uniform(100)
    top = :random.uniform(100)
    right = left + :random.uniform(10) + 4
    bottom = top + :random.uniform(10) + 4
    {left, top, right, bottom}
  end

  defp overlap?({left_1, top_1, right_1, bottom_1}, {left_2, top_2, right_2, bottom_2}) do
    if one_dimension_overlap?(left_1, right_1, left_2, right_2) &&
         one_dimension_overlap?(top_1, bottom_1, top_2, bottom_2) do
      true
    else
      false
    end
  end

  defp one_dimension_overlap?(start_1, end_1, start_2, end_2) do
    start_1 <= end_2 && start_2 <= end_1
  end

  def points({x_1, y_1, x_2, y_2}) do
    Enum.reduce(y_1..y_2, [], fn y, acc ->
      Enum.reduce(x_1..x_2, acc, fn x, acc ->
        [{x, y} | acc]
      end)
    end)
  end

  defp connect_dots(x_1, y_1, x_2, y_2) when y_1 == y_2 do
    Enum.map(x_1..x_2, fn x -> {x, y_1} end)
  end

  defp connect_dots(x_1, y_1, x_2, y_2) when x_1 == x_2 do
    Enum.map(y_1..y_2, fn y -> {x_1, y} end)
  end

  defp connect_dots(x_1, y_1, x_2, y_2) do
    if abs(x_1 - x_2) > abs(y_1 - y_2) do
      Enum.concat(connect_dots(x_1, y_1, x_2, y_1), connect_dots(x_2, y_1, x_2, y_2))
    else
      Enum.concat(connect_dots(x_1, y_1, x_1, y_2), connect_dots(x_1, y_2, x_2, y_2))
    end
  end

  defp middle_point({left, top, right, bottom}) do
    horizontal = (left + right) / 2
    vertical = (top + bottom) / 2
    {Kernel.trunc(horizontal), Kernel.trunc(vertical)}
  end

  defp distance({x_1, y_1}, {x_2, y_2}) do
    (:math.pow(x_2 - x_1, 2) + :math.pow(y_2 - y_1, 2))
    |> :math.sqrt()
  end
end
