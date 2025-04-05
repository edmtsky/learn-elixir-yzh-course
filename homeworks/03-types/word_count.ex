defmodule WordCount do
  @moduledoc """
  Word Count
  """

  @doc """
  Count number of lines, words and symbols for a given file,
  returns tuple {num_lines, num_words, num_symbols}
  """
  def process_file(filename) do
    case File.read(filename) do
      {:ok, body} -> count(body)
      {:error, reason} -> {:error, reason}
    end
  end


  @doc ~S"""
  Count number of lines, words and symbols for a given string,
  returns tuple {num_lines, num_words, num_symbols}

  ## Example
  iex> WordCount.count("hello here\nand there")
  {2, 4, 20}
  """
  @spec count(data :: String.t) :: {}
  def count(data) do
    # chars = String.split(data, "")
    # do_count(chars, {1, 1, 0})
    num_lines = String.split(data, "\n") |> length()
    num_words = String.split(data) |> length()
    num_symbols = String.length(data)

    {num_lines, num_words, num_symbols}
  end

  # TODO a more optimized solution
  # String.next_grapheme ?
  # def count(data) do
  #   chars = String.split(data, "")
  #   do_count(chars, {1, 1, 0})
  # end

  # def do_count([], acc), do: acc
  # def do_count([char | rest], {num_lines, num_words, num_symbols}) do
  #   new_acc =
  #     case char do
  #       "\n" -> {num_lines + 1, num_words, num_symbols}
  #       " " -> {num_lines, num_words + 1, num_symbols + 1}
  #       "" -> {num_lines, num_words, num_symbols}
  #       _ -> {num_lines, num_words, num_symbols + 1}
  #     end
  #   do_count(rest, new_acc)
  # end

end
