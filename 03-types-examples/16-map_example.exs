defmodule MapExample do
  def test_string do
  """
  Elixir in Action is a tutorial book that aims to bring developers
  new to Elixir and Erlang to the point where they can develop complex systems on their own.
  """
  end

  def count_words(str) do
    str |> String.split() |> count_words(%{})
  end

  def count_words([], acc), do: acc
  # def count_words(words, acc) do
  def count_words([word | words], acc) do
    new_acc = case Map.fetch(acc, word) do
      {:ok, counter} -> %{acc | word => counter + 1}
      :error -> Map.put(acc, word, 1)
    end
    count_words(words, new_acc)
  end
end


ExUnit.start()

defmodule MapExampleTest do
  use ExUnit.Case
  import MapExample

  test "count_words" do
    assert %{} == count_words("")
    assert %{"aa" => 1} == count_words("aa")
    assert %{"aa" => 2} == count_words("aa aa")
    assert %{"a" => 1, "b" => 1, "c" => 2} == count_words("a c b c")
  end
end
