defmodule KWList0 do
  @moduledoc """
  Goal:
  makes sure that syntactic sugar for KeyWord works only for the last argument
  of the function and doesn't work for first in func/2+
  """

  @type t :: binary

  @spec split_1(t, keyword) :: {:ok, t} | {:error, t}
  def split_1(string, options \\ [])

  def split_1(string, options) do
    case options do
      options when is_list(options) -> {:ok, string, options}
      _ -> {:error, string, options}
    end
  end

  # ~/.asdf/installs/elixir/1.16.1-otp-26/lib/elixir/lib/string.ex
  # @spec split(t, pattern | Regex.t(), keyword) :: [t]
  # def split(string, pattern, options \\ [])

  def split_2(options \\ [], string)

  def split_2(options, string) do
    case options do
      options when is_list(options) -> {:ok, string, options}
      _ -> {:error, string, options}
    end
  end

end

ExUnit.start()

defmodule KWListTest do
  use ExUnit.Case
  import KWList0

  test "split_1" do
    assert split_1("str", a: 4, b: 8) ==
      {:ok, "str", [{:a, 4}, {:b, 8}]}

    assert split_1("str", a: 4) == {:ok, "str", [{:a, 4}]}
    assert split_1("str")       == {:ok, "str", []}
    assert split_1("str", 42)   == {:error, "str", 42}
  end

  test "split_2" do
    assert split_2([a: 4, b: 8], "str") ==
      {:ok, "str", [{:a, 4}, {:b, 8}]}

    assert split_2([a: 4], "str") == {:ok, "str", [{:a, 4}]}
    assert split_2([], "str") == {:ok, "str", []}
    assert split_2(42, "str") == {:error, "str", 42}
  end

  # ensure keyword syntaxsugar works only for last argument of the function
  test "split_2 try use surar" do
    # Give  Syntax error after: ','
    # assert split_2(a: 4, b: 8, "str")
    # Give Syntax error after: ','
    # assert split_2(a: 4, "str") == {:ok, "str", [{:a, 4}]}

    assert split_2(a: 4) == {:ok, [{:a, 4}], []}
    assert split_2([], "str") == {:ok, "str", []}
  end
end
