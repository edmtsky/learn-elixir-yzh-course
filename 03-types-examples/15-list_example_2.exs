defmodule ListExample do
  @moduledoc """
  implementation of part of the list merge-sorting algorithm
  in this example we implement only one function -
  merging two pre-sorted lists into one.
  """

  @doc """
  merging two pre-sorted lists into one
  """
  @spec merge(list(), list()) :: list()

  def merge(list1, list2) do
    check_sort(list1)
    check_sort(list2)
    merge(list1, list2, [])
  end

  defp merge([], list2, acc), do: Enum.reverse(acc) ++ list2
  defp merge(list1, [], acc), do: Enum.reverse(acc) ++ list1

  defp merge(list1, list2, acc) do
    [head1 | tail1] = list1
    [head2 | tail2] = list2

    if head1 < head2 do
      merge(tail1, list2, [head1 | acc])
    else
      merge(list1, tail2, [head2 | acc])
    end
  end

  @doc """
  a function that checks whether a given list is actually sorted
  if not, raises a runtime error "Unsorted"
  """
  def check_sort([]), do: {:ok}

  def check_sort(list) do
    [head | tail] = list
    check_sort(head, tail)
  end

  defp check_sort(_prev, []), do: {:ok}

  defp check_sort(prev, list) do
    [head | tail] = list
    if prev > head do
      raise "Unsorted: " <> to_string(prev) <> " " <> to_string(head)
    else
      check_sort(head, tail)
    end
  end

end

# tests

ExUnit.start()

defmodule ListExampleTest do
  use ExUnit.Case
  import ListExample

  test "merge" do
    assert [1, 2, 3, 4, 5] == merge([1, 3], [2, 4, 5])
    assert [-100, 0, 2, 22, 55, 500, 1000] == merge([2,22,500, 1000], [-100, 0, 55])

    # left:  [1, 2, 3, 4, 5]
    # right: [1, 4, 3, 5, 2]
  end

  test "merge, corner cases" do
    assert [] == merge([], [])
    assert [1, 2, 3 ] == merge([], [1, 2, 3])
    assert [1, 2, 3 ] == merge([1, 2, 3], [])
  end

end
