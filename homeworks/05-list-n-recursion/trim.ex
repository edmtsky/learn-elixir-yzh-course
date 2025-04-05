defmodule Trim do

  # We only trim space character
  def is_space(char), do: char == 32

  @doc """
  Function trim spaces in the beginning and in the end of the string.
  It accepts both single-quoted and double-quoted strings.

  ## Examples
  iex> Trim.trim('   hello there   ')
  'hello there'
  iex> Trim.trim("  Привет   мир  ")
  "Привет   мир"
  """
  def trim(str) when is_list(str) do
    # We iterate string 4 times here
    str
    |> trim_left
    |> Enum.reverse
    |> trim_left
    |> Enum.reverse
  end

  def trim(str) when is_binary(str) do
    # And yet 2 more iterations here
    str
    |> to_charlist
    |> trim
    |> to_string
  end


  defp trim_left([]), do: []
  defp trim_left([head | tail] = str) do
    if is_space(head) do
      trim_left(tail)
    else
      str
    end
  end


  def effective_trim(str) when is_list(str) do
    {start, finish} = find_trim_edges(str, 0, -1, -1)
    Enum.slice(str, start..finish)
  end

  def effective_trim(str) when is_binary(str) do
    str
    |> to_charlist
    |> effective_trim()
    |> to_string()
  end

  defp find_trim_edges([], _, start, finish), do: {start, finish}
  defp find_trim_edges([head | tail], index, start, finish) do
    if is_space(head) do
      if start == -1 do  # search left trim
        find_trim_edges(tail, index + 1, -1, finish)
      else
        find_trim_edges(tail, index + 1, start, finish)
      end
    else
      if start == -1 do
        find_trim_edges(tail, index + 1, index, finish)
      else
        find_trim_edges(tail, index + 1, start, index)
      end
    end
  end

end
