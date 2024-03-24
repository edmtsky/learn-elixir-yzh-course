defmodule StringExample do
  def example() do
    ["a", "bb", "hello", "word", "some-long-word", "short-word"]
  end

  @doc """
  |  a |
  | bbb|
  | cc |
  |dddd|
  """
  def align_words(words) do
    max_length = find_max_length(words)
    Enum.map(words, fn word -> align_word(word, max_length) end)
  end

  def find_max_length(words) do
    do_find_max_length(words, 0)
  end

  defp do_find_max_length([], current_max), do: current_max

  defp do_find_max_length([word | words], current_max) do
    current_max = max(String.length(word), current_max)
    do_find_max_length(words, current_max)
  end

  # TODO protect from infinitive recursion
  # length should not be less than word length
  def align_word(word, length) do
    spaces = length - String.length(word)
    left_spaces = div(spaces, 2)
    right_spaces = spaces - left_spaces

    word
    |> add_spaces(:right, right_spaces)
    |> add_spaces(:left, left_spaces)
  end

  # TODO protect from infinitive recursion
  # spaces should not be less than 0
  def add_spaces(str, _, 0), do: str
  def add_spaces(str, :left, spaces), do: add_spaces(" " <> str, :left, spaces - 1)
  def add_spaces(str, :right, spaces), do: add_spaces(str <> " ", :right, spaces - 1)
end


ExUnit.start()
defmodule StringExampleTest do
  use ExUnit.Case
  import StringExample

  test "add_spaces" do
    assert "aa" == add_spaces("aa", :left, 0)
    assert "aa" == add_spaces("aa", :right, 0)
    assert "  aa" == add_spaces("aa", :left, 2)
    assert "aa  " == add_spaces("aa", :right, 2)
  end

  test "align_word" do
    # assert " aa " == align_word("aa", 0) # TODO fix infinitive recursion
    # assert " aa " == align_word("aa", 1)
    assert "aa" == align_word("aa", 2)
    assert "aa " == align_word("aa", 3)
    assert " aa " == align_word("aa", 4)
    assert " aa  " == align_word("aa", 5)
    assert "  aa  " == align_word("aa", 6)
  end

  test "find_max_length" do
    assert 14 == find_max_length(example())
    assert 0 == find_max_length([])
    assert 1 == find_max_length(["a"])
    assert 2 == find_max_length(["a", "aa"])
  end

  test "align_words" do
    assert [] == align_words([])
    assert ["aa"] == align_words(["aa"])
    assert ["aa ", "bbb"] == align_words(["aa", "bbb"])
    assert [" aa ", "bbbb"] == align_words(["aa", "bbbb"])
    assert ["  aa  ", " bbb  ", "cccccc"] == align_words(["aa", "bbb", "cccccc"])
  end
end
