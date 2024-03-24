defmodule MapExample do
  @moduledoc """
  This is an attempt to independently solve a problem
  before getting acquainted with a ready-made solution.
  """

  def test_string do
  """
  Elixir in Action is a tutorial book that aims to bring developers
  new to Elixir and Erlang to the point where they can develop complex systems on their own.
  """
  end

  def count_words(sentence) do
    String.split(sentence)
      # my own implmentation instead Enum.reduce
      |> reduce_count_words(%{})

    # String.split(sentence)
    # |> Enum.group_by(fn(x) -> x end)
    # |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, Enum.count(v)) end)

    # or

    # String.split(sentence)
    # |> Enum.reduce(%{}, fn word, acc -> Map.update(acc, word, 1, &(&1 + 1)) end)
  end

  defp reduce_count_words([], acc), do: acc

  @spec reduce_count_words(collection :: list(), acc :: Map.t()) :: acc :: Map.t()
  defp reduce_count_words(collection, acc) do
    [head | tail] = collection
    acc = Map.update(acc, head, 1, &(&1 + 1))
    reduce_count_words(tail, acc)
  end
end

# tests

ExUnit.start()

defmodule MapExampleTest do
  use ExUnit.Case
  import MapExample

  # test "reduce_count_words" do
  #   assert %{"a" => 2, "b" => 1} == reduce_count_words(["a", "b", "a"], %{})
  # end

  test "count_words" do
    assert %{"a" => 1, "b" => 1, "c" => 2} == count_words("a c b c")
  end
end
