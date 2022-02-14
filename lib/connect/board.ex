defmodule Connect.Board do
  def make_board(), do: do_make_board(1, [])

  def do_make_board(7, board), do: board

  def do_make_board(row, board) do
    current_row = Enum.map(1..7, fn _ -> nil end)
    do_make_board(row + 1, [current_row | board])
  end

  # def play(_board, column, _player, 6), do: "No move: #{column}"

  def play(board, column, player, 5 = row) when column in 0..6 do
    place =
      board
      |> Enum.at(row)
      |> Enum.at(column)

    if place == nil do
      {row, column}
    else
      "No move: #{column}"
    end
  end

  def play(board, column, player, row) when column in 0..6 do
    place =
      board
      |> Enum.at(row)
      |> Enum.at(column)

    next_place =
      board
      |> Enum.at(row + 1)
      |> Enum.at(column)

    if place == nil and next_place != nil do
      {row, column}
    else
      play(board, column, player, row + 1)
    end
  end
end
