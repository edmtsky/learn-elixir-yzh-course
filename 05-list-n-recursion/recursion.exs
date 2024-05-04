defmodule Recursion do

  @moduledoc """
  iex recursion.exs

  iex> alias Recursion, as R
  """


  @doc """
  # len
  iex> R.len([1, 2, 3, 4])
  4
  """
  def len([]), do: 0 # body to exit from recursion

  def len([_head | tail]) do
    1 + len(tail)
  end


  @doc """
  # list_max

  iex> R.list_max([1, 2, 3, 4])
  4

  iex> R.list_max([1, 42, 3, 500, 100, -4])
  500
  """
  def list_max([]), do: nil

  def list_max([elm]), do: elm

  def list_max([head | tail]) do
    max(head, list_max(tail))
  end


  @doc """
  iex> R.set_value([1,2,3,4], 3, "X")
  [1, 2, "X", 4]

  iex> R.set_value([1,2,3,4], 1, "X")
  ["X", 2, 3, 4]

  iex> R.set_value([1,2,3,4], 4, "X")
  [1, 2, 3, "X"]

  iex> R.set_value([1,2,3,4], 5, "X")
  [1, 2, 3, 4]
  """
  def set_value([], _pos, _value), do: []

  def set_value([_head | tail], 1, value), do: [value | tail]

  def set_value([head | tail], pos, value) do # pos > 1
    tail = set_value(tail, pos - 1, value)
    [head | tail]
  end

  @doc """
  # range
  1..10 |> Enum.to_list()

  iex> R.range(1,1)
  [1]

  iex> R.range(1,5)
  [1, 2, 3, 4, 5]
  """
  def range(to, to), do: [to]

  def range(from, to) when from < to do
    [from | range(from + 1, to)]
  end

  def range(_, _), do: []


  @doc """
  # swap
  iex> R.swap([1,2,3,4,5,6])
  [2, 1, 4, 3, 6, 5]


  iex> R.swap([1,2,3,4,5])
  ** (RuntimeError) Can't swap list with odd number of lements
  """
  def swap([]), do: []

  def swap([_]), do: raise "Can't swap list with odd number of lements"

  def swap([item1, item2 | tail]) do
    [item2, item1 | swap(tail)]
  end

end
