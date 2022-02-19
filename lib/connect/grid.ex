defmodule Connect.Grid do
  def make_grid(), do: do_make_grid(1, [])

  def do_make_grid(7, grid), do: grid

  def do_make_grid(row, grid) do
    current_row = Enum.map(1..7, fn _ -> nil end)
    do_make_grid(row + 1, [current_row | grid])
  end

  def play(grid, player, column) do
    {result, grid} =
      case drop_piece(grid, player, {0, column}) do
        :full_column ->
          {:full_column, grid}

        {new_grid, {row, column}} ->
          if win?(new_grid, player, {row, column}) do
            {:end_game, new_grid}
          else
            {:continue, new_grid}
          end
      end

    if tie?(grid), do: {:tie, grid}, else: {result, grid}
  end

  def tie?(board) do
    not (board
         |> List.flatten()
         |> Enum.any?(fn p -> is_nil(p) end))
  end

  def drop_piece(grid, player, {5 = row, column}) do
    place =
      grid
      |> Enum.at(row)
      |> Enum.at(column)

    if place == nil do
      {put_piece(grid, player, {row, column}), {row, column}}
    else
      :full_column
    end
  end

  def drop_piece(grid, player, {row, column}) do
    place =
      grid
      |> Enum.at(row)
      |> Enum.at(column)

    next_place =
      grid
      |> Enum.at(row + 1)
      |> Enum.at(column)

    if place == nil and next_place != nil do
      {put_piece(grid, player, {row, column}), {row, column}}
    else
      drop_piece(grid, player, {row + 1, column})
    end
  end

  def put_piece(grid, player, {row, column}) do
    new_row =
      grid
      |> Enum.at(row)
      |> List.replace_at(column, player)

    List.replace_at(grid, row, new_row)
  end

  def win?(grid, player, {row, column}) do
    neighbors_count =
      Connect.Neighbor.find_all(grid, player, {row, column})
      |> travel_neighbors(grid, {row, column}, player)
      |> List.flatten()

    neighbors_coordinates = extract_coordinats(neighbors_count)

    Enum.reduce_while(neighbors_count, false, fn
      {_row, _column, 3}, _acc ->
        {:halt, true}

      {row, column, 2}, acc ->
        if has_opposite_direction?({row, column}, neighbors_coordinates),
          do: {:halt, true},
          else: {:cont, acc}

      {_row, _column, _count}, acc ->
        {:cont, acc}
    end)
  end

  def extract_coordinats(neighbors),
    do: Enum.map(neighbors, fn {r, c, _} -> {r, c} end)

  def has_opposite_direction?({row, column}, neighbors) do
    opposite_direction({row, column}) in neighbors
  end

  def opposite_direction({row, column}) do
    o_row =
      case row do
        :same -> :same
        :up -> :down
        :down -> :up
      end

    o_column =
      case column do
        :same -> :same
        :left -> :right
        :right -> :left
      end

    {o_row, o_column}
  end

  def travel_neighbors(neighbors, grid, {row, column}, player) do
    travel_rows(grid, neighbors, {row, column}, player, [])
  end

  def travel_rows(_grid, [], _, _player, acc), do: acc

  def travel_rows(grid, [nrow | rows], {row, column}, player, acc) do
    result = travel_columns(grid, nrow, {row, column}, player, [])
    travel_rows(grid, rows, {row, column}, player, [result | acc])
  end

  def travel_columns(_grid, {_nrow, []}, _, _player, acc), do: acc

  def travel_columns(grid, {nrow, [direction | directions]}, {row, column}, player, acc) do
    result = do_travel_columns(grid, {nrow, direction}, {row, column}, player, 0)
    travel_columns(grid, {nrow, directions}, {row, column}, player, [result | acc])
  end

  def do_travel_columns(grid, {nrow, direction}, {row_acc, column_acc}, player, count) do
    next_row = row_movement(nrow) + row_acc
    next_column = column_movement(direction) + column_acc

    next =
      grid
      |> Enum.at(next_row)
      |> case do
        nil -> nil
        row -> Enum.at(row, next_column)
      end

    case next do
      ^player ->
        do_travel_columns(
          grid,
          {nrow, direction},
          {next_row, next_column},
          player,
          count + 1
        )

      _ ->
        {nrow, direction, count}
    end
  end

  def row_movement(:same), do: 0

  def row_movement(:up), do: -1

  def row_movement(:down), do: 1

  def column_movement(:same), do: 0

  def column_movement(:left), do: -1

  def column_movement(:right), do: 1
end
