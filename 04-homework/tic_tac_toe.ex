defmodule TicTacToe do

  @type who :: :x | :o
  @type cell :: :x | :o | :f
  @type row :: {cell, cell, cell}
  @type game_state :: {row, row, row}
  @type game_result :: {:win, :x} | {:win, :o} | :no_win

  @spec valid_game?(game_state) :: boolean
  def valid_game?({row1, row2, row3}) do
    valid_row?(row1) && valid_row?(row2) && valid_row?(row3)
  end

  def valid_game?(_), do: false

  @spec valid_row?(row) :: boolean
  defp valid_row?({cell1, cell2, cell3}) do
    valid_cell?(cell1) && valid_cell?(cell2) && valid_cell?(cell3)
  end

  defp valid_row?(_), do: false

  @spec valid_cell?(cell) :: boolean
  defp valid_cell?(cell) do
    case cell do
      :f -> true
      :x -> true
      :o -> true
      _ -> false
    end
  end

  #

  @spec check_who_win(game_state) :: game_result
  def check_who_win(state) do
    if valid_game?(state) do
      {r1, r2, r3} = state
      {c11, c12, c13} = r1
      {c21, c22, c23} = r2
      {c31, c32, c33} = r3
      lines = [
        r1, r2, r3,                                        # horizontal
        {c11, c21, c31}, {c12, c22, c32}, {c13, c23, c33}, # vertical
        {c11, c22, c33}, {c13, c22, c31}                   # diagonal
      ]
      check_lines(lines) # :nowin | {:win, who}
    end
  end

  @spec check_lines(List.t(row)) :: game_result
  defp check_lines([]), do: :no_win

  defp check_lines([row | tail]) do
    case row do
      {:x, :x, :x} -> {:win, :x}
      {:o, :o, :o} -> {:win, :o}
      _ -> check_lines(tail)
    end
  end
end
