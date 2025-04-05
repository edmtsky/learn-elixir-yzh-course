defmodule MyList do
  @doc """
  Function takes a list that may contain any number of sublists,
  which themselves may contain sublists, to any depth.
  It returns the elements of these lists as a flat list.

  ## Examples
  iex> MyList.flatten([1, [2, 3], 4, [5, [6, 7, [8, 9, 10]]]])
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  """
  def flatten([]), do: []

  def flatten([head | tail]), do: flatten(head) ++ flatten(tail)

  def flatten(item), do: [item]

  # ++ operator is not very effective.
  # It would be better to provide a more effective implementation,
  # which is possible, but a little bit tricky.
  def flatten_e(list) do
    do_flatten_e(list, [])
  end


  # iex> L.add_to_head([3,4], [2, 1, 0])
  # [4, 3, 2, 1, 0]
  defp add_to_head([], acc), do: acc

  defp add_to_head([head | tail], acc) do
    add_to_head(tail, [head | acc])
  end

  defp do_flatten_e([], acc), do: Enum.reverse(acc)
  # head is a list
  defp do_flatten_e([head | tail], acc) when is_list(head) do
    sublist = do_flatten_e(head, [])
    new_acc = add_to_head(sublist, acc)

    do_flatten_e(tail, new_acc)
  end

  # head is an item
  defp do_flatten_e([head | tail], acc) do
    do_flatten_e(tail, [head | acc])
  end
end
