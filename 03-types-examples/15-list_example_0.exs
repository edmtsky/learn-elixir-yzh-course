defmodule ListExample do
  @moduledoc """
  A naive way to solve a problem - head on
  We make sure that the naive implementation by itself will not work correctly.
  And then we come to the understanding that we need to implement the correct
  merging algorithm.
  """
  @doc """
  ## Usage Example:
      iex> c "15-list-example-0.exs"
      iex> l1 = [1, 3, 7, 20]
      iex> l2 = [2, 6, 11, 32]
      iex> ListExample.merge(l1, l2)
      [1, 3, 7, 20, 2, 6, 11, 32]
  """
  def merge0(list1, list2) do
    list1 ++ list2
  end
end
