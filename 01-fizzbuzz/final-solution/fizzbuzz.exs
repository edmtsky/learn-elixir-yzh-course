defmodule FizzBuzz do
  @moduledoc """
  FizzBuzz is a simple game, ...
  """

  def main() do
    fizzbuzz_100()
    |> Enum.join(" ")
    |> IO.puts()
  end

  @doc "fizbuzz for all number from 1 to 100"
  @spec fizzbuzz(integer()) :: String.t()
  def fizzbuzz_100() do
    Enum.map(1..100, &fizzbuzz/1)
  end

  def fizzbuzz(number) do
    divisible_by_3 = rem(number, 3) == 0
    divisible_by_5 = rem(number, 5) == 0
    cond do
      divisible_by_3 and divisible_by_5  -> "FizzBuzz"
      divisible_by_3 -> "Fizz"
      divisible_by_5 -> "Buzz"
      true -> to_string(number)
    end
  end

end
