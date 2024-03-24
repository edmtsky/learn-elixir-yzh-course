defmodule FizzBuzz do

  def main() do
    1..100
    |> Enum.map(&fizzbuzz/1)
    |> Enum.join(" ")
    |> IO.puts()
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
