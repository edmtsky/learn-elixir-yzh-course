defmodule Caesar do
  # We consider only chars in range 32 - 126 as valid ascii chars
  # http://www.asciitable.com/
  @min_ascii_char 32
  @max_ascii_char 126
  @char_size 8
  @byte_size 255

  @doc """
  Function shifts forward all characters in string.
  String could be double-quoted or single-quoted.

  ## Examples
  iex> Caesar.encode("Hello", 10)
  "Rovvy"
  iex> Caesar.encode('Hello', 5)
  'Mjqqt'
  """
  def encode(str, code) do
    case is_list(str) do
      true -> do_shift_charlist(str, code, [])
      false -> do_shift_binary(str, code, <<>>)
    end
  end

  # normalize to byte size
  # todo find way to do it via bitwize operation
  defp do_shift_codepoint(codepoint, code) when code > @byte_size do
    codepoint - @byte_size
  end

  defp do_shift_codepoint(codepoint, code) when code < -@byte_size do
    codepoint + @byte_size
  end

  defp do_shift_codepoint(codepoint, code) do
    case codepoint >= @min_ascii_char and codepoint <= @max_ascii_char do
      true ->
          codepoint + code

      false ->
        codepoint
    end
  end

  defp do_shift_charlist([], _code, acc), do: Enum.reverse(acc)

  defp do_shift_charlist([codepoint | tail], code, acc) do
    codepoint = do_shift_codepoint(codepoint, code)

    do_shift_charlist(tail, code, [codepoint | acc])
  end

  defp do_shift_binary(<<>>, _code, acc), do: acc

  defp do_shift_binary(<<codepoint::@char_size, rest::bitstring>>, code, acc) do
    codepoint = do_shift_codepoint(codepoint, code)

    do_shift_binary(rest, code, <<acc::bitstring, codepoint::8>>)
  end

  @doc """
  Function shifts backward all characters in string.
  String could be double-quoted or single-quoted.

  ## Examples
  iex> Caesar.decode("Rovvy", 10)
  "Hello"
  iex> Caesar.decode('Mjqqt', 5)
  'Hello'
  """
  def decode(str, code) do
    case is_list(str) do
      true -> do_shift_charlist(str, -code, [])
      false -> do_shift_binary(str, -code, <<>>)
    end
  end

  @doc ~S"""
  Function shifts forward all characters in string.
  String could be double-quoted or single-quoted.
  All characters should be in range 32-126, otherwise function raises
  RuntimeError with message "invalid ascii str"
  If result characters are out of valid range, than
  function wraps them to the beginning of the range.

  ## Examples
  iex> Caesar.encode_ascii('hello world', 15)
  'wt{{~/\'~\"{s'
  """
  def encode_ascii(str, code) do
    case is_list(str) do
      true -> do_shift_ascii_charlist(str, code, [])
      false -> do_shift_ascii_binary(str, code, <<>>)
    end
  end

  @doc ~S"""
  Function shifts backward all characters in string.
  String could be double-quoted or single-quoted.
  All characters should be in range 32-126, otherwise function raises
  RuntimeError with message "invalid ascii str"
  If result characters are out of valid range, than
  function wraps them to the end of the range.

  ## Examples
  iex> Caesar.decode_ascii('wt{{~/\'~\"{s', 15)
  'hello world'
  """
  def decode_ascii(str, code) do
    case is_list(str) do
      true -> do_shift_ascii_charlist(str, -code, [])
      false -> do_shift_ascii_binary(str, -code, <<>>)
    end
  end

  defp do_shift_ascii_codepoint(codepoint, code) do
    # IO.inspect("before codepoint: #{codepoint} code: #{code}")

    case codepoint >= @min_ascii_char and codepoint <= @max_ascii_char do
      false ->
        raise(RuntimeError, "invalid ascii str")

      true ->
        new_codepoint =
          case codepoint + code do
            cp when cp < @min_ascii_char ->
              # IO.inspect("< 32 codepoint: #{cp} #{@min_ascii_char - cp}")
              @max_ascii_char - (@min_ascii_char - cp - 1)

            cp when cp > @max_ascii_char ->
              # IO.inspect("> 126 codepoint: #{cp}")
              @min_ascii_char + (cp - @max_ascii_char - 1)

            cp ->
              # IO.inspect("normal codepoint: #{cp}")
              cp
          end

        new_codepoint
    end
  end

  defp do_shift_ascii_charlist([], _code, acc), do: Enum.reverse(acc)

  defp do_shift_ascii_charlist([codepoint | tail], code, acc) do
    codepoint = do_shift_ascii_codepoint(codepoint, code)

    do_shift_ascii_charlist(tail, code, [codepoint | acc])
  end

  defp do_shift_ascii_binary(<<>>, _code, acc), do: acc

  defp do_shift_ascii_binary(<<codepoint::8, rest::bitstring>>, code, acc) do
    codepoint = do_shift_ascii_codepoint(codepoint, code)

    do_shift_ascii_binary(rest, code, <<acc::bitstring, codepoint::8>>)
  end
end
