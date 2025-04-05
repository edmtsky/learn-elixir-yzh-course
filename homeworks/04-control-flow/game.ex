defmodule Game do

  def join_game({:user, _name, age, role}) do
    case {age, role} do
      {_, :admin} -> :ok
      {_, :moderator} -> :ok
      {age, _} when age >= 18 -> :ok
      _ -> :error
    end
  end

  def move_allowed?(current_color, figure) do
    case {current_color, figure} do
      {:white, {:pawn, :white}} -> true
      {:black, {:pawn, :black}} -> true
      {:white, {:rock, :white}} -> true
      {:black, {:rock, :black}} -> true
      _ -> false
    end
  end

  def single_win?(a_win, b_win) do
    case {a_win, b_win} do
      {true, false} -> true
      {false, true} -> true
      _ -> false
    end
  end

  def double_win?(a_win, b_win, c_win) do
    case {a_win, b_win, c_win} do
      {true, true, false} -> :ab
      {true, false, true} -> :ac
      {false, true, true} -> :bc
      _ -> false
    end
  end

end
