defmodule FizzBuzz do

  def main() do
    fizzbuzz_100()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def fizzbuzz_100() do
    Enum.map(1..100, &fizzbuzz/1)
  end

  @spec fizzbuzz(integer()) :: String.t()
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
