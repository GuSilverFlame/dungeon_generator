defmodule DungeonGenerator do
  def new_dungeon(
        repetitions \\ 10,
        area_size \\ {100, 100},
        max_room_size \\ {14, 14},
        min_room_size \\ {4, 4}
      ) do
    rooms =
      Enum.reduce(0..repetitions, [], fn _x, acc ->
        new_room = rectangle(area_size, min_room_size, max_room_size)

        if Enum.any?(acc, fn room -> rectangle_overlap?(room, new_room) end) do
          acc
        else
          [new_room | acc]
        end
      end)

    Enum.concat(
      link_rooms(Enum.sort_by(rooms, fn room -> distance({0, 0}, middle_point(room)) end), []),
      Enum.flat_map(rooms, &rectangle_points/1)
    )
  end

  defp link_rooms([_last_room | []], acc) do
    acc
  end

  defp link_rooms([current | next_rooms], acc) do
    start_point = middle_point(current)

    nearest_neighbor =
      Enum.min_by(next_rooms, fn room -> distance(start_point, middle_point(room)) end)

    end_point = middle_point(nearest_neighbor)

    link_rooms(next_rooms, Enum.concat(connect_dots(start_point, end_point), acc))
  end

  defp rectangle(
         {max_height, max_width},
         {min_room_height, min_room_width},
         {max_room_height, max_room_width}
       ) do
    # the subtraction is to make sure even a max sized room still remains within the set limits
    left = :random.uniform(max_width - max_room_width)
    top = :random.uniform(max_height - max_room_height)

    # we subtract the minimum values to sum them later to avoid a random number lower
    # than the configured
    right = left + :random.uniform(max_room_width - min_room_width) + min_room_width
    bottom = top + :random.uniform(max_room_height - min_room_height) + min_room_height
    {left, top, right, bottom}
  end

  defp rectangle_overlap?({left_1, top_1, right_1, bottom_1}, {left_2, top_2, right_2, bottom_2}) do
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

  defp rectangle_points({left, top, right, bottom}) do
    Enum.reduce(top..bottom, [], fn y, acc ->
      Enum.reduce(left..right, acc, fn x, acc ->
        [{x, y} | acc]
      end)
    end)
  end

  defp middle_point({left, top, right, bottom}) do
    x = (left + right) / 2
    y = (top + bottom) / 2
    {Kernel.trunc(x), Kernel.trunc(y)}
  end

  defp connect_dots({x_1, y_1}, {x_2, y_2}) when y_1 == y_2 do
    Enum.map(x_1..x_2, fn x -> {x, y_1} end)
  end

  defp connect_dots({x_1, y_1}, {x_2, y_2}) when x_1 == x_2 do
    Enum.map(y_1..y_2, fn y -> {x_1, y} end)
  end

  defp connect_dots({x_1, y_1}, {x_2, y_2}) do
    if abs(x_1 - x_2) > abs(y_1 - y_2) do
      Enum.concat(connect_dots({x_1, y_1}, {x_2, y_1}), connect_dots({x_2, y_1}, {x_2, y_2}))
    else
      Enum.concat(connect_dots({x_1, y_1}, {x_1, y_2}), connect_dots({x_1, y_2}, {x_2, y_2}))
    end
  end

  defp distance({x_1, y_1}, {x_2, y_2}) do
    (:math.pow(x_2 - x_1, 2) + :math.pow(y_2 - y_1, 2))
    |> :math.sqrt()
  end
end
